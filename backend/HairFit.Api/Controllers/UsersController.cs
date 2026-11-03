using HairFit.Api.Data;
using HairFit.Api.DTOs;
using HairFit.Api.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace HairFit.Api.Controllers;

[ApiController]
[Route("api/users")]
public class UsersController : ControllerBase
{
    private readonly AppDbContext _db;

    public UsersController(AppDbContext db)
    {
        _db = db;
    }

    /// <summary>
    /// Đồng bộ hoặc khởi tạo User sau khi đăng ký / đăng nhập qua Firebase Auth
    /// </summary>
    [HttpPost("sync")]
    public async Task<IActionResult> SyncUser([FromBody] SyncUserRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Uid))
        {
            return BadRequest(new { code = "INVALID_UID", message = "UID không hợp lệ." });
        }

        var user = await _db.Users.FindAsync(request.Uid);
        if (user == null)
        {
            var now = DateTime.UtcNow;
            user = new UserEntity
            {
                Uid = request.Uid.Trim(),
                Email = request.Email.Trim(),
                DisplayName = string.IsNullOrWhiteSpace(request.DisplayName)
                    ? request.Email.Split('@').FirstOrDefault() ?? "Người dùng"
                    : request.DisplayName.Trim(),
                AvatarUrl = request.AvatarUrl?.Trim() ?? string.Empty,
                Role = string.IsNullOrWhiteSpace(request.Role) ? "customer" : request.Role.Trim().ToLowerInvariant(),
                IsBlocked = false,
                Phone = request.Phone?.Trim(),
                CreatedAt = now,
                UpdatedAt = now
            };
            _db.Users.Add(user);
            await _db.SaveChangesAsync();
        }
        else if (!string.IsNullOrWhiteSpace(request.Role) && request.Role != user.Role && user.CreatedAt > DateTime.UtcNow.AddMinutes(-1))
        {
            // Trường hợp vừa đăng ký mới với role cụ thể (vd: barber)
            user.Role = request.Role.Trim().ToLowerInvariant();
            if (!string.IsNullOrWhiteSpace(request.DisplayName))
            {
                user.DisplayName = request.DisplayName.Trim();
            }
            user.UpdatedAt = DateTime.UtcNow;
            await _db.SaveChangesAsync();
        }

        if (user.IsBlocked)
        {
            return StatusCode(403, new
            {
                code = "BLOCKED_ACCOUNT",
                message = "Tài khoản của bạn đã bị khóa. Vui lòng liên hệ quản trị viên."
            });
        }

        return Ok(user.ToFlutterMap());
    }

    /// <summary>
    /// Lấy thông tin User theo UID
    /// </summary>
    [HttpGet("{uid}")]
    public async Task<IActionResult> GetUser(string uid)
    {
        var user = await _db.Users.AsNoTracking().FirstOrDefaultAsync(u => u.Uid == uid);
        if (user == null)
        {
            return NotFound(new { code = "USER_NOT_FOUND", message = "Không tìm thấy người dùng." });
        }

        if (user.IsBlocked)
        {
            return StatusCode(403, new
            {
                code = "BLOCKED_ACCOUNT",
                message = "Tài khoản của bạn đã bị khóa. Vui lòng liên hệ quản trị viên."
            });
        }

        return Ok(user.ToFlutterMap());
    }

    /// <summary>
    /// Cập nhật hồ sơ người dùng (displayName, avatarUrl) và đồng bộ sang BarberProfiles nếu có
    /// </summary>
    [HttpPut("{uid}/profile")]
    public async Task<IActionResult> UpdateProfile(string uid, [FromBody] UpdateUserProfileRequest request)
    {
        var user = await _db.Users.FindAsync(uid);
        if (user == null)
        {
            return NotFound(new { code = "USER_NOT_FOUND", message = "Không tìm thấy người dùng." });
        }

        user.DisplayName = request.DisplayName.Trim();
        if (request.AvatarUrl != null)
        {
            user.AvatarUrl = request.AvatarUrl.Trim();
        }
        user.UpdatedAt = DateTime.UtcNow;

        var barber = await _db.BarberProfiles.FindAsync(uid);
        if (barber != null)
        {
            if (!string.IsNullOrWhiteSpace(request.DisplayName))
            {
                barber.DisplayName = request.DisplayName.Trim();
            }
            if (request.AvatarUrl != null)
            {
                barber.AvatarUrl = request.AvatarUrl.Trim();
            }
            barber.UpdatedAt = DateTime.UtcNow;
        }

        await _db.SaveChangesAsync();
        return Ok(user.ToFlutterMap());
    }

    /// <summary>
    /// Lưu dáng khuôn mặt AI của khách hàng
    /// </summary>
    [HttpPut("{uid}/face-shape")]
    public async Task<IActionResult> SaveFaceShape(string uid, [FromBody] SaveFaceShapeRequest request)
    {
        var user = await _db.Users.FindAsync(uid);
        if (user == null)
        {
            return NotFound(new { code = "USER_NOT_FOUND", message = "Không tìm thấy người dùng." });
        }

        user.SavedFaceShape = request.FaceShape.Trim();
        user.UpdatedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();

        return Ok(user.ToFlutterMap());
    }

    /// <summary>
    /// Thêm hoặc bỏ thợ cắt tóc khỏi danh sách yêu thích
    /// </summary>
    [HttpPost("{uid}/favorites/toggle")]
    public async Task<IActionResult> ToggleFavoriteBarber(string uid, [FromBody] ToggleFavoriteRequest request)
    {
        var user = await _db.Users.FindAsync(uid);
        if (user == null)
        {
            return NotFound(new { code = "USER_NOT_FOUND", message = "Không tìm thấy người dùng." });
        }

        var favorites = JsonHelper.DeserializeList<string>(user.FavoriteBarberIdsJson);
        if (favorites.Contains(request.BarberId))
        {
            favorites.Remove(request.BarberId);
        }
        else
        {
            favorites.Add(request.BarberId);
        }

        user.FavoriteBarberIdsJson = JsonHelper.Serialize(favorites);
        user.UpdatedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();

        return Ok(new { favoriteBarberIds = favorites });
    }
}

// CreBy: MenBoyBMN

