using HairFit.Api.Data;
using HairFit.Api.DTOs;
using Microsoft.AspNetCore.Mvc;

namespace HairFit.Api.Controllers;

[ApiController]
[Route("api/seed")]
public class SeedController : ControllerBase
{
    private readonly AppDbContext _db;

    public SeedController(AppDbContext db)
    {
        _db = db;
    }

    [HttpPost("hairstyles")]
    public async Task<IActionResult> SeedHairstyles([FromBody] SeedOptionsRequest? request)
    {
        await DbInitializer.SeedHairstylesAsync(_db, request?.Overwrite ?? false);
        return Ok(new { message = "Đã nạp danh mục kiểu tóc mẫu thành công." });
    }

    [HttpPost("barbers")]
    public async Task<IActionResult> SeedBarbers([FromBody] SeedOptionsRequest? request)
    {
        await DbInitializer.SeedBarbersAsync(_db, request?.Overwrite ?? false);
        return Ok(new { message = "Đã nạp 5 hồ sơ thợ mẫu thành công." });
    }

    [HttpPost("all")]
    public async Task<IActionResult> SeedAll([FromBody] SeedOptionsRequest? request)
    {
        var overwrite = request?.Overwrite ?? false;
        await DbInitializer.SeedHairstylesAsync(_db, overwrite);
        await DbInitializer.SeedBarbersAsync(_db, overwrite);
        return Ok(new { message = "Đã nạp toàn bộ dữ liệu Seed Data thành công." });
    }

    [HttpDelete("barbers")]
    public async Task<IActionResult> ClearSampleBarbers()
    {
        await DbInitializer.ClearSampleBarbersAsync(_db);
        return Ok(new { message = "Đã xoá 5 thợ mẫu Seed Data." });
    }

    [HttpPost("appointments")]
    public async Task<IActionResult> SeedSampleAppointments()
    {
        await DbInitializer.SeedSampleAppointmentsAsync(_db);
        return Ok(new { message = "Đã nạp lịch hẹn mẫu hôm nay." });
    }

    [HttpDelete("appointments")]
    public async Task<IActionResult> ClearSampleAppointments()
    {
        await DbInitializer.ClearSampleAppointmentsAsync(_db);
        return Ok(new { message = "Đã xoá lịch hẹn mẫu thử nghiệm." });
    }
}

// CreBy: MenBoyBMN

