using System.ComponentModel.DataAnnotations;
using System.Text.Json;

namespace HairFit.Api.Models;

public class UserEntity
{
    [Key]
    [MaxLength(128)]
    public string Uid { get; set; } = string.Empty;

    [MaxLength(256)]
    public string Email { get; set; } = string.Empty;

    [MaxLength(256)]
    public string DisplayName { get; set; } = string.Empty;

    public string AvatarUrl { get; set; } = string.Empty;

    [MaxLength(32)]
    public string Role { get; set; } = "customer";

    public bool IsBlocked { get; set; }

    [MaxLength(32)]
    public string? Phone { get; set; }

    [MaxLength(64)]
    public string? SavedFaceShape { get; set; }

    public string SavedHairstyleIdsJson { get; set; } = "[]";

    public string FavoriteBarberIdsJson { get; set; } = "[]";

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    public Dictionary<string, object?> ToFlutterMap()
    {
        return new Dictionary<string, object?>
        {
            ["uid"] = Uid,
            ["email"] = Email,
            ["displayName"] = DisplayName,
            ["avatarUrl"] = AvatarUrl,
            ["role"] = Role,
            ["isBlocked"] = IsBlocked,
            ["phone"] = Phone,
            ["savedFaceShape"] = SavedFaceShape,
            ["savedHairstyleIds"] = JsonHelper.DeserializeList<string>(SavedHairstyleIdsJson),
            ["favoriteBarberIds"] = JsonHelper.DeserializeList<string>(FavoriteBarberIdsJson),
            ["createdAt"] = JsonHelper.ToUtcIso(CreatedAt),
            ["updatedAt"] = JsonHelper.ToUtcIso(UpdatedAt)
        };
    }
}

public class BarberProfileEntity
{
    [Key]
    [MaxLength(128)]
    public string Uid { get; set; } = string.Empty;

    [MaxLength(256)]
    public string DisplayName { get; set; } = string.Empty;

    public string AvatarUrl { get; set; } = string.Empty;

    public string CoverUrl { get; set; } = string.Empty;

    public string Bio { get; set; } = string.Empty;

    [MaxLength(512)]
    public string Address { get; set; } = string.Empty;

    public double Latitude { get; set; } = 16.0544;

    public double Longitude { get; set; } = 108.2022;

    [MaxLength(32)]
    public string? Phone { get; set; }

    public string PortfolioUrlsJson { get; set; } = "[]";

    public bool IsAcceptingBookingsToday { get; set; } = true;

    public int PriceMin { get; set; }

    public int PriceMax { get; set; }

    public double RatingAvg { get; set; } = 5.0;

    public int RatingCount { get; set; }

    [MaxLength(32)]
    public string ApprovalStatus { get; set; } = "pending";

    public string HairstyleIdsJson { get; set; } = "[]";

    public string ServicesJson { get; set; } = "[]";

    public string WorkingHoursJson { get; set; } = "{}";

    public string ExceptionsJson { get; set; } = "[]";

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    public Dictionary<string, object?> ToFlutterMap()
    {
        return new Dictionary<string, object?>
        {
            ["uid"] = Uid,
            ["displayName"] = DisplayName,
            ["avatarUrl"] = AvatarUrl,
            ["coverUrl"] = CoverUrl,
            ["bio"] = Bio,
            ["address"] = Address,
            ["location"] = new Dictionary<string, double>
            {
                ["latitude"] = Latitude,
                ["longitude"] = Longitude
            },
            ["phone"] = Phone,
            ["portfolioUrls"] = JsonHelper.DeserializeList<string>(PortfolioUrlsJson),
            ["isAcceptingBookingsToday"] = IsAcceptingBookingsToday,
            ["priceMin"] = PriceMin,
            ["priceMax"] = PriceMax,
            ["ratingAvg"] = RatingAvg,
            ["ratingCount"] = RatingCount,
            ["approvalStatus"] = ApprovalStatus,
            ["hairstyleIds"] = JsonHelper.DeserializeList<string>(HairstyleIdsJson),
            ["services"] = JsonHelper.DeserializeRawElement(ServicesJson, "[]"),
            ["workingHours"] = JsonHelper.DeserializeRawElement(WorkingHoursJson, "{}"),
            ["exceptions"] = JsonHelper.DeserializeRawElement(ExceptionsJson, "[]"),
            ["createdAt"] = JsonHelper.ToUtcIso(CreatedAt),
            ["updatedAt"] = JsonHelper.ToUtcIso(UpdatedAt)
        };
    }
}

public class AppointmentEntity
{
    [Key]
    [MaxLength(128)]
    public string Id { get; set; } = string.Empty;

    [MaxLength(128)]
    public string CustomerId { get; set; } = string.Empty;

    [MaxLength(256)]
    public string CustomerName { get; set; } = string.Empty;

    [MaxLength(128)]
    public string BarberId { get; set; } = string.Empty;

    [MaxLength(256)]
    public string BarberName { get; set; } = string.Empty;

    [MaxLength(128)]
    public string ServiceId { get; set; } = string.Empty;

    [MaxLength(256)]
    public string ServiceName { get; set; } = string.Empty;

    public int Price { get; set; }

    public int DurationMinutes { get; set; } = 30;

    [MaxLength(16)]
    public string Date { get; set; } = string.Empty;

    [MaxLength(16)]
    public string StartTime { get; set; } = string.Empty;

    [MaxLength(16)]
    public string EndTime { get; set; } = string.Empty;

    public DateTime StartTimestamp { get; set; }

    public DateTime EndTimestamp { get; set; }

    [MaxLength(64)]
    public string Timezone { get; set; } = "Asia/Ho_Chi_Minh";

    public string SlotIdsJson { get; set; } = "[]";

    [MaxLength(128)]
    public string HairstyleId { get; set; } = string.Empty;

    [MaxLength(64)]
    public string? CustomerFaceShape { get; set; }

    public string? AiStylingTip { get; set; }

    public string? HairstyleImageUrl { get; set; }

    public string? BarberPrivateNote { get; set; }

    [MaxLength(32)]
    public string? CustomerPhone { get; set; }

    [MaxLength(32)]
    public string? BarberPhone { get; set; }

    public string Note { get; set; } = string.Empty;

    public string? RejectReason { get; set; }

    [MaxLength(32)]
    public string Status { get; set; } = "pending";

    public int? Rating { get; set; }

    public string? ReviewComment { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    public Dictionary<string, object?> ToFlutterMap()
    {
        return new Dictionary<string, object?>
        {
            ["id"] = Id,
            ["customerId"] = CustomerId,
            ["customerName"] = CustomerName,
            ["barberId"] = BarberId,
            ["barberName"] = BarberName,
            ["serviceId"] = ServiceId,
            ["serviceName"] = ServiceName,
            ["price"] = Price,
            ["durationMinutes"] = DurationMinutes,
            ["date"] = Date,
            ["startTime"] = StartTime,
            ["endTime"] = EndTime,
            ["startTimestamp"] = StartTimestamp.ToString("O"),
            ["endTimestamp"] = EndTimestamp.ToString("O"),
            ["timezone"] = Timezone,
            ["slotIds"] = JsonHelper.DeserializeList<string>(SlotIdsJson),
            ["hairstyleId"] = HairstyleId,
            ["customerFaceShape"] = CustomerFaceShape,
            ["aiStylingTip"] = AiStylingTip,
            ["hairstyleImageUrl"] = HairstyleImageUrl,
            ["barberPrivateNote"] = BarberPrivateNote,
            ["customerPhone"] = CustomerPhone,
            ["barberPhone"] = BarberPhone,
            ["note"] = Note,
            ["rejectReason"] = RejectReason,
            ["status"] = Status,
            ["rating"] = Rating,
            ["reviewComment"] = ReviewComment,
            ["createdAt"] = JsonHelper.ToUtcIso(CreatedAt),
            ["updatedAt"] = JsonHelper.ToUtcIso(UpdatedAt)
        };
    }
}

public class BookedSlotEntity
{
    [Key]
    [MaxLength(256)]
    public string Id { get; set; } = string.Empty;

    [MaxLength(128)]
    public string BarberId { get; set; } = string.Empty;

    [MaxLength(16)]
    public string Date { get; set; } = string.Empty;

    [MaxLength(16)]
    public string Time { get; set; } = string.Empty;

    [MaxLength(128)]
    public string AppointmentId { get; set; } = string.Empty;

    public DateTime StartTimestamp { get; set; }

    public bool IsBlockedByBarber { get; set; }

    public string? BlockReason { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public Dictionary<string, object?> ToFlutterMap()
    {
        return new Dictionary<string, object?>
        {
            ["id"] = Id,
            ["barberId"] = BarberId,
            ["date"] = Date,
            ["time"] = Time,
            ["appointmentId"] = AppointmentId,
            ["startTimestamp"] = StartTimestamp.ToString("O"),
            ["isBlockedByBarber"] = IsBlockedByBarber,
            ["blockReason"] = BlockReason,
            ["createdAt"] = JsonHelper.ToUtcIso(CreatedAt)
        };
    }
}

public class ReviewEntity
{
    [Key]
    [MaxLength(128)]
    public string Id { get; set; } = string.Empty;

    [MaxLength(128)]
    public string AppointmentId { get; set; } = string.Empty;

    [MaxLength(128)]
    public string BarberId { get; set; } = string.Empty;

    [MaxLength(128)]
    public string CustomerId { get; set; } = string.Empty;

    [MaxLength(256)]
    public string CustomerName { get; set; } = "Khách hàng";

    public int Rating { get; set; } = 5;

    public string ReviewComment { get; set; } = string.Empty;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public Dictionary<string, object?> ToFlutterMap()
    {
        return new Dictionary<string, object?>
        {
            ["id"] = Id,
            ["appointmentId"] = AppointmentId,
            ["barberId"] = BarberId,
            ["customerId"] = CustomerId,
            ["customerName"] = CustomerName,
            ["rating"] = Rating,
            ["reviewComment"] = ReviewComment,
            ["createdAt"] = JsonHelper.ToUtcIso(CreatedAt)
        };
    }
}

public class HairstyleEntity
{
    [Key]
    [MaxLength(128)]
    public string Id { get; set; } = string.Empty;

    [MaxLength(256)]
    public string Name { get; set; } = string.Empty;

    public string Description { get; set; } = string.Empty;

    public string ImageUrl { get; set; } = string.Empty;

    public string ImageUrlsJson { get; set; } = "[]";

    public string FaceShapesJson { get; set; } = "[]";

    public string TagsJson { get; set; } = "[]";

    public bool Active { get; set; } = true;

    public Dictionary<string, object?> ToFlutterMap()
    {
        return new Dictionary<string, object?>
        {
            ["id"] = Id,
            ["name"] = Name,
            ["description"] = Description,
            ["imageUrl"] = ImageUrl,
            ["imageUrls"] = JsonHelper.DeserializeList<string>(ImageUrlsJson),
            ["faceShapes"] = JsonHelper.DeserializeList<string>(FaceShapesJson),
            ["tags"] = JsonHelper.DeserializeList<string>(TagsJson),
            ["active"] = Active
        };
    }
}

public class SystemSettingEntity
{
    [Key]
    [MaxLength(64)]
    public string Key { get; set; } = "global";

    public double SearchRadiusKm { get; set; } = 10.0;

    public int CancelNoticeHours { get; set; } = 1;

    public bool MaintenanceMode { get; set; }

    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    public Dictionary<string, object?> ToFlutterMap()
    {
        return new Dictionary<string, object?>
        {
            ["searchRadiusKm"] = SearchRadiusKm,
            ["cancelNoticeHours"] = CancelNoticeHours,
            ["maintenanceMode"] = MaintenanceMode,
            ["updatedAt"] = JsonHelper.ToUtcIso(UpdatedAt)
        };
    }
}

public static class JsonHelper
{
    public static List<T> DeserializeList<T>(string? json)
    {
        if (string.IsNullOrWhiteSpace(json)) return new List<T>();
        try
        {
            return JsonSerializer.Deserialize<List<T>>(json) ?? new List<T>();
        }
        catch
        {
            return new List<T>();
        }
    }

    public static object DeserializeRawElement(string? json, string fallbackJson)
    {
        var raw = string.IsNullOrWhiteSpace(json) ? fallbackJson : json;
        try
        {
            return JsonSerializer.Deserialize<JsonElement>(raw);
        }
        catch
        {
            return JsonSerializer.Deserialize<JsonElement>(fallbackJson);
        }
    }

    public static string Serialize<T>(T value)
    {
        return JsonSerializer.Serialize(value);
    }

    public static string ToUtcIso(DateTime dt)
    {
        return DateTime.SpecifyKind(dt, DateTimeKind.Utc).ToString("O");
    }
}

// CreBy: MenBoyBMN

