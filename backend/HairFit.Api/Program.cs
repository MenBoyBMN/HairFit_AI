using HairFit.Api.Data;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

var builder = WebApplication.CreateBuilder(args);

// 1. Cấu hình Entity Framework Core với SQL Server (LocalDB)
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? "Server=(localdb)\\mssqllocaldb;Database=HairFitAiDb;Trusted_Connection=True;MultipleActiveResultSets=true;TrustServerCertificate=True";

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString));

// 2. Cấu hình xác thực Firebase JWT Bearer Token (Project: hairfitai-c4855)
var firebaseProjectId = builder.Configuration["Firebase:ProjectId"] ?? "hairfitai-c4855";
builder.Services
    .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.Authority = $"https://securetoken.google.com/{firebaseProjectId}";
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidIssuer = $"https://securetoken.google.com/{firebaseProjectId}",
            ValidateAudience = true,
            ValidAudience = firebaseProjectId,
            ValidateLifetime = true
        };
    });

builder.Services.AddAuthorization();

// 3. Cấu hình CORS cho phép Flutter Web / Mobile / Desktop kết nối
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFlutterClient", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

builder.Services.AddControllers(options =>
{
    options.SuppressImplicitRequiredAttributeForNonNullableReferenceTypes = true;
});
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new()
    {
        Title = "HairFit AI - ASP.NET Core Web API",
        Version = "v1",
        Description = "Backend RESTful API vận hành trên SQL Server (EF Core) & Firebase Auth cho nền tảng HairFit AI."
    });
});

var app = builder.Build();

// 4. Tự động tạo Database SQL Server và nạp Seed Data mặc định khi khởi chạy
await DbInitializer.InitializeAsync(app.Services);

app.UseSwagger();
app.UseSwaggerUI();

app.UseCors("AllowFlutterClient");

app.UseAuthentication();
app.UseAuthorization();

app.MapGet("/api/health", () => Results.Ok(new
{
    status = "healthy",
    service = "HairFit.Api",
    timestamp = DateTime.UtcNow.ToString("O")
}));

app.MapControllers();

app.Run();

// CreBy: MenBoyBMN

