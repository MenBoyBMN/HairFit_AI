using HairFit.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace HairFit.Api.Data;

public static class DbInitializer
{
    public static async Task InitializeAsync(IServiceProvider services)
    {
        using var scope = services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();

        await db.Database.EnsureCreatedAsync();

        if (!await db.SystemSettings.AnyAsync())
        {
            db.SystemSettings.Add(new SystemSettingEntity
            {
                Key = "global",
                SearchRadiusKm = 10.0,
                CancelNoticeHours = 1,
                MaintenanceMode = false,
                UpdatedAt = DateTime.UtcNow
            });
            await db.SaveChangesAsync();
        }

        if (!await db.Hairstyles.AnyAsync())
        {
            await SeedHairstylesAsync(db, overwrite: false);
        }

        if (!await db.BarberProfiles.AnyAsync())
        {
            await SeedBarbersAsync(db, overwrite: false);
        }
    }

    public static List<HairstyleEntity> GetSampleHairstyles()
    {
        return new List<HairstyleEntity>
        {
            new()
            {
                Id = "undercut",
                Name = "Undercut Cổ Điển",
                Description = "Cắt ngắn gọn gàng hai bên và sau gáy, phần mái để dài vuốt ngược, giúp khuôn mặt trông thon gọn và góc cạnh hơn.",
                ImageUrl = "https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=500&auto=format&fit=crop",
                ImageUrlsJson = JsonHelper.Serialize(new[]
                {
                    "https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=500&auto=format&fit=crop",
                    "https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=500&auto=format&fit=crop",
                    "https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=500&auto=format&fit=crop"
                }),
                FaceShapesJson = JsonHelper.Serialize(new[] { "round", "square", "oval" }),
                TagsJson = JsonHelper.Serialize(new[] { "nam", "gọn gàng", "hiện đại", "công sở" }),
                Active = true
            },
            new()
            {
                Id = "side_part",
                Name = "Side Part 7/3 Lịch Lãm",
                Description = "Kiểu tóc rẽ ngôi 7/3 hoặc 8/2 kinh điển, tôn lên đường nét tri thức, hài hoà cho người mặt dài hoặc trái xoan.",
                ImageUrl = "https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=500&auto=format&fit=crop",
                ImageUrlsJson = JsonHelper.Serialize(new[]
                {
                    "https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=500&auto=format&fit=crop",
                    "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&auto=format&fit=crop",
                    "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=500&auto=format&fit=crop"
                }),
                FaceShapesJson = JsonHelper.Serialize(new[] { "oval", "oblong", "heart" }),
                TagsJson = JsonHelper.Serialize(new[] { "nam", "lịch lãm", "cổ điển", "công sở" }),
                Active = true
            },
            new()
            {
                Id = "pompadour",
                Name = "Pompadour Phồng",
                Description = "Phần tóc mái được sấy phồng và vuốt ngược ra sau tạo độ bồng bềnh, tăng thêm chiều cao biểu kiến cho người mặt tròn.",
                ImageUrl = "https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=500&auto=format&fit=crop",
                ImageUrlsJson = JsonHelper.Serialize(new[]
                {
                    "https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=500&auto=format&fit=crop",
                    "https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=500&auto=format&fit=crop",
                    "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=500&auto=format&fit=crop"
                }),
                FaceShapesJson = JsonHelper.Serialize(new[] { "round", "oval", "square" }),
                TagsJson = JsonHelper.Serialize(new[] { "nam", "quý ông", "bồng bềnh", "tiệc" }),
                Active = true
            },
            new()
            {
                Id = "layer_male",
                Name = "Tóc Layer Nam Hàn Quốc",
                Description = "Các lọn tóc được cắt tỉa so le tạo tầng lớp tự nhiên, che khuyết điểm trán cao và làm mềm các góc cạnh khuôn mặt.",
                ImageUrl = "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&auto=format&fit=crop",
                ImageUrlsJson = JsonHelper.Serialize(new[]
                {
                    "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&auto=format&fit=crop",
                    "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=500&auto=format&fit=crop",
                    "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=500&auto=format&fit=crop"
                }),
                FaceShapesJson = JsonHelper.Serialize(new[] { "oval", "oblong", "heart" }),
                TagsJson = JsonHelper.Serialize(new[] { "nam", "trẻ trung", "hàn quốc", "tự nhiên" }),
                Active = true
            },
            new()
            {
                Id = "two_block",
                Name = "Two Block Học Đường",
                Description = "Đặc trưng với 2 khối rõ rệt: phần dưới cắt sát, phần trên để layer tự nhiên, phù hợp mọi độ tuổi học sinh và sinh viên.",
                ImageUrl = "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&auto=format&fit=crop",
                ImageUrlsJson = JsonHelper.Serialize(new[]
                {
                    "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&auto=format&fit=crop",
                    "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&auto=format&fit=crop"
                }),
                FaceShapesJson = JsonHelper.Serialize(new[] { "oval", "heart", "round" }),
                TagsJson = JsonHelper.Serialize(new[] { "nam", "học sinh", "sinh viên", "dễ chăm" }),
                Active = true
            },
            new()
            {
                Id = "french_crop",
                Name = "French Crop Cá Tính",
                Description = "Mái bằng ngắn ngang trán kết hợp fade sát hai bên, cực kỳ thoáng mát và tôn lên xương hàm góc cạnh.",
                ImageUrl = "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=500&auto=format&fit=crop",
                ImageUrlsJson = JsonHelper.Serialize(new[]
                {
                    "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=500&auto=format&fit=crop",
                    "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=500&auto=format&fit=crop"
                }),
                FaceShapesJson = JsonHelper.Serialize(new[] { "square", "oval", "oblong" }),
                TagsJson = JsonHelper.Serialize(new[] { "nam", "cá tính", "ngắn", "mát mẻ" }),
                Active = true
            },
            new()
            {
                Id = "buzz_cut",
                Name = "Buzz Cut Nam Tính",
                Description = "Húi cua quân đội siêu ngắn, làm nổi bật đường nét nam tính, không tốn công tạo kiểu hay sấy tóc mỗi ngày.",
                ImageUrl = "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=500&auto=format&fit=crop",
                ImageUrlsJson = JsonHelper.Serialize(new[]
                {
                    "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=500&auto=format&fit=crop",
                    "https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=500&auto=format&fit=crop"
                }),
                FaceShapesJson = JsonHelper.Serialize(new[] { "oval", "square" }),
                TagsJson = JsonHelper.Serialize(new[] { "nam", "thể thao", "quân đội", "siêu ngắn" }),
                Active = true
            },
            new()
            {
                Id = "mullet_modern",
                Name = "Mullet Hiện Đại",
                Description = "Ngắn phía trước và hai bên, dài dần về phía gáy, mang phong cách đường phố phá cách và phóng khoáng.",
                ImageUrl = "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=500&auto=format&fit=crop",
                ImageUrlsJson = JsonHelper.Serialize(new[]
                {
                    "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=500&auto=format&fit=crop",
                    "https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=500&auto=format&fit=crop"
                }),
                FaceShapesJson = JsonHelper.Serialize(new[] { "oval", "heart", "oblong" }),
                TagsJson = JsonHelper.Serialize(new[] { "nam", "phá cách", "streetwear", "nghệ thuật" }),
                Active = true
            },
            new()
            {
                Id = "quiff",
                Name = "Textured Quiff",
                Description = "Tóc mái vuốt chếch lên trên với các thớ tóc lọn rõ ràng, tạo cảm giác năng động và cực kỳ thu hút.",
                ImageUrl = "https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=500&auto=format&fit=crop",
                ImageUrlsJson = JsonHelper.Serialize(new[]
                {
                    "https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=500&auto=format&fit=crop",
                    "https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=500&auto=format&fit=crop"
                }),
                FaceShapesJson = JsonHelper.Serialize(new[] { "round", "square", "oval" }),
                TagsJson = JsonHelper.Serialize(new[] { "nam", "năng động", "hiện đại", "hẹn hò" }),
                Active = true
            },
            new()
            {
                Id = "slicked_back",
                Name = "Slicked Back Vuốt Ngược",
                Description = "Toàn bộ tóc vuốt ngược bóng bẩy về sau, tạo thần thái quyền lực và sang trọng của quý ông.",
                ImageUrl = "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=500&auto=format&fit=crop",
                ImageUrlsJson = JsonHelper.Serialize(new[]
                {
                    "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=500&auto=format&fit=crop",
                    "https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=500&auto=format&fit=crop"
                }),
                FaceShapesJson = JsonHelper.Serialize(new[] { "oval", "square", "oblong" }),
                TagsJson = JsonHelper.Serialize(new[] { "nam", "sang trọng", "quý ông", "sự kiện" }),
                Active = true
            }
        };
    }

    public static List<BarberProfileEntity> GetSampleBarbers()
    {
        var now = DateTime.UtcNow;
        return new List<BarberProfileEntity>
        {
            new()
            {
                Uid = "barber_danang_01",
                DisplayName = "HairFit Studio Đà Nẵng",
                AvatarUrl = "https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=500&auto=format&fit=crop",
                Bio = "Tiệm cắt tóc chuẩn phong cách Barber Châu Âu, hơn 8 năm kinh nghiệm tạo kiểu cho các quý ông.",
                Address = "123 Nguyễn Văn Linh, Quận Hải Châu, Đà Nẵng",
                Latitude = 16.0544,
                Longitude = 108.2022,
                PriceMin = 80000,
                PriceMax = 150000,
                RatingAvg = 4.9,
                RatingCount = 128,
                ApprovalStatus = "approved",
                IsAcceptingBookingsToday = true,
                HairstyleIdsJson = JsonHelper.Serialize(new[] { "undercut", "side_part", "pompadour", "quiff" }),
                ServicesJson = JsonHelper.Serialize(new object[]
                {
                    new { id = "svc_01", name = "Cắt tạo kiểu cao cấp", price = 80000, durationMinutes = 30, active = true },
                    new { id = "svc_02", name = "Combo Cắt + Gội massage + Sấy vuốt sáp", price = 120000, durationMinutes = 60, active = true },
                    new { id = "svc_03", name = "Uốn tóc tạo phồng Textured", price = 150000, durationMinutes = 90, active = true }
                }),
                WorkingHoursJson = BuildWorkingHoursJson("08:30", "20:00", satClose: "21:00", sunOpen: "09:00", sunClose: "18:00"),
                CreatedAt = now,
                UpdatedAt = now
            },
            new()
            {
                Uid = "barber_danang_02",
                DisplayName = "30Shine Hải Châu",
                AvatarUrl = "https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=500&auto=format&fit=crop",
                Bio = "Chuỗi cắt tóc nam hiện đại, phục vụ nhanh chóng, chuyên nghiệp và ứng dụng công nghệ.",
                Address = "45 Lê Duẩn, Quận Hải Châu, Đà Nẵng",
                Latitude = 16.0680,
                Longitude = 108.2160,
                PriceMin = 100000,
                PriceMax = 180000,
                RatingAvg = 4.8,
                RatingCount = 95,
                ApprovalStatus = "approved",
                IsAcceptingBookingsToday = true,
                HairstyleIdsJson = JsonHelper.Serialize(new[] { "side_part", "two_block", "layer_male", "french_crop" }),
                ServicesJson = JsonHelper.Serialize(new object[]
                {
                    new { id = "svc_04", name = "Combo Shine 7 bước", price = 100000, durationMinutes = 30, active = true },
                    new { id = "svc_05", name = "Nhuộm màu thời trang", price = 180000, durationMinutes = 60, active = true }
                }),
                WorkingHoursJson = BuildWorkingHoursJson("08:00", "21:00", satClose: "21:30", sunOpen: "08:00", sunClose: "21:00"),
                CreatedAt = now,
                UpdatedAt = now
            },
            new()
            {
                Uid = "barber_danang_03",
                DisplayName = "Tiệm Cắt Tóc Quý Ông Retro",
                AvatarUrl = "https://images.unsplash.com/photo-1621605815971-fbc98d665033?w=500&auto=format&fit=crop",
                Bio = "Không gian cổ điển thập niên 80, chuyên cạo râu khăn nóng và các kiểu tóc Pompadour, Slicked Back.",
                Address = "88 Bạch Đằng, Quận Hải Châu, Đà Nẵng",
                Latitude = 16.0645,
                Longitude = 108.2235,
                PriceMin = 90000,
                PriceMax = 200000,
                RatingAvg = 4.95,
                RatingCount = 84,
                ApprovalStatus = "approved",
                IsAcceptingBookingsToday = true,
                HairstyleIdsJson = JsonHelper.Serialize(new[] { "pompadour", "slicked_back", "buzz_cut", "undercut" }),
                ServicesJson = JsonHelper.Serialize(new object[]
                {
                    new { id = "svc_06", name = "Cắt tóc cổ điển Classic", price = 90000, durationMinutes = 30, active = true },
                    new { id = "svc_07", name = "Cạo mặt khăn nóng tinh dầu", price = 60000, durationMinutes = 30, active = true },
                    new { id = "svc_08", name = "Gói chăm sóc Quý Ông Toàn Diện", price = 200000, durationMinutes = 90, active = true }
                }),
                WorkingHoursJson = BuildWorkingHoursJson("09:00", "19:30", satClose: "20:00", sunClosed: true),
                CreatedAt = now,
                UpdatedAt = now
            },
            new()
            {
                Uid = "barber_danang_04",
                DisplayName = "Street Barber Club",
                AvatarUrl = "https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=500&auto=format&fit=crop",
                Bio = "Chuyên Fade nghệ thuật, Mullet và các kiểu tóc đường phố phá cách cho giới trẻ.",
                Address = "210 Điện Biên Phủ, Quận Thanh Khê, Đà Nẵng",
                Latitude = 16.0610,
                Longitude = 108.1950,
                PriceMin = 70000,
                PriceMax = 130000,
                RatingAvg = 4.7,
                RatingCount = 62,
                ApprovalStatus = "approved",
                IsAcceptingBookingsToday = true,
                HairstyleIdsJson = JsonHelper.Serialize(new[] { "mullet_modern", "french_crop", "buzz_cut", "two_block" }),
                ServicesJson = JsonHelper.Serialize(new object[]
                {
                    new { id = "svc_09", name = "Skin Fade sắc nét", price = 70000, durationMinutes = 30, active = true },
                    new { id = "svc_10", name = "Tạo kiểu Mullet nghệ thuật", price = 90000, durationMinutes = 60, active = true },
                    new { id = "svc_11", name = "Tẩy tóc & Nhuộm highlight", price = 130000, durationMinutes = 90, active = true }
                }),
                WorkingHoursJson = BuildWorkingHoursJson("09:00", "20:00", satClose: "20:00", sunOpen: "09:00", sunClose: "18:00"),
                CreatedAt = now,
                UpdatedAt = now
            },
            new()
            {
                Uid = "barber_danang_05",
                DisplayName = "Korean Hair Studio",
                AvatarUrl = "https://images.unsplash.com/photo-1560066984-138dadb4c035?w=500&auto=format&fit=crop",
                Bio = "Tạo mẫu tóc nam phong cách Hàn Quốc: Layer bay, Two Block, Uốn phồng chân tóc nhẹ nhàng.",
                Address = "15 Võ Văn Kiệt, Quận Sơn Trà, Đà Nẵng",
                Latitude = 16.0602,
                Longitude = 108.2390,
                PriceMin = 85000,
                PriceMax = 160000,
                RatingAvg = 4.85,
                RatingCount = 110,
                ApprovalStatus = "approved",
                IsAcceptingBookingsToday = true,
                HairstyleIdsJson = JsonHelper.Serialize(new[] { "layer_male", "two_block", "side_part", "quiff" }),
                ServicesJson = JsonHelper.Serialize(new object[]
                {
                    new { id = "svc_12", name = "Cắt Layer chuẩn Hàn", price = 85000, durationMinutes = 30, active = true },
                    new { id = "svc_13", name = "Uốn phồng chân tóc tự nhiên", price = 160000, durationMinutes = 60, active = true }
                }),
                WorkingHoursJson = BuildWorkingHoursJson("09:00", "20:30", satClose: "21:00", sunOpen: "09:00", sunClose: "19:00"),
                CreatedAt = now,
                UpdatedAt = now
            }
        };
    }

    private static string BuildWorkingHoursJson(
        string weekdayOpen,
        string weekdayClose,
        string? satClose = null,
        string? sunOpen = null,
        string? sunClose = null,
        bool sunClosed = false)
    {
        var dict = new Dictionary<string, object>
        {
            ["mon"] = new { closed = false, open = weekdayOpen, close = weekdayClose },
            ["tue"] = new { closed = false, open = weekdayOpen, close = weekdayClose },
            ["wed"] = new { closed = false, open = weekdayOpen, close = weekdayClose },
            ["thu"] = new { closed = false, open = weekdayOpen, close = weekdayClose },
            ["fri"] = new { closed = false, open = weekdayOpen, close = weekdayClose },
            ["sat"] = new { closed = false, open = weekdayOpen, close = satClose ?? weekdayClose },
            ["sun"] = sunClosed
                ? new { closed = true, open = "00:00", close = "00:00" }
                : new { closed = false, open = sunOpen ?? weekdayOpen, close = sunClose ?? weekdayClose }
        };
        return JsonHelper.Serialize(dict);
    }

    public static async Task SeedHairstylesAsync(AppDbContext db, bool overwrite)
    {
        foreach (var item in GetSampleHairstyles())
        {
            var existing = await db.Hairstyles.FindAsync(item.Id);
            if (existing == null)
            {
                db.Hairstyles.Add(item);
            }
            else if (overwrite)
            {
                existing.Name = item.Name;
                existing.Description = item.Description;
                existing.ImageUrl = item.ImageUrl;
                existing.ImageUrlsJson = item.ImageUrlsJson;
                existing.FaceShapesJson = item.FaceShapesJson;
                existing.TagsJson = item.TagsJson;
                existing.Active = item.Active;
            }
        }
        await db.SaveChangesAsync();
    }

    public static async Task SeedBarbersAsync(AppDbContext db, bool overwrite)
    {
        foreach (var item in GetSampleBarbers())
        {
            var existing = await db.BarberProfiles.FindAsync(item.Uid);
            if (existing == null)
            {
                db.BarberProfiles.Add(item);
            }
            else if (overwrite)
            {
                existing.DisplayName = item.DisplayName;
                existing.AvatarUrl = item.AvatarUrl;
                existing.Bio = item.Bio;
                existing.Address = item.Address;
                existing.Latitude = item.Latitude;
                existing.Longitude = item.Longitude;
                existing.PriceMin = item.PriceMin;
                existing.PriceMax = item.PriceMax;
                existing.RatingAvg = item.RatingAvg;
                existing.RatingCount = item.RatingCount;
                existing.ApprovalStatus = item.ApprovalStatus;
                existing.HairstyleIdsJson = item.HairstyleIdsJson;
                existing.ServicesJson = item.ServicesJson;
                existing.WorkingHoursJson = item.WorkingHoursJson;
                existing.UpdatedAt = DateTime.UtcNow;
            }
        }
        await db.SaveChangesAsync();
    }

    public static async Task ClearSampleBarbersAsync(AppDbContext db)
    {
        var sampleIds = GetSampleBarbers().Select(b => b.Uid).ToList();
        var entities = await db.BarberProfiles.Where(b => sampleIds.Contains(b.Uid)).ToListAsync();
        if (entities.Count > 0)
        {
            db.BarberProfiles.RemoveRange(entities);
            await db.SaveChangesAsync();
        }
    }

    public static async Task SeedSampleAppointmentsAsync(AppDbContext db)
    {
        var todayStr = DateTime.Now.ToString("yyyy-MM-dd");
        var now = DateTime.UtcNow;
        var firstBarber = GetSampleBarbers().First();

        var samples = new List<AppointmentEntity>
        {
            new()
            {
                Id = "sample_app_1",
                CustomerId = "customer_demo_1",
                CustomerName = "Nguyễn Văn An",
                BarberId = firstBarber.Uid,
                BarberName = firstBarber.DisplayName,
                ServiceId = "srv_1",
                ServiceName = "Cắt tóc nam tiêu chuẩn",
                Price = 100000,
                DurationMinutes = 30,
                Date = todayStr,
                StartTime = "09:30",
                EndTime = "10:00",
                StartTimestamp = now,
                EndTimestamp = now.AddMinutes(30),
                Timezone = "Asia/Ho_Chi_Minh",
                SlotIdsJson = JsonHelper.Serialize(new[] { $"slot_{todayStr}_0930" }),
                HairstyleId = "undercut",
                Note = "Cắt ngắn 2 bên giúp mình",
                Status = "confirmed",
                CreatedAt = now,
                UpdatedAt = now
            },
            new()
            {
                Id = "sample_app_2",
                CustomerId = "customer_demo_2",
                CustomerName = "Trần Minh Đức",
                BarberId = firstBarber.Uid,
                BarberName = firstBarber.DisplayName,
                ServiceId = "srv_2",
                ServiceName = "Combo Cắt + Gội + Massage",
                Price = 150000,
                DurationMinutes = 45,
                Date = todayStr,
                StartTime = "11:00",
                EndTime = "11:45",
                StartTimestamp = now,
                EndTimestamp = now.AddMinutes(45),
                Timezone = "Asia/Ho_Chi_Minh",
                SlotIdsJson = JsonHelper.Serialize(new[] { $"slot_{todayStr}_1100" }),
                HairstyleId = "side_part",
                Note = "Cạo râu luôn",
                Status = "pending",
                CreatedAt = now,
                UpdatedAt = now
            },
            new()
            {
                Id = "sample_app_3",
                CustomerId = "customer_demo_3",
                CustomerName = "Lê Hoàng Long",
                BarberId = firstBarber.Uid,
                BarberName = firstBarber.DisplayName,
                ServiceId = "srv_1",
                ServiceName = "Cắt tóc nam tiêu chuẩn",
                Price = 100000,
                DurationMinutes = 30,
                Date = todayStr,
                StartTime = "08:00",
                EndTime = "08:30",
                StartTimestamp = now,
                EndTimestamp = now.AddMinutes(30),
                Timezone = "Asia/Ho_Chi_Minh",
                SlotIdsJson = JsonHelper.Serialize(new[] { $"slot_{todayStr}_0800" }),
                HairstyleId = "pompadour",
                Note = "Đã hoàn tất thanh toán",
                Status = "completed",
                CreatedAt = now,
                UpdatedAt = now
            }
        };

        foreach (var app in samples)
        {
            var existing = await db.Appointments.FindAsync(app.Id);
            if (existing == null)
            {
                db.Appointments.Add(app);
            }
            else
            {
                existing.Date = app.Date;
                existing.Status = app.Status;
                existing.Price = app.Price;
                existing.UpdatedAt = now;
            }
        }
        await db.SaveChangesAsync();
    }

    public static async Task ClearSampleAppointmentsAsync(AppDbContext db)
    {
        var ids = new[] { "sample_app_1", "sample_app_2", "sample_app_3" };
        var entities = await db.Appointments.Where(a => ids.Contains(a.Id)).ToListAsync();
        if (entities.Count > 0)
        {
            db.Appointments.RemoveRange(entities);
            await db.SaveChangesAsync();
        }
    }
}

// CreBy: MenBoyBMN

