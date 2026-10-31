using HairFit.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace HairFit.Api.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
    {
    }

    public DbSet<UserEntity> Users => Set<UserEntity>();
    public DbSet<BarberProfileEntity> BarberProfiles => Set<BarberProfileEntity>();
    public DbSet<AppointmentEntity> Appointments => Set<AppointmentEntity>();
    public DbSet<BookedSlotEntity> BookedSlots => Set<BookedSlotEntity>();
    public DbSet<ReviewEntity> Reviews => Set<ReviewEntity>();
    public DbSet<HairstyleEntity> Hairstyles => Set<HairstyleEntity>();
    public DbSet<SystemSettingEntity> SystemSettings => Set<SystemSettingEntity>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<UserEntity>(entity =>
        {
            entity.HasIndex(u => u.Email);
            entity.HasIndex(u => u.Role);
        });

        modelBuilder.Entity<BarberProfileEntity>(entity =>
        {
            entity.HasIndex(b => b.ApprovalStatus);
            entity.HasIndex(b => b.RatingAvg);
        });

        modelBuilder.Entity<AppointmentEntity>(entity =>
        {
            entity.HasIndex(a => a.CustomerId);
            entity.HasIndex(a => a.BarberId);
            entity.HasIndex(a => new { a.BarberId, a.Date });
            entity.HasIndex(a => new { a.Date, a.Status });
        });

        modelBuilder.Entity<BookedSlotEntity>(entity =>
        {
            // Unique index đảm bảo chống trùng slot tuyệt đối ở tầng SQL Server
            entity.HasIndex(s => new { s.BarberId, s.Date, s.Time }).IsUnique();
            entity.HasIndex(s => s.AppointmentId);
        });

        modelBuilder.Entity<ReviewEntity>(entity =>
        {
            entity.HasIndex(r => r.BarberId);
            entity.HasIndex(r => r.Rating);
        });
    }
}

// CreBy: MenBoyBMN

