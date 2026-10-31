using System.Data;
using System.Globalization;
using HairFit.Api.Data;
using HairFit.Api.DTOs;
using HairFit.Api.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace HairFit.Api.Controllers;

[ApiController]
[Route("api/bookings")]
public class BookingsController : ControllerBase
{
    private const int MaxActiveBookingsPerCustomer = 2;
    private const int LeadTimeMinutes = 30;
    private const int MaxBookingDaysAhead = 30;

    private readonly AppDbContext _db;

    public BookingsController(AppDbContext db)
    {
        _db = db;
    }

    private static DateTime CombineDateAndTime(string dateStr, string timeStr)
    {
        if (DateTime.TryParseExact(
            $"{dateStr} {timeStr}",
            "yyyy-MM-dd HH:mm",
            CultureInfo.InvariantCulture,
            DateTimeStyles.AssumeLocal,
            out var dt))
        {
            return dt;
        }
        return DateTime.Now;
    }

    /// <summary>
    /// Đếm số lượng lịch hẹn đang active (pending hoặc confirmed) của một khách hàng
    /// </summary>
    [HttpGet("active-count/{customerId}")]
    public async Task<IActionResult> CountActiveBookings(string customerId)
    {
        var count = await _db.Appointments
            .AsNoTracking()
            .CountAsync(a => a.CustomerId == customerId &&
                             (a.Status == "pending" || a.Status == "confirmed"));

        return Ok(new { count });
    }

    /// <summary>
    /// Lấy danh sách các slot đã đặt của thợ theo ngày và tự động dọn dẹp slot mồ côi
    /// </summary>
    [HttpGet("slots")]
    public async Task<IActionResult> GetBookedSlotsForDate(
        [FromQuery] string barberId,
        [FromQuery] string date)
    {
        if (string.IsNullOrWhiteSpace(barberId) || string.IsNullOrWhiteSpace(date))
        {
            return Ok(Array.Empty<object>());
        }

        // 1. Lấy các lịch hẹn đang active của thợ trong ngày
        var activeAppointments = await _db.Appointments
            .AsNoTracking()
            .Where(a => a.BarberId == barberId &&
                        a.Date == date &&
                        (a.Status == "pending" || a.Status == "confirmed"))
            .ToListAsync();

        var activeAppointmentIds = activeAppointments.Select(a => a.Id).ToHashSet();

        // 2. Lấy các bản ghi trong BookedSlots
        var bookedSlots = await _db.BookedSlots
            .Where(s => s.BarberId == barberId && s.Date == date)
            .ToListAsync();

        var validSlots = new List<BookedSlotEntity>();
        var orphanedSlots = new List<BookedSlotEntity>();

        foreach (var slot in bookedSlots)
        {
            if (slot.IsBlockedByBarber ||
                slot.AppointmentId == "BLOCKED_BY_BARBER" ||
                activeAppointmentIds.Contains(slot.AppointmentId))
            {
                validSlots.Add(slot);
            }
            else
            {
                orphanedSlots.Add(slot);
            }
        }

        // 3. Tự động xóa các slot mồ côi
        if (orphanedSlots.Count > 0)
        {
            _db.BookedSlots.RemoveRange(orphanedSlots);
            await _db.SaveChangesAsync();
        }

        // 4. Bổ sung các slot từ active appointments nếu bị thiếu
        var existingSlotIds = validSlots.Select(s => s.Id).ToHashSet();
        foreach (var app in activeAppointments)
        {
            var slotIds = JsonHelper.DeserializeList<string>(app.SlotIdsJson);
            foreach (var slotId in slotIds)
            {
                if (!existingSlotIds.Contains(slotId))
                {
                    var timePart = slotId.Contains('_')
                        ? slotId.Split('_').Last().Replace('-', ':')
                        : app.StartTime;
                    var subSlotTimestamp = CombineDateAndTime(app.Date, timePart);
                    validSlots.Add(new BookedSlotEntity
                    {
                        Id = slotId,
                        BarberId = barberId,
                        Date = app.Date,
                        Time = timePart,
                        AppointmentId = app.Id,
                        StartTimestamp = subSlotTimestamp,
                        CreatedAt = app.CreatedAt
                    });
                    existingSlotIds.Add(slotId);
                }
            }
        }

        return Ok(validSlots.Select(s => s.ToFlutterMap()).ToList());
    }

    /// <summary>
    /// Thợ tự khóa slot giờ nghỉ / bận đột xuất
    /// </summary>
    [HttpPost("block-slots")]
    public async Task<IActionResult> BlockSlotsByBarber([FromBody] BlockSlotsRequest request)
    {
        var reason = string.IsNullOrWhiteSpace(request.Reason)
            ? "Giờ nghỉ / Bận đột xuất"
            : request.Reason.Trim();

        foreach (var time in request.Times ?? new List<string>())
        {
            var sanitizedTime = time.Replace(':', '-');
            var slotId = $"{request.BarberId}_{request.Date}_{sanitizedTime}";
            var subSlotTimestamp = CombineDateAndTime(request.Date, time);

            var existing = await _db.BookedSlots.FindAsync(slotId);
            if (existing == null)
            {
                _db.BookedSlots.Add(new BookedSlotEntity
                {
                    Id = slotId,
                    BarberId = request.BarberId,
                    Date = request.Date,
                    Time = time,
                    AppointmentId = "BLOCKED_BY_BARBER",
                    IsBlockedByBarber = true,
                    BlockReason = reason,
                    StartTimestamp = subSlotTimestamp,
                    CreatedAt = DateTime.UtcNow
                });
            }
            else
            {
                existing.AppointmentId = "BLOCKED_BY_BARBER";
                existing.IsBlockedByBarber = true;
                existing.BlockReason = reason;
                existing.StartTimestamp = subSlotTimestamp;
            }
        }

        await _db.SaveChangesAsync();
        return Ok(new { message = "Đã khóa khung giờ thành công." });
    }

    /// <summary>
    /// Thợ mở lại slot đã khóa
    /// </summary>
    [HttpDelete("block-slots/{slotId}")]
    public async Task<IActionResult> UnblockSlotByBarber(string slotId)
    {
        var existing = await _db.BookedSlots.FindAsync(slotId);
        if (existing != null)
        {
            _db.BookedSlots.Remove(existing);
            await _db.SaveChangesAsync();
        }
        return Ok(new { message = "Đã mở khóa khung giờ thành công." });
    }

    /// <summary>
    /// Đặt lịch hẹn nguyên tử bằng SQL Transaction (ACID)
    /// </summary>
    [HttpPost]
    public async Task<IActionResult> CreateBooking([FromBody] CreateBookingRequest request)
    {
        var now = !string.IsNullOrWhiteSpace(request.CurrentTime) &&
                  DateTime.TryParse(request.CurrentTime, out var parsedNow)
            ? parsedNow
            : DateTime.Now;

        // 1. Kiểm tra số lượng lịch active của khách hàng (Tối đa 2)
        var activeCount = await _db.Appointments
            .CountAsync(a => a.CustomerId == request.CustomerId &&
                             (a.Status == "pending" || a.Status == "confirmed"));

        if (activeCount >= MaxActiveBookingsPerCustomer)
        {
            return BadRequest(new
            {
                code = "MAX_BOOKINGS_EXCEEDED",
                message = $"Bạn đã có {MaxActiveBookingsPerCustomer} lịch hẹn chưa hoàn thành. Không thể đặt thêm!"
            });
        }

        // 2. Kiểm tra thời gian hợp lệ (lead time 30 phút, tối đa 30 ngày)
        var startTimestamp = CombineDateAndTime(request.Date, request.StartTime);
        var endTimestamp = CombineDateAndTime(request.Date, request.EndTime);

        if (startTimestamp < now.AddMinutes(LeadTimeMinutes))
        {
            return BadRequest(new
            {
                code = "LEAD_TIME_VIOLATION",
                message = $"Vui lòng đặt lịch trước ít nhất {LeadTimeMinutes} phút!"
            });
        }

        if (startTimestamp > now.AddDays(MaxBookingDaysAhead))
        {
            return BadRequest(new
            {
                code = "MAX_DAYS_EXCEEDED",
                message = $"Chỉ được đặt lịch trước tối đa {MaxBookingDaysAhead} ngày!"
            });
        }

        if (request.SlotIds == null || request.SlotIds.Count == 0)
        {
            return BadRequest(new
            {
                code = "BOOKING_ERROR",
                message = "Danh sách slot thời gian không hợp lệ"
            });
        }

        // 3. Thực thi SQL Transaction chống trùng lịch
        await using var transaction = await _db.Database.BeginTransactionAsync(IsolationLevel.Serializable);
        try
        {
            // Kiểm tra có slot nào đã tồn tại không
            var conflictingSlot = await _db.BookedSlots
                .FirstOrDefaultAsync(s => request.SlotIds.Contains(s.Id));

            if (conflictingSlot != null)
            {
                await transaction.RollbackAsync();
                return Conflict(new
                {
                    code = "SLOT_ALREADY_BOOKED",
                    slotId = conflictingSlot.Id,
                    message = "Khung giờ này vừa có người khác đặt. Vui lòng chọn khung giờ khác!"
                });
            }

            var appointmentId = Guid.NewGuid().ToString("N")[..20];
            var utcNow = DateTime.UtcNow;

            var appointment = new AppointmentEntity
            {
                Id = appointmentId,
                CustomerId = request.CustomerId,
                CustomerName = request.CustomerName,
                BarberId = request.BarberId,
                BarberName = request.BarberName,
                ServiceId = request.ServiceId,
                ServiceName = request.ServiceName,
                Price = request.Price,
                DurationMinutes = request.DurationMinutes,
                Date = request.Date,
                StartTime = request.StartTime,
                EndTime = request.EndTime,
                StartTimestamp = startTimestamp,
                EndTimestamp = endTimestamp,
                Timezone = "Asia/Ho_Chi_Minh",
                SlotIdsJson = JsonHelper.Serialize(request.SlotIds),
                HairstyleId = request.HairstyleId ?? string.Empty,
                CustomerFaceShape = string.IsNullOrWhiteSpace(request.CustomerFaceShape) ? null : request.CustomerFaceShape,
                AiStylingTip = string.IsNullOrWhiteSpace(request.AiStylingTip) ? null : request.AiStylingTip,
                HairstyleImageUrl = string.IsNullOrWhiteSpace(request.HairstyleImageUrl) ? null : request.HairstyleImageUrl,
                CustomerPhone = string.IsNullOrWhiteSpace(request.CustomerPhone) ? null : request.CustomerPhone,
                BarberPhone = string.IsNullOrWhiteSpace(request.BarberPhone) ? null : request.BarberPhone,
                Note = request.Note?.Trim() ?? string.Empty,
                Status = "pending",
                CreatedAt = utcNow,
                UpdatedAt = utcNow
            };

            _db.Appointments.Add(appointment);

            foreach (var slotId in request.SlotIds)
            {
                var timePart = slotId.Split('_').Last().Replace('-', ':');
                var subSlotTimestamp = CombineDateAndTime(request.Date, timePart);
                _db.BookedSlots.Add(new BookedSlotEntity
                {
                    Id = slotId,
                    BarberId = request.BarberId,
                    Date = request.Date,
                    Time = timePart,
                    AppointmentId = appointmentId,
                    StartTimestamp = subSlotTimestamp,
                    IsBlockedByBarber = false,
                    CreatedAt = utcNow
                });
            }

            await _db.SaveChangesAsync();
            await transaction.CommitAsync();

            return Ok(new { appointmentId });
        }
        catch (DbUpdateException)
        {
            await transaction.RollbackAsync();
            return Conflict(new
            {
                code = "SLOT_ALREADY_BOOKED",
                slotId = request.SlotIds.FirstOrDefault() ?? "",
                message = "Khung giờ này vừa có người khác đặt. Vui lòng chọn khung giờ khác!"
            });
        }
    }

    /// <summary>
    /// Hủy lịch hẹn nguyên tử (Atomic Cancel Transaction)
    /// </summary>
    [HttpPost("{appointmentId}/cancel")]
    public async Task<IActionResult> CancelBooking(
        string appointmentId,
        [FromBody] CancelBookingRequest request)
    {
        var now = !string.IsNullOrWhiteSpace(request.CurrentTime) &&
                  DateTime.TryParse(request.CurrentTime, out var parsedNow)
            ? parsedNow
            : DateTime.Now;

        await using var transaction = await _db.Database.BeginTransactionAsync();
        var appointment = await _db.Appointments.FindAsync(appointmentId);
        if (appointment == null)
        {
            return NotFound(new
            {
                code = "CANNOT_CANCEL",
                message = "Lịch hẹn không tồn tại trên hệ thống!"
            });
        }

        if (appointment.Status != "pending" && appointment.Status != "confirmed")
        {
            return BadRequest(new
            {
                code = "CANNOT_CANCEL",
                message = $"Không thể hủy lịch hẹn đã ở trạng thái \"{appointment.Status}\"!"
            });
        }

        var cancelCutoff = appointment.StartTimestamp.AddMinutes(-LeadTimeMinutes);
        if (now > cancelCutoff)
        {
            return BadRequest(new
            {
                code = "CANNOT_CANCEL",
                message = "Chỉ được hủy lịch trước giờ hẹn ít nhất 30 phút!"
            });
        }

        appointment.Status = "cancelled";
        appointment.UpdatedAt = DateTime.UtcNow;

        var slotIds = JsonHelper.DeserializeList<string>(appointment.SlotIdsJson);
        var slotsToRemove = await _db.BookedSlots
            .Where(s => slotIds.Contains(s.Id) || s.AppointmentId == appointmentId)
            .ToListAsync();

        if (slotsToRemove.Count > 0)
        {
            _db.BookedSlots.RemoveRange(slotsToRemove);
        }

        await _db.SaveChangesAsync();
        await transaction.CommitAsync();

        return Ok(new { message = "Đã hủy lịch hẹn thành công!" });
    }

    /// <summary>
    /// Đổi giờ hẹn nguyên tử (Atomic Reschedule Transaction)
    /// </summary>
    [HttpPost("{appointmentId}/reschedule")]
    public async Task<IActionResult> RescheduleBooking(
        string appointmentId,
        [FromBody] RescheduleBookingRequest request)
    {
        var now = DateTime.Now;
        var newStartTimestamp = CombineDateAndTime(request.NewDate, request.NewStartTime);
        var newEndTimestamp = CombineDateAndTime(request.NewDate, request.NewEndTime);

        if (newStartTimestamp < now.AddMinutes(LeadTimeMinutes))
        {
            return BadRequest(new
            {
                code = "LEAD_TIME_VIOLATION",
                message = $"Vui lòng đặt lịch trước ít nhất {LeadTimeMinutes} phút!"
            });
        }

        await using var transaction = await _db.Database.BeginTransactionAsync(IsolationLevel.Serializable);
        var appointment = await _db.Appointments.FindAsync(appointmentId);
        if (appointment == null)
        {
            return NotFound(new
            {
                code = "BOOKING_ERROR",
                message = "Lịch hẹn không tồn tại trên hệ thống!"
            });
        }

        if (appointment.Status != "pending" && appointment.Status != "confirmed")
        {
            return BadRequest(new
            {
                code = "BOOKING_ERROR",
                message = "Chỉ có thể đổi giờ đối với lịch hẹn đang chờ duyệt hoặc đã tiếp nhận!"
            });
        }

        var newSlotIds = request.NewSlotIds ?? new List<string>();
        var oldSlotIds = JsonHelper.DeserializeList<string>(appointment.SlotIdsJson);
        var newlyRequestedSlots = newSlotIds.Except(oldSlotIds).ToList();

        if (newlyRequestedSlots.Count > 0)
        {
            var conflict = await _db.BookedSlots
                .FirstOrDefaultAsync(s => newlyRequestedSlots.Contains(s.Id));
            if (conflict != null)
            {
                await transaction.RollbackAsync();
                return Conflict(new
                {
                    code = "SLOT_ALREADY_BOOKED",
                    slotId = conflict.Id,
                    message = "Khung giờ này vừa có người khác đặt. Vui lòng chọn khung giờ khác!"
                });
            }
        }

        // Xóa các slot cũ không còn nằm trong danh sách mới
        var slotsToDeleteIds = oldSlotIds.Except(newSlotIds).ToList();
        if (slotsToDeleteIds.Count > 0)
        {
            var oldSlots = await _db.BookedSlots
                .Where(s => slotsToDeleteIds.Contains(s.Id))
                .ToListAsync();
            _db.BookedSlots.RemoveRange(oldSlots);
        }

        // Thêm các slot mới
        var utcNow = DateTime.UtcNow;
        foreach (var slotId in newlyRequestedSlots)
        {
            var timePart = slotId.Split('_').Last().Replace('-', ':');
            var subSlotTimestamp = CombineDateAndTime(request.NewDate, timePart);
            _db.BookedSlots.Add(new BookedSlotEntity
            {
                Id = slotId,
                BarberId = appointment.BarberId,
                Date = request.NewDate,
                Time = timePart,
                AppointmentId = appointmentId,
                StartTimestamp = subSlotTimestamp,
                IsBlockedByBarber = false,
                CreatedAt = utcNow
            });
        }

        appointment.Date = request.NewDate;
        appointment.StartTime = request.NewStartTime;
        appointment.EndTime = request.NewEndTime;
        appointment.SlotIdsJson = JsonHelper.Serialize(newSlotIds);
        appointment.StartTimestamp = newStartTimestamp;
        appointment.EndTimestamp = newEndTimestamp;
        appointment.UpdatedAt = utcNow;

        await _db.SaveChangesAsync();
        await transaction.CommitAsync();

        return Ok(appointment.ToFlutterMap());
    }
}

// CreBy: MenBoyBMN

