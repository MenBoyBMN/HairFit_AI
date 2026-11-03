using System.Text.Json;
using HairFit.Api.Controllers;
using HairFit.Api.Data;
using HairFit.Api.DTOs;
using HairFit.Api.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Xunit;

namespace HairFit.Api.Tests;

public class ApiIntegrationTests
{
    private AppDbContext CreateInMemoryDbContext()
    {
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .ConfigureWarnings(w => w.Ignore(Microsoft.EntityFrameworkCore.Diagnostics.InMemoryEventId.TransactionIgnoredWarning))
            .Options;

        var context = new AppDbContext(options);
        return context;
    }

    [Fact]
    public async Task UsersController_SyncAndProfileFlow_WorksAsExpected()
    {
        using var db = CreateInMemoryDbContext();
        var controller = new UsersController(db);

        // 1. Sync User
        var syncResult = await controller.SyncUser(new SyncUserRequest(
            Uid: "user_test_1",
            Email: "user1@test.com",
            DisplayName: "User One",
            Role: "customer"
        ));

        var okObj = Assert.IsType<OkObjectResult>(syncResult);
        var map = Assert.IsAssignableFrom<Dictionary<string, object?>>(okObj.Value);
        Assert.Equal("user_test_1", map["uid"]);
        Assert.Equal("customer", map["role"]);

        // 2. Update Profile
        var updateResult = await controller.UpdateProfile("user_test_1", new UpdateUserProfileRequest(
            DisplayName: "User One Updated",
            AvatarUrl: "https://example.com/avatar.jpg"
        ));
        var updateOk = Assert.IsType<OkObjectResult>(updateResult);
        var updatedMap = Assert.IsAssignableFrom<Dictionary<string, object?>>(updateOk.Value);
        Assert.Equal("User One Updated", updatedMap["displayName"]);
        Assert.Equal("https://example.com/avatar.jpg", updatedMap["avatarUrl"]);

        // 3. Save Face Shape
        var faceResult = await controller.SaveFaceShape("user_test_1", new SaveFaceShapeRequest("oval"));
        Assert.IsType<OkObjectResult>(faceResult);

        // 4. Toggle Favorite
        var favResult = await controller.ToggleFavoriteBarber("user_test_1", new ToggleFavoriteRequest("barber_99"));
        Assert.IsType<OkObjectResult>(favResult);

        // 5. Block check
        var user = await db.Users.FindAsync("user_test_1");
        Assert.NotNull(user);
        user!.IsBlocked = true;
        await db.SaveChangesAsync();

        var blockedResult = await controller.GetUser("user_test_1");
        var statusResult = Assert.IsType<ObjectResult>(blockedResult);
        Assert.Equal(403, statusResult.StatusCode);
    }

    [Fact]
    public async Task BarbersController_ProfileAndStatusFlow_WorksAsExpected()
    {
        using var db = CreateInMemoryDbContext();
        var controller = new BarbersController(db);

        // Seed 5 sample barbers
        await DbInitializer.SeedBarbersAsync(db, overwrite: true);

        // 1. Get approved barbers
        var approvedResult = await controller.GetApprovedBarbers();
        var approvedOk = Assert.IsType<OkObjectResult>(approvedResult);
        var list = Assert.IsAssignableFrom<List<Dictionary<string, object?>>>(approvedOk.Value);
        Assert.Equal(5, list.Count);

        // 2. Toggle accepting bookings today
        var firstUid = list.First()["uid"]!.ToString()!;
        var patchAcc = await controller.UpdateAcceptingBookingsToday(firstUid, new UpdateAcceptingBookingsRequest(false));
        Assert.IsType<OkObjectResult>(patchAcc);

        var barber = await db.BarberProfiles.FindAsync(firstUid);
        Assert.NotNull(barber);
        Assert.False(barber!.IsAcceptingBookingsToday);

        // 3. Suspend barber
        var patchStatus = await controller.UpdateApprovalStatus(firstUid, new UpdateApprovalStatusRequest("suspended"));
        Assert.IsType<OkObjectResult>(patchStatus);
        Assert.Equal("suspended", barber.ApprovalStatus);
        Assert.False(barber.IsAcceptingBookingsToday);
    }

    [Fact]
    public async Task BookingsController_AtomicBookingAndConflict_WorksAsExpected()
    {
        using var db = CreateInMemoryDbContext();
        var controller = new BookingsController(db);

        var futureDate = DateTime.Now.AddDays(3).ToString("yyyy-MM-dd");
        var slotId = $"barber_01_{futureDate}_09-00";

        // 1. Create booking
        var result = await controller.CreateBooking(new CreateBookingRequest(
            CustomerId: "cust_1",
            CustomerName: "Customer One",
            BarberId: "barber_01",
            BarberName: "Barber Studio",
            ServiceId: "svc_01",
            ServiceName: "Cắt tóc",
            Price: 80000,
            DurationMinutes: 30,
            Date: futureDate,
            StartTime: "09:00",
            EndTime: "09:30",
            SlotIds: new List<string> { slotId }
        ));

        var okObj = Assert.IsType<OkObjectResult>(result);
        var doc = JsonDocument.Parse(JsonSerializer.Serialize(okObj.Value));
        var appointmentId = doc.RootElement.GetProperty("appointmentId").GetString();
        Assert.False(string.IsNullOrEmpty(appointmentId));

        // Slot should be booked
        var slot = await db.BookedSlots.FindAsync(slotId);
        Assert.NotNull(slot);
        Assert.Equal(appointmentId, slot!.AppointmentId);

        // 2. Attempt duplicate booking for same slot -> 409 Conflict
        var dupResult = await controller.CreateBooking(new CreateBookingRequest(
            CustomerId: "cust_2",
            CustomerName: "Customer Two",
            BarberId: "barber_01",
            BarberName: "Barber Studio",
            ServiceId: "svc_01",
            ServiceName: "Cắt tóc",
            Price: 80000,
            DurationMinutes: 30,
            Date: futureDate,
            StartTime: "09:00",
            EndTime: "09:30",
            SlotIds: new List<string> { slotId }
        ));

        var conflict = Assert.IsType<ConflictObjectResult>(dupResult);
        Assert.Equal(409, conflict.StatusCode);

        // 3. Cancel booking -> releases slot
        var cancelResult = await controller.CancelBooking(appointmentId!, new CancelBookingRequest(CancelledByUid: "cust_1"));
        Assert.IsType<OkObjectResult>(cancelResult);

        var slotAfterCancel = await db.BookedSlots.FindAsync(slotId);
        Assert.Null(slotAfterCancel);

        var appAfterCancel = await db.Appointments.FindAsync(appointmentId!);
        Assert.Equal("cancelled", appAfterCancel!.Status);
    }

    [Fact]
    public async Task AppointmentsController_LifecycleAndRating_WorksAsExpected()
    {
        using var db = CreateInMemoryDbContext();
        var appointmentsCtrl = new AppointmentsController(db);

        // Seed a barber
        var barber = new BarberProfileEntity
        {
            Uid = "barber_x",
            DisplayName = "Master Barber",
            RatingAvg = 4.0,
            RatingCount = 1
        };
        db.BarberProfiles.Add(barber);

        var appointment = new AppointmentEntity
        {
            Id = "app_100",
            CustomerId = "cust_10",
            CustomerName = "John",
            BarberId = "barber_x",
            BarberName = "Master Barber",
            ServiceId = "svc_1",
            ServiceName = "Haircut",
            Price = 100000,
            Status = "pending",
            Date = DateTime.Now.AddDays(1).ToString("yyyy-MM-dd"),
            StartTime = "10:00",
            EndTime = "10:30",
            SlotIdsJson = "[\"slot_100\"]",
            StartTimestamp = DateTime.Now.AddDays(1),
            EndTimestamp = DateTime.Now.AddDays(1).AddMinutes(30)
        };
        db.Appointments.Add(appointment);
        db.BookedSlots.Add(new BookedSlotEntity
        {
            Id = "slot_100",
            BarberId = "barber_x",
            Date = appointment.Date,
            Time = "10:00",
            AppointmentId = "app_100",
            StartTimestamp = appointment.StartTimestamp
        });
        await db.SaveChangesAsync();

        // 1. Confirm appointment
        var confirmRes = await appointmentsCtrl.ConfirmAppointment("app_100");
        Assert.IsType<OkObjectResult>(confirmRes);
        Assert.Equal("confirmed", appointment.Status);

        // 2. Complete appointment
        var completeRes = await appointmentsCtrl.CompleteAppointment("app_100");
        Assert.IsType<OkObjectResult>(completeRes);
        Assert.Equal("completed", appointment.Status);

        // 3. Rate appointment with 5 stars
        var rateRes = await appointmentsCtrl.RateAppointment("app_100", new RateAppointmentRequest(
            BarberId: "barber_x",
            Rating: 5,
            CustomerId: "cust_10",
            CustomerName: "John",
            Comment: "Tuyệt vời"
        ));
        Assert.IsType<OkObjectResult>(rateRes);

        // Rating avg: (4.0*1 + 5)/2 = 4.5
        var updatedBarber = await db.BarberProfiles.FindAsync("barber_x");
        Assert.Equal(4.5, updatedBarber!.RatingAvg);
        Assert.Equal(2, updatedBarber.RatingCount);

        // 4. Update private note
        var noteRes = await appointmentsCtrl.UpdateBarberPrivateNote("app_100", new UpdatePrivateNoteRequest("Khách thích cắt fade thấp"));
        Assert.IsType<OkObjectResult>(noteRes);
        Assert.Equal("Khách thích cắt fade thấp", appointment.BarberPrivateNote);
    }

    [Fact]
    public async Task AdminController_StatsAndReviews_WorksAsExpected()
    {
        using var db = CreateInMemoryDbContext();
        var adminCtrl = new AdminController(db);

        // Seed data
        await DbInitializer.InitializeAsync(new TestServiceProvider(db));

        // 1. Get stats
        var statsRes = await adminCtrl.GetDashboardStats();
        var statsOk = Assert.IsType<OkObjectResult>(statsRes);
        var stats = Assert.IsAssignableFrom<Dictionary<string, object>>(statsOk.Value);
        Assert.True((int)stats["totalHairstyles"] >= 10);
        Assert.True((int)stats["approvedBarbers"] >= 5);

        // 2. Settings read and write
        var getSettings = await adminCtrl.GetSystemSettings();
        var settingsOk = Assert.IsType<OkObjectResult>(getSettings);
        var settingsMap = Assert.IsAssignableFrom<Dictionary<string, object?>>(settingsOk.Value);
        Assert.Equal(10.0, (double)settingsMap["searchRadiusKm"]!);

        var putSettings = await adminCtrl.SaveSystemSettings(new SaveSystemSettingsRequest(
            SearchRadiusKm: 15.5,
            CancelNoticeHours: 2,
            MaintenanceMode: true
        ));
        Assert.IsType<OkObjectResult>(putSettings);

        var verifySetting = await db.SystemSettings.FindAsync("global");
        Assert.Equal(15.5, verifySetting!.SearchRadiusKm);
        Assert.True(verifySetting.MaintenanceMode);
    }

    private class TestServiceProvider : IServiceProvider, IServiceScope, IServiceScopeFactory
    {
        private readonly AppDbContext _db;
        public TestServiceProvider(AppDbContext db) => _db = db;
        public object? GetService(Type serviceType)
        {
            if (serviceType == typeof(AppDbContext)) return _db;
            if (serviceType == typeof(IServiceScopeFactory)) return this;
            return null;
        }
        public IServiceScope CreateScope() => this;
        public IServiceProvider ServiceProvider => this;
        public void Dispose() { }
    }
}

// CreBy: MenBoyBMN
