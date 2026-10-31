using HairFit.Api.Data;
using HairFit.Api.DTOs;
using HairFit.Api.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace HairFit.Api.Controllers;

[ApiController]
[Route("api/appointments")]
public class AppointmentsController : ControllerBase
{
    private readonly AppDbContext _db;

    public AppointmentsController(AppDbContext db)
    {
        _db = db;
    }

    /// <summary>
    /// Lấy danh sách lịch hẹn của khách hàng (sắp xếp theo startTimestamp mới nhất lên đầu)
    /// </summary>
    [HttpGet("customer/{customerId}")]
    public async Task<IActionResult> GetCustomerAppointments(string customerId)
    {
        var list = await _db.Appointments
            .AsNoTracking()
            .Where(a => a.CustomerId == customerId)
            .OrderByDescending(a => a.StartTimestamp)
            .ToListAsync();

        return Ok(list.Select(a => a.ToFlutterMap()).ToList());
    }

    /// <summary>
    /// Lấy danh sách lịch hẹn của thợ cắt tóc (sắp xếp theo startTimestamp giảm dần)
    /// </summary>
    [HttpGet("barber/{barberId}")]
    public async Task<IActionResult> GetBarberAppointments(string barberId)
    {
        var list = await _db.Appointments
            .AsNoTracking()
            .Where(a => a.BarberId == barberId)
            .OrderByDescending(a => a.StartTimestamp)
            .ToListAsync();

        return Ok(list.Select(a => a.ToFlutterMap()).ToList());
    }

    /// <summary>
    /// Lấy thông tin chi tiết một lịch hẹn bằng ID
    /// </summary>
    [HttpGet("{appointmentId}")]
    public async Task<IActionResult> GetAppointmentById(string appointmentId)
    {
        var appointment = await _db.Appointments
            .AsNoTracking()
            .FirstOrDefaultAsync(a => a.Id == appointmentId);

        if (appointment == null)
        {
            return NotFound(new { code = "APPOINTMENT_NOT_FOUND", message = "Lịch hẹn không tồn tại" });
        }

        return Ok(appointment.ToFlutterMap());
    }

    /// <summary>
    /// Thợ xác nhận tiếp nhận lịch hẹn (pending -> confirmed)
    /// </summary>
    [HttpPost("{appointmentId}/confirm")]
    public async Task<IActionResult> ConfirmAppointment(string appointmentId)
    {
        var appointment = await _db.Appointments.FindAsync(appointmentId);
        if (appointment == null)
        {
            return NotFound(new { code = "BOOKING_ERROR", message = "Lịch hẹn không tồn tại" });
        }

        if (appointment.Status != "pending")
        {
            return BadRequest(new
            {
                code = "BOOKING_ERROR",
                message = "Chỉ có thể xác nhận lịch hẹn ở trạng thái chờ duyệt"
            });
        }

        appointment.Status = "confirmed";
        appointment.UpdatedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();

        return Ok(appointment.ToFlutterMap());
    }

    /// <summary>
    /// Thợ từ chối lịch hẹn (pending -> rejected) và xóa BookedSlots để giải phóng khung giờ
    /// </summary>
    [HttpPost("{appointmentId}/reject")]
    public async Task<IActionResult> RejectAppointment(
        string appointmentId,
        [FromBody] RejectAppointmentRequest? request)
    {
        await using var transaction = await _db.Database.BeginTransactionAsync();
        var appointment = await _db.Appointments.FindAsync(appointmentId);
        if (appointment == null)
        {
            return NotFound(new { code = "BOOKING_ERROR", message = "Lịch hẹn không tồn tại" });
        }

        if (appointment.Status != "pending")
        {
            return BadRequest(new
            {
                code = "BOOKING_ERROR",
                message = "Chỉ có thể từ chối lịch hẹn ở trạng thái chờ duyệt"
            });
        }

        appointment.Status = "rejected";
        if (!string.IsNullOrWhiteSpace(request?.Reason))
        {
            var cleanReason = request.Reason.Trim();
            appointment.RejectReason = cleanReason;
            appointment.Note = string.IsNullOrWhiteSpace(appointment.Note)
                ? $"[Lý do từ chối: {cleanReason}]"
                : $"{appointment.Note} [Lý do từ chối: {cleanReason}]";
        }
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

        return Ok(appointment.ToFlutterMap());
    }

    /// <summary>
    /// Thợ hoàn tất dịch vụ cắt tóc (confirmed -> completed)
    /// </summary>
    [HttpPost("{appointmentId}/complete")]
    public async Task<IActionResult> CompleteAppointment(string appointmentId)
    {
        var appointment = await _db.Appointments.FindAsync(appointmentId);
        if (appointment == null)
        {
            return NotFound(new { code = "BOOKING_ERROR", message = "Lịch hẹn không tồn tại" });
        }

        if (appointment.Status != "confirmed")
        {
            return BadRequest(new
            {
                code = "BOOKING_ERROR",
                message = "Chỉ có thể hoàn tất lịch hẹn đã được xác nhận"
            });
        }

        appointment.Status = "completed";
        appointment.UpdatedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();

        return Ok(appointment.ToFlutterMap());
    }

    /// <summary>
    /// Khách hàng đánh giá lịch hẹn và cập nhật điểm trung bình của thợ
    /// </summary>
    [HttpPost("{appointmentId}/rate")]
    public async Task<IActionResult> RateAppointment(
        string appointmentId,
        [FromBody] RateAppointmentRequest request)
    {
        await using var transaction = await _db.Database.BeginTransactionAsync();
        var appointment = await _db.Appointments.FindAsync(appointmentId);
        if (appointment != null)
        {
            appointment.Rating = request.Rating;
            appointment.ReviewComment = request.Comment;
            appointment.UpdatedAt = DateTime.UtcNow;
        }

        var review = new ReviewEntity
        {
            Id = Guid.NewGuid().ToString("N")[..20],
            AppointmentId = appointmentId,
            BarberId = request.BarberId,
            CustomerId = request.CustomerId ?? string.Empty,
            CustomerName = string.IsNullOrWhiteSpace(request.CustomerName) ? "Khách hàng" : request.CustomerName,
            Rating = request.Rating,
            ReviewComment = request.Comment ?? string.Empty,
            CreatedAt = DateTime.UtcNow
        };
        _db.Reviews.Add(review);

        var barber = await _db.BarberProfiles.FindAsync(request.BarberId);
        if (barber != null)
        {
            var currentAvg = barber.RatingAvg > 0 ? barber.RatingAvg : 5.0;
            var currentCount = barber.RatingCount;
            var newCount = currentCount + 1;
            var newAvg = ((currentAvg * currentCount) + request.Rating) / newCount;
            barber.RatingAvg = Math.Round(newAvg, 1);
            barber.RatingCount = newCount;
            barber.UpdatedAt = DateTime.UtcNow;
        }

        await _db.SaveChangesAsync();
        await transaction.CommitAsync();

        return Ok(new { message = "Đã ghi nhận đánh giá thành công!" });
    }

    /// <summary>
    /// Thợ cập nhật ghi chú riêng tư về khách hàng này (Client Notes / Mini CRM)
    /// </summary>
    [HttpPatch("{appointmentId}/private-note")]
    public async Task<IActionResult> UpdateBarberPrivateNote(
        string appointmentId,
        [FromBody] UpdatePrivateNoteRequest request)
    {
        var appointment = await _db.Appointments.FindAsync(appointmentId);
        if (appointment == null)
        {
            return NotFound(new { code = "BOOKING_ERROR", message = "Lịch hẹn không tồn tại" });
        }

        var cleanNote = request.Note?.Trim() ?? string.Empty;
        appointment.BarberPrivateNote = string.IsNullOrEmpty(cleanNote) ? null : cleanNote;
        appointment.UpdatedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();

        return Ok(appointment.ToFlutterMap());
    }
}

// CreBy: MenBoyBMN

