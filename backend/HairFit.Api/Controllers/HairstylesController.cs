using HairFit.Api.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace HairFit.Api.Controllers;

[ApiController]
[Route("api/hairstyles")]
public class HairstylesController : ControllerBase
{
    private readonly AppDbContext _db;

    public HairstylesController(AppDbContext db)
    {
        _db = db;
    }

    /// <summary>
    /// Lấy danh sách các kiểu tóc đang hoạt động (active == true)
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> GetActiveHairstyles()
    {
        var list = await _db.Hairstyles
            .AsNoTracking()
            .Where(h => h.Active)
            .ToListAsync();

        return Ok(list.Select(h => h.ToFlutterMap()).ToList());
    }
}

// CreBy: MenBoyBMN

