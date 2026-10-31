namespace HairFit.Api.DTOs;

public record SyncUserRequest(
    string Uid = "",
    string Email = "",
    string DisplayName = "",
    string? Role = null,
    string? AvatarUrl = null,
    string? Phone = null
);

public record UpdateUserProfileRequest(
    string DisplayName = "",
    string? AvatarUrl = null
);

public record SaveFaceShapeRequest(
    string FaceShape = ""
);

public record ToggleFavoriteRequest(
    string BarberId = ""
);

public record UpdateAcceptingBookingsRequest(
    bool IsAccepting = true
);

public record UpdateApprovalStatusRequest(
    string Status = "pending"
);

public record BlockSlotsRequest(
    string BarberId = "",
    string Date = "",
    List<string>? Times = null,
    string? Reason = null
);

public record CreateBookingRequest(
    string CustomerId = "",
    string CustomerName = "",
    string BarberId = "",
    string BarberName = "",
    string ServiceId = "",
    string ServiceName = "",
    int Price = 0,
    int DurationMinutes = 30,
    string Date = "",
    string StartTime = "",
    string EndTime = "",
    List<string>? SlotIds = null,
    string? HairstyleId = null,
    string? CustomerFaceShape = null,
    string? AiStylingTip = null,
    string? HairstyleImageUrl = null,
    string? CustomerPhone = null,
    string? BarberPhone = null,
    string? Note = null,
    string? CurrentTime = null
);

public record CancelBookingRequest(
    string CancelledByUid = "",
    string? CurrentTime = null
);

public record RescheduleBookingRequest(
    string NewDate = "",
    string NewStartTime = "",
    string NewEndTime = "",
    List<string>? NewSlotIds = null
);

public record RejectAppointmentRequest(
    string? Reason = null
);

public record RateAppointmentRequest(
    string BarberId = "",
    int Rating = 5,
    string? CustomerId = null,
    string? CustomerName = null,
    string? Comment = null
);

public record UpdatePrivateNoteRequest(
    string? Note = null
);

public record SetUserBlockStatusRequest(
    bool IsBlocked = false
);

public record UpdateUserRoleRequest(
    string NewRole = "customer"
);

public record UpdateUserInfoAdminRequest(
    string DisplayName = "",
    string? Phone = null
);

public record UpdateBarberLocationRequest(
    double Latitude = 16.0544,
    double Longitude = 108.2022
);

public record UpdateBarberProfileAdminRequest(
    string DisplayName = "",
    string Address = "",
    string? Phone = null,
    string Bio = "",
    double Latitude = 16.0544,
    double Longitude = 108.2022,
    bool IsAcceptingBookingsToday = true
);

public record UpdateAppointmentStatusAdminRequest(
    string NewStatus = "pending",
    string? Reason = null
);

public record SaveSystemSettingsRequest(
    double SearchRadiusKm = 10.0,
    int CancelNoticeHours = 1,
    bool MaintenanceMode = false
);

public record SeedOptionsRequest(
    bool Overwrite = false
);

// CreBy: MenBoyBMN
