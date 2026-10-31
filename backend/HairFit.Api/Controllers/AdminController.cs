using System.Text.Json;
using HairFit.Api.Data;
using HairFit.Api.DTOs;
using HairFit.Api.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace HairFit.Api.Controllers;

[ApiController]
[Route("api/admin")]
public class AdminController : ControllerBase
{
    private readonly AppDbContext _db;

    public AdminController(AppDbContext db)
    {
        _db = db;
    }

    /// <summary>
    /// Lấy số liệu thống kê tổng quan cho Dashboard
    /// </summary>
    [HttpGet("stats")]
    public async Task<IActionResult> GetDashboardStats()
    {
        var todayStr = DateTime.Now.ToString("yyyy-MM-dd");

        var users = await _db.Users.AsNoTracking().ToListAsync();
        int customers = 0, barbers = 0, admins = 0, blocked = 0;
        foreach (var u in users)
        {
            if (u.IsBlocked) blocked++;
            var role = u.Role.ToLowerInvariant();
            if (role == "barber") barbers++;
            else if (role == "admin") admins++;
            else customers++;
        }

        var barberProfiles = await _db.BarberProfiles.AsNoTracking().ToListAsync();
        int pendingBarbers = 0, approvedBarbers = 0, suspendedBarbers = 0, rejectedBarbers = 0;
        foreach (var b in barberProfiles)
        {
            var status = b.ApprovalStatus.ToLowerInvariant();
            if (status == "pending") pendingBarbers++;
            else if (status == "approved") approvedBarbers++;
            else if (status == "suspended") suspendedBarbers++;
            else if (status == "rejected") rejectedBarbers++;
        }

        var appointments = await _db.Appointments.AsNoTracking().ToListAsync();
        int totalAppToday = 0, pendingAppToday = 0, confirmedAppToday = 0, completedAppToday = 0, cancelledAppToday = 0;
        int revenueToday = 0, expectedRevenueToday = 0, totalRevenue = 0;

        foreach (var a in appointments)
        {
            var status = a.Status.ToLowerInvariant();
            if (status == "completed")
            {
                totalRevenue += a.Price;
            }

            if (a.Date == todayStr)
            {
                totalAppToday++;
                if (status == "pending")
                {
                    pendingAppToday++;
                }
                else if (status == "confirmed")
                {
                    confirmedAppToday++;
                    expectedRevenueToday += a.Price;
                }
                else if (status == "completed")
                {
                    completedAppToday++;
                    revenueToday += a.Price;
                    expectedRevenueToday += a.Price;
                }
                else if (status == "cancelled" || status == "rejected")
                {
                    cancelledAppToday++;
                }
            }
        }

        var hairstylesCount = await _db.Hairstyles.CountAsync();
        var reviewsCount = await _db.Reviews.CountAsync();

        return Ok(new Dictionary<string, object>
        {
            ["totalUsers"] = users.Count,
            ["totalCustomers"] = customers,
            ["totalBarbers"] = barbers,
            ["totalAdmins"] = admins,
            ["blockedUsers"] = blocked,
            ["pendingBarbers"] = pendingBarbers,
            ["approvedBarbers"] = approvedBarbers,
            ["suspendedBarbers"] = suspendedBarbers,
            ["rejectedBarbers"] = rejectedBarbers,
            ["totalAppointmentsToday"] = totalAppToday,
            ["pendingAppointmentsToday"] = pendingAppToday,
            ["confirmedAppointmentsToday"] = confirmedAppToday,
            ["completedAppointmentsToday"] = completedAppToday,
            ["cancelledAppointmentsToday"] = cancelledAppToday,
            ["revenueToday"] = revenueToday,
            ["expectedRevenueToday"] = expectedRevenueToday,
            ["totalRevenue"] = totalRevenue,
            ["totalAppointments"] = appointments.Count,
            ["totalHairstyles"] = hairstylesCount,
            ["totalReviews"] = reviewsCount
        });
    }

    /// <summary>
    /// Lấy danh sách thợ chờ duyệt gần nhất
    /// </summary>
    [HttpGet("barbers/recent-pending")]
    public async Task<IActionResult> GetRecentPendingBarbers([FromQuery] int limit = 5)
    {
        var list = await _db.BarberProfiles
            .AsNoTracking()
            .Where(b => b.ApprovalStatus == "pending")
            .Take(limit)
            .ToListAsync();

        return Ok(list.Select(b => b.ToFlutterMap()).ToList());
    }

    /// <summary>
    /// Lấy danh sách tất cả thợ với bộ lọc trạng thái tùy chọn
    /// </summary>
    [HttpGet("barbers")]
    public async Task<IActionResult> GetAllBarbers([FromQuery] string? statusFilter)
    {
        var query = _db.BarberProfiles.AsNoTracking();
        if (!string.IsNullOrWhiteSpace(statusFilter) && statusFilter != "all")
        {
            query = query.Where(b => b.ApprovalStatus == statusFilter);
        }

        var list = await query.OrderBy(b => b.DisplayName).ToListAsync();
        return Ok(list.Select(b => b.ToFlutterMap()).ToList());
    }

    /// <summary>
    /// Lấy danh sách người dùng với bộ lọc vai trò tùy chọn
    /// </summary>
    [HttpGet("users")]
    public async Task<IActionResult> GetAllUsers([FromQuery] string? roleFilter)
    {
        var query = _db.Users.AsNoTracking();
        if (!string.IsNullOrWhiteSpace(roleFilter) && roleFilter != "all")
        {
            query = query.Where(u => u.Role == roleFilter);
        }

        var list = await query.OrderByDescending(u => u.CreatedAt).ToListAsync();
        return Ok(list.Select(u => u.ToFlutterMap()).ToList());
    }

    /// <summary>
    /// Khóa hoặc mở khóa tài khoản người dùng (đồng bộ sang BarberProfiles nếu là thợ)
    /// </summary>
    [HttpPatch("users/{uid}/block")]
    public async Task<IActionResult> SetUserBlockStatus(
        string uid,
        [FromBody] SetUserBlockStatusRequest request)
    {
        var user = await _db.Users.FindAsync(uid);
        if (user == null)
        {
            return NotFound(new { message = "Không tìm thấy người dùng." });
        }

        user.IsBlocked = request.IsBlocked;
        user.UpdatedAt = DateTime.UtcNow;

        if (request.IsBlocked)
        {
            var barber = await _db.BarberProfiles.FindAsync(uid);
            if (barber != null)
            {
                barber.ApprovalStatus = "suspended";
                barber.IsAcceptingBookingsToday = false;
                barber.UpdatedAt = DateTime.UtcNow;
            }
        }

        await _db.SaveChangesAsync();
        return Ok(user.ToFlutterMap());
    }

    /// <summary>
    /// Cập nhật vai trò (Role) người dùng & khởi tạo hồ sơ thợ nếu chuyển sang barber
    /// </summary>
    [HttpPatch("users/{uid}/role")]
    public async Task<IActionResult> UpdateUserRole(
        string uid,
        [FromBody] UpdateUserRoleRequest request)
    {
        var user = await _db.Users.FindAsync(uid);
        if (user == null)
        {
            return NotFound(new { message = "Không tìm thấy người dùng." });
        }

        user.Role = request.NewRole;
        user.UpdatedAt = DateTime.UtcNow;

        if (request.NewRole == "barber")
        {
            var barber = await _db.BarberProfiles.FindAsync(uid);
            if (barber == null)
            {
                _db.BarberProfiles.Add(new BarberProfileEntity
                {
                    Uid = uid,
                    DisplayName = string.IsNullOrWhiteSpace(user.DisplayName) ? "Tiệm Tóc Mới" : user.DisplayName,
                    AvatarUrl = user.AvatarUrl,
                    Phone = user.Phone,
                    Address = "Chưa cập nhật địa chỉ",
                    Latitude = 16.0544,
                    Longitude = 108.2022,
                    ApprovalStatus = "pending",
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                });
            }
        }

        await _db.SaveChangesAsync();
        return Ok(user.ToFlutterMap());
    }

    /// <summary>
    /// Cập nhật thông tin cơ bản của người dùng từ Admin
    /// </summary>
    [HttpPut("users/{uid}")]
    public async Task<IActionResult> UpdateUserInfo(
        string uid,
        [FromBody] UpdateUserInfoAdminRequest request)
    {
        var user = await _db.Users.FindAsync(uid);
        if (user == null)
        {
            return NotFound(new { message = "Không tìm thấy người dùng." });
        }

        var cleanPhone = request.Phone?.Trim();
        user.DisplayName = request.DisplayName.Trim();
        user.Phone = string.IsNullOrEmpty(cleanPhone) ? null : cleanPhone;
        user.UpdatedAt = DateTime.UtcNow;

        var barber = await _db.BarberProfiles.FindAsync(uid);
        if (barber != null)
        {
            if (!string.IsNullOrEmpty(cleanPhone))
            {
                barber.Phone = cleanPhone;
            }
            barber.UpdatedAt = DateTime.UtcNow;
        }

        await _db.SaveChangesAsync();
        return Ok(user.ToFlutterMap());
    }

    /// <summary>
    /// Lấy lịch sử đặt lịch của một người dùng (Khách hàng hoặc Thợ)
    /// </summary>
    [HttpGet("users/{uid}/appointments")]
    public async Task<IActionResult> GetUserAppointments(
        string uid,
        [FromQuery] bool isBarber = false,
        [FromQuery] int limit = 50)
    {
        var query = _db.Appointments.AsNoTracking();
        query = isBarber
            ? query.Where(a => a.BarberId == uid)
            : query.Where(a => a.CustomerId == uid);

        var list = await query
            .OrderByDescending(a => a.StartTimestamp)
            .Take(limit)
            .ToListAsync();

        return Ok(list.Select(a => a.ToFlutterMap()).ToList());
    }

    /// <summary>
    /// Cập nhật tọa độ bản đồ của tiệm tóc
    /// </summary>
    [HttpPatch("barbers/{uid}/location")]
    public async Task<IActionResult> UpdateBarberLocation(
        string uid,
        [FromBody] UpdateBarberLocationRequest request)
    {
        var barber = await _db.BarberProfiles.FindAsync(uid);
        if (barber == null)
        {
            return NotFound(new { message = "Không tìm thấy hồ sơ thợ." });
        }

        barber.Latitude = request.Latitude;
        barber.Longitude = request.Longitude;
        barber.UpdatedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();

        return Ok(barber.ToFlutterMap());
    }

    /// <summary>
    /// Admin chỉnh sửa toàn diện thông tin tiệm cắt tóc
    /// </summary>
    [HttpPut("barbers/{uid}")]
    public async Task<IActionResult> UpdateBarberProfileAdmin(
        string uid,
        [FromBody] UpdateBarberProfileAdminRequest request)
    {
        var barber = await _db.BarberProfiles.FindAsync(uid);
        if (barber == null)
        {
            return NotFound(new { message = "Không tìm thấy hồ sơ thợ." });
        }

        var cleanPhone = request.Phone?.Trim();
        barber.DisplayName = request.DisplayName.Trim();
        barber.Address = request.Address.Trim();
        barber.Phone = string.IsNullOrEmpty(cleanPhone) ? null : cleanPhone;
        barber.Bio = request.Bio.Trim();
        barber.Latitude = request.Latitude;
        barber.Longitude = request.Longitude;
        barber.IsAcceptingBookingsToday = request.IsAcceptingBookingsToday;
        barber.UpdatedAt = DateTime.UtcNow;

        await _db.SaveChangesAsync();
        return Ok(barber.ToFlutterMap());
    }

    /// <summary>
    /// Cập nhật trạng thái duyệt của thợ
    /// </summary>
    [HttpPatch("barbers/{uid}/status")]
    public async Task<IActionResult> UpdateBarberStatus(
        string uid,
        [FromBody] UpdateApprovalStatusRequest request)
    {
        var barber = await _db.BarberProfiles.FindAsync(uid);
        if (barber == null)
        {
            return NotFound(new { message = "Không tìm thấy hồ sơ thợ." });
        }

        barber.ApprovalStatus = request.Status;
        if (request.Status == "suspended" || request.Status == "rejected")
        {
            barber.IsAcceptingBookingsToday = false;
        }
        barber.UpdatedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();

        return Ok(barber.ToFlutterMap());
    }

    /// <summary>
    /// Xóa hồ sơ thợ cắt tóc
    /// </summary>
    [HttpDelete("barbers/{uid}")]
    public async Task<IActionResult> DeleteBarberProfile(string uid)
    {
        var barber = await _db.BarberProfiles.FindAsync(uid);
        if (barber != null)
        {
            _db.BarberProfiles.Remove(barber);
            await _db.SaveChangesAsync();
        }
        return Ok(new { message = "Đã xóa hồ sơ thợ thành công." });
    }

    /// <summary>
    /// Lấy danh sách lịch hẹn theo ngày và trạng thái
    /// </summary>
    [HttpGet("appointments")]
    public async Task<IActionResult> GetAppointments(
        [FromQuery] string? date,
        [FromQuery] string? status,
        [FromQuery] int limit = 100)
    {
        var query = _db.Appointments.AsNoTracking();
        if (!string.IsNullOrWhiteSpace(date))
        {
            query = query.Where(a => a.Date == date);
        }
        if (!string.IsNullOrWhiteSpace(status) && status != "all")
        {
            query = query.Where(a => a.Status == status);
        }

        var list = await query
            .OrderByDescending(a => a.StartTimestamp)
            .Take(limit)
            .ToListAsync();

        return Ok(list.Select(a => a.ToFlutterMap()).ToList());
    }

    /// <summary>
    /// Admin cập nhật trạng thái lịch hẹn (Xác nhận / Hoàn tất / Hủy) chuẩn ACID Transaction
    /// </summary>
    [HttpPatch("appointments/{appointmentId}/status")]
    public async Task<IActionResult> UpdateAppointmentStatusAdmin(
        string appointmentId,
        [FromBody] UpdateAppointmentStatusAdminRequest request)
    {
        await using var transaction = await _db.Database.BeginTransactionAsync();
        var appointment = await _db.Appointments.FindAsync(appointmentId);
        if (appointment == null)
        {
            return NotFound(new { message = "Lịch hẹn không tồn tại." });
        }

        var cleanReason = request.Reason?.Trim() ?? string.Empty;
        var updatedNote = appointment.Note;
        if (!string.IsNullOrEmpty(cleanReason) && !updatedNote.Contains(cleanReason))
        {
            updatedNote = string.IsNullOrEmpty(updatedNote)
                ? $"[{cleanReason}]"
                : $"{updatedNote} [{cleanReason}]";
        }

        appointment.Status = request.NewStatus;
        appointment.Note = updatedNote;
        appointment.UpdatedAt = DateTime.UtcNow;

        if (request.NewStatus == "cancelled" || request.NewStatus == "rejected")
        {
            var slotIds = JsonHelper.DeserializeList<string>(appointment.SlotIdsJson);
            var slotsToRemove = await _db.BookedSlots
                .Where(s => slotIds.Contains(s.Id) || s.AppointmentId == appointmentId)
                .ToListAsync();

            if (slotsToRemove.Count > 0)
            {
                _db.BookedSlots.RemoveRange(slotsToRemove);
            }
        }

        await _db.SaveChangesAsync();
        await transaction.CommitAsync();

        return Ok(appointment.ToFlutterMap());
    }

    /// <summary>
    /// Lấy danh sách tất cả kiểu tóc trong catalog (cả active và inactive)
    /// </summary>
    [HttpGet("hairstyles")]
    public async Task<IActionResult> GetHairstyles()
    {
        var list = await _db.Hairstyles.AsNoTracking().ToListAsync();
        return Ok(list.Select(h => h.ToFlutterMap()).ToList());
    }

    /// <summary>
    /// Thêm mới hoặc cập nhật kiểu tóc vào catalog
    /// </summary>
    [HttpPost("hairstyles")]
    public async Task<IActionResult> SaveHairstyle([FromBody] JsonElement body)
    {
        var id = body.TryGetProperty("id", out var idEl) && idEl.ValueKind == JsonValueKind.String
            ? idEl.GetString()
            : null;

        if (string.IsNullOrWhiteSpace(id))
        {
            id = Guid.NewGuid().ToString("N")[..12];
        }

        var entity = await _db.Hairstyles.FindAsync(id);
        if (entity == null)
        {
            entity = new HairstyleEntity { Id = id };
            _db.Hairstyles.Add(entity);
        }

        if (body.TryGetProperty("name", out var nameEl) && nameEl.ValueKind == JsonValueKind.String)
            entity.Name = nameEl.GetString() ?? entity.Name;

        if (body.TryGetProperty("description", out var descEl) && descEl.ValueKind == JsonValueKind.String)
            entity.Description = descEl.GetString() ?? entity.Description;

        if (body.TryGetProperty("imageUrl", out var imgEl) && imgEl.ValueKind == JsonValueKind.String)
            entity.ImageUrl = imgEl.GetString() ?? entity.ImageUrl;

        if (body.TryGetProperty("imageUrls", out var imgsEl) && imgsEl.ValueKind == JsonValueKind.Array)
            entity.ImageUrlsJson = imgsEl.GetRawText();

        if (body.TryGetProperty("faceShapes", out var fsEl) && fsEl.ValueKind == JsonValueKind.Array)
            entity.FaceShapesJson = fsEl.GetRawText();

        if (body.TryGetProperty("tags", out var tagsEl) && tagsEl.ValueKind == JsonValueKind.Array)
            entity.TagsJson = tagsEl.GetRawText();

        if (body.TryGetProperty("active", out var actEl) &&
            (actEl.ValueKind == JsonValueKind.True || actEl.ValueKind == JsonValueKind.False))
            entity.Active = actEl.GetBoolean();

        await _db.SaveChangesAsync();
        return Ok(entity.ToFlutterMap());
    }

    /// <summary>
    /// Xóa kiểu tóc khỏi catalog
    /// </summary>
    [HttpDelete("hairstyles/{id}")]
    public async Task<IActionResult> DeleteHairstyle(string id)
    {
        var entity = await _db.Hairstyles.FindAsync(id);
        if (entity != null)
        {
            _db.Hairstyles.Remove(entity);
            await _db.SaveChangesAsync();
        }
        return Ok(new { message = "Đã xóa kiểu tóc thành công." });
    }

    /// <summary>
    /// Lấy danh sách đánh giá toàn hệ thống
    /// </summary>
    [HttpGet("reviews")]
    public async Task<IActionResult> GetReviews([FromQuery] int? ratingFilter, [FromQuery] int limit = 100)
    {
        var query = _db.Reviews.AsNoTracking();
        if (ratingFilter.HasValue)
        {
            query = query.Where(r => r.Rating == ratingFilter.Value);
        }

        var list = await query
            .OrderByDescending(r => r.CreatedAt)
            .Take(limit)
            .ToListAsync();

        return Ok(list.Select(r => r.ToFlutterMap()).ToList());
    }

    /// <summary>
    /// Xóa đánh giá độc hại, gỡ đánh giá khỏi lịch hẹn và tính lại rating của thợ
    /// </summary>
    [HttpDelete("reviews/{reviewId}")]
    public async Task<IActionResult> DeleteReview(
        string reviewId,
        [FromQuery] string barberId,
        [FromQuery] int rating,
        [FromQuery] string? appointmentId)
    {
        await using var transaction = await _db.Database.BeginTransactionAsync();
        var review = await _db.Reviews.FindAsync(reviewId);
        var resolvedAppointmentId = appointmentId;

        if (review != null)
        {
            if (string.IsNullOrWhiteSpace(resolvedAppointmentId))
            {
                resolvedAppointmentId = review.AppointmentId;
            }
            _db.Reviews.Remove(review);
        }

        if (!string.IsNullOrWhiteSpace(resolvedAppointmentId))
        {
            var app = await _db.Appointments.FindAsync(resolvedAppointmentId);
            if (app != null)
            {
                app.Rating = null;
                app.ReviewComment = null;
                app.UpdatedAt = DateTime.UtcNow;
            }
        }

        if (!string.IsNullOrWhiteSpace(barberId))
        {
            var barber = await _db.BarberProfiles.FindAsync(barberId);
            if (barber != null)
            {
                var currentAvg = barber.RatingAvg > 0 ? barber.RatingAvg : 5.0;
                var currentCount = barber.RatingCount > 0 ? barber.RatingCount : 1;

                if (currentCount > 1)
                {
                    var newCount = currentCount - 1;
                    var newTotalScore = (currentAvg * currentCount) - rating;
                    var newAvg = Math.Clamp(newTotalScore / newCount, 1.0, 5.0);
                    barber.RatingAvg = Math.Round(newAvg, 1);
                    barber.RatingCount = newCount;
                }
                else
                {
                    barber.RatingAvg = 5.0;
                    barber.RatingCount = 0;
                }
                barber.UpdatedAt = DateTime.UtcNow;
            }
        }

        await _db.SaveChangesAsync();
        await transaction.CommitAsync();

        return Ok(new { message = "Đã xóa đánh giá thành công." });
    }

    /// <summary>
    /// Đọc cấu hình vận hành hệ thống
    /// </summary>
    [HttpGet("settings")]
    public async Task<IActionResult> GetSystemSettings()
    {
        var setting = await _db.SystemSettings.AsNoTracking().FirstOrDefaultAsync(s => s.Key == "global");
        if (setting == null)
        {
            return Ok(new Dictionary<string, object>
            {
                ["searchRadiusKm"] = 10.0,
                ["cancelNoticeHours"] = 1,
                ["maintenanceMode"] = false
            });
        }

        return Ok(setting.ToFlutterMap());
    }

    /// <summary>
    /// Lưu cấu hình vận hành hệ thống
    /// </summary>
    [HttpPut("settings")]
    public async Task<IActionResult> SaveSystemSettings([FromBody] SaveSystemSettingsRequest request)
    {
        var setting = await _db.SystemSettings.FindAsync("global");
        if (setting == null)
        {
            setting = new SystemSettingEntity { Key = "global" };
            _db.SystemSettings.Add(setting);
        }

        setting.SearchRadiusKm = request.SearchRadiusKm;
        setting.CancelNoticeHours = request.CancelNoticeHours;
        setting.MaintenanceMode = request.MaintenanceMode;
        setting.UpdatedAt = DateTime.UtcNow;

        await _db.SaveChangesAsync();
        return Ok(setting.ToFlutterMap());
    }
}

// CreBy: MenBoyBMN

