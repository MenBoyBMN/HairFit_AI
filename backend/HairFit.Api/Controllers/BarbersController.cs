using System.Text.Json;
using HairFit.Api.Data;
using HairFit.Api.DTOs;
using HairFit.Api.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace HairFit.Api.Controllers;

[ApiController]
[Route("api/barbers")]
public class BarbersController : ControllerBase
{
    private readonly AppDbContext _db;

    public BarbersController(AppDbContext db)
    {
        _db = db;
    }

    private async Task ResolveAvatarsIfEmptyAsync(List<BarberProfileEntity> barbers)
    {
        var emptyAvatarUids = barbers
            .Where(b => string.IsNullOrWhiteSpace(b.AvatarUrl))
            .Select(b => b.Uid)
            .ToList();

        if (emptyAvatarUids.Count == 0) return;

        var userAvatars = await _db.Users
            .Where(u => emptyAvatarUids.Contains(u.Uid) && u.AvatarUrl != "")
            .ToDictionaryAsync(u => u.Uid, u => u.AvatarUrl);

        bool changed = false;
        foreach (var barber in barbers)
        {
            if (string.IsNullOrWhiteSpace(barber.AvatarUrl) &&
                userAvatars.TryGetValue(barber.Uid, out var userAvatar) &&
                !string.IsNullOrWhiteSpace(userAvatar))
            {
                barber.AvatarUrl = userAvatar.Trim();
                changed = true;
            }
        }

        if (changed)
        {
            await _db.SaveChangesAsync();
        }
    }

    /// <summary>
    /// Lấy danh sách tất cả thợ có trạng thái approved
    /// </summary>
    [HttpGet("approved")]
    public async Task<IActionResult> GetApprovedBarbers()
    {
        var barbers = await _db.BarberProfiles
            .Where(b => b.ApprovalStatus == "approved")
            .ToListAsync();

        await ResolveAvatarsIfEmptyAsync(barbers);
        return Ok(barbers.Select(b => b.ToFlutterMap()).ToList());
    }

    /// <summary>
    /// Lấy danh sách thợ nổi bật (sắp xếp theo ratingAvg giảm dần)
    /// </summary>
    [HttpGet("featured")]
    public async Task<IActionResult> GetFeaturedBarbers([FromQuery] int limit = 5)
    {
        var barbers = await _db.BarberProfiles
            .Where(b => b.ApprovalStatus == "approved")
            .OrderByDescending(b => b.RatingAvg)
            .Take(limit)
            .ToListAsync();

        await ResolveAvatarsIfEmptyAsync(barbers);
        return Ok(barbers.Select(b => b.ToFlutterMap()).ToList());
    }

    /// <summary>
    /// Lấy danh sách thợ đang chờ duyệt (pending)
    /// </summary>
    [HttpGet("pending")]
    public async Task<IActionResult> GetPendingBarbers()
    {
        var barbers = await _db.BarberProfiles
            .Where(b => b.ApprovalStatus == "pending")
            .ToListAsync();

        await ResolveAvatarsIfEmptyAsync(barbers);
        return Ok(barbers.Select(b => b.ToFlutterMap()).ToList());
    }

    /// <summary>
    /// Lấy chi tiết hồ sơ một thợ cắt tóc theo UID
    /// </summary>
    [HttpGet("{uid}")]
    public async Task<IActionResult> GetBarberById(string uid)
    {
        var barber = await _db.BarberProfiles.FindAsync(uid);
        if (barber == null)
        {
            return NotFound(new { code = "BARBER_NOT_FOUND", message = "Không tìm thấy hồ sơ thợ." });
        }

        await ResolveAvatarsIfEmptyAsync(new List<BarberProfileEntity> { barber });
        return Ok(barber.ToFlutterMap());
    }

    /// <summary>
    /// Tạo mới hoặc cập nhật hồ sơ thợ cắt tóc (đồng bộ sang Users)
    /// </summary>
    [HttpPut("{uid}")]
    public async Task<IActionResult> CreateOrUpdateProfile(string uid, [FromBody] JsonElement body)
    {
        var barber = await _db.BarberProfiles.FindAsync(uid);
        var isNew = barber == null;
        if (barber == null)
        {
            barber = new BarberProfileEntity
            {
                Uid = uid,
                CreatedAt = DateTime.UtcNow
            };
            _db.BarberProfiles.Add(barber);
        }

        if (body.TryGetProperty("displayName", out var displayNameEl) && displayNameEl.ValueKind == JsonValueKind.String)
            barber.DisplayName = displayNameEl.GetString()?.Trim() ?? barber.DisplayName;

        if (body.TryGetProperty("avatarUrl", out var avatarEl) && avatarEl.ValueKind == JsonValueKind.String)
            barber.AvatarUrl = avatarEl.GetString()?.Trim() ?? barber.AvatarUrl;

        if (body.TryGetProperty("coverUrl", out var coverEl) && coverEl.ValueKind == JsonValueKind.String)
            barber.CoverUrl = coverEl.GetString()?.Trim() ?? barber.CoverUrl;

        if (body.TryGetProperty("bio", out var bioEl) && bioEl.ValueKind == JsonValueKind.String)
            barber.Bio = bioEl.GetString()?.Trim() ?? barber.Bio;

        if (body.TryGetProperty("address", out var addrEl) && addrEl.ValueKind == JsonValueKind.String)
            barber.Address = addrEl.GetString()?.Trim() ?? barber.Address;

        if (body.TryGetProperty("phone", out var phoneEl))
            barber.Phone = phoneEl.ValueKind == JsonValueKind.String ? phoneEl.GetString()?.Trim() : null;

        if (body.TryGetProperty("location", out var locEl) && locEl.ValueKind == JsonValueKind.Object)
        {
            if (locEl.TryGetProperty("latitude", out var latEl) && latEl.TryGetDouble(out var lat))
                barber.Latitude = lat;
            if (locEl.TryGetProperty("longitude", out var lngEl) && lngEl.TryGetDouble(out var lng))
                barber.Longitude = lng;
        }

        if (body.TryGetProperty("portfolioUrls", out var portEl) && portEl.ValueKind == JsonValueKind.Array)
            barber.PortfolioUrlsJson = portEl.GetRawText();

        if (body.TryGetProperty("isAcceptingBookingsToday", out var accEl) &&
            (accEl.ValueKind == JsonValueKind.True || accEl.ValueKind == JsonValueKind.False))
            barber.IsAcceptingBookingsToday = accEl.GetBoolean();

        if (body.TryGetProperty("priceMin", out var pMinEl) && pMinEl.TryGetInt32(out var pMin))
            barber.PriceMin = pMin;

        if (body.TryGetProperty("priceMax", out var pMaxEl) && pMaxEl.TryGetInt32(out var pMax))
            barber.PriceMax = pMax;

        if (body.TryGetProperty("ratingAvg", out var rAvgEl) && rAvgEl.TryGetDouble(out var rAvg))
            barber.RatingAvg = rAvg;

        if (body.TryGetProperty("ratingCount", out var rCntEl) && rCntEl.TryGetInt32(out var rCnt))
            barber.RatingCount = rCnt;

        if (body.TryGetProperty("approvalStatus", out var appStatusEl) && appStatusEl.ValueKind == JsonValueKind.String)
            barber.ApprovalStatus = appStatusEl.GetString() ?? barber.ApprovalStatus;

        if (body.TryGetProperty("hairstyleIds", out var hsEl) && hsEl.ValueKind == JsonValueKind.Array)
            barber.HairstyleIdsJson = hsEl.GetRawText();

        if (body.TryGetProperty("services", out var svcEl) && svcEl.ValueKind == JsonValueKind.Array)
            barber.ServicesJson = svcEl.GetRawText();

        if (body.TryGetProperty("workingHours", out var whEl) && whEl.ValueKind == JsonValueKind.Object)
            barber.WorkingHoursJson = whEl.GetRawText();

        if (body.TryGetProperty("exceptions", out var exEl) && exEl.ValueKind == JsonValueKind.Array)
            barber.ExceptionsJson = exEl.GetRawText();

        barber.UpdatedAt = DateTime.UtcNow;

        // Đồng bộ avatarUrl và displayName sang bảng Users
        var user = await _db.Users.FindAsync(uid);
        if (user != null)
        {
            if (!string.IsNullOrWhiteSpace(barber.AvatarUrl))
                user.AvatarUrl = barber.AvatarUrl;
            if (!string.IsNullOrWhiteSpace(barber.DisplayName))
                user.DisplayName = barber.DisplayName;
            user.UpdatedAt = DateTime.UtcNow;
        }

        await _db.SaveChangesAsync();
        return Ok(barber.ToFlutterMap());
    }

    /// <summary>
    /// Cập nhật trạng thái nhận khách đặt lịch hôm nay
    /// </summary>
    [HttpPatch("{uid}/accepting")]
    public async Task<IActionResult> UpdateAcceptingBookingsToday(
        string uid,
        [FromBody] UpdateAcceptingBookingsRequest request)
    {
        var barber = await _db.BarberProfiles.FindAsync(uid);
        if (barber == null)
        {
            return NotFound(new { code = "BARBER_NOT_FOUND", message = "Không tìm thấy hồ sơ thợ." });
        }

        barber.IsAcceptingBookingsToday = request.IsAccepting;
        barber.UpdatedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();

        return Ok(barber.ToFlutterMap());
    }

    /// <summary>
    /// Cập nhật trạng thái phê duyệt hồ sơ thợ
    /// </summary>
    [HttpPatch("{uid}/approval")]
    public async Task<IActionResult> UpdateApprovalStatus(
        string uid,
        [FromBody] UpdateApprovalStatusRequest request)
    {
        var barber = await _db.BarberProfiles.FindAsync(uid);
        if (barber == null)
        {
            return NotFound(new { code = "BARBER_NOT_FOUND", message = "Không tìm thấy hồ sơ thợ." });
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
    /// Lấy danh sách đánh giá của thợ theo barberId
    /// </summary>
    [HttpGet("{uid}/reviews")]
    public async Task<IActionResult> GetReviewsForBarber(string uid)
    {
        var reviews = await _db.Reviews
            .AsNoTracking()
            .Where(r => r.BarberId == uid)
            .OrderByDescending(r => r.CreatedAt)
            .ToListAsync();

        return Ok(reviews.Select(r => r.ToFlutterMap()).ToList());
    }
}

// CreBy: MenBoyBMN

