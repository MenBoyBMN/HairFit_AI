# HairFit AI - RESTful Web API Backend

Backend Web API phục vụ cho ứng dụng di động & đa nền tảng **HairFit AI**. Dự án cung cấp 2 giải pháp Backend chuyên nghiệp:
1. **ASP.NET Core 8 Web API** (`HairFit.Api/`): Chạy trên Entity Framework Core, SQL Server LocalDB, xác thực Firebase JWT Bearer, tối ưu hóa cho máy chủ Backend hiệu năng cao tại cổng `5000`.
2. **Node.js Express Web API** (`server.js`, `routes/`, `data/`): Triển khai Serverless nhẹ nhàng, 0 đồng trên Vercel hoặc chạy cục bộ tại cổng `3000`.

Cả 2 Backend đều tương thích hoàn toàn 100% với các Route RESTful của Flutter Frontend (`/api/...`).

---

## 🚀 1. Khởi Chạy ASP.NET Core 8 Web API (Port 5000)

### Yêu cầu:
- .NET 8 SDK
- SQL Server Express LocalDB (đi kèm Visual Studio hoặc cài riêng)

### Lệnh chạy:
```bash
cd backend/HairFit.Api
dotnet run
```
- **Swagger UI**: `http://localhost:5000/swagger`
- **Health Check**: `http://localhost:5000/health` hoặc `http://localhost:5000/api/health`

### Chạy kiểm thử tự động (.NET):
```bash
dotnet test backend/HairFit.Backend.sln
```

---

## ⚡ 2. Khởi Chạy Node.js Express Web API (Port 3000)

### Bước 1: Cài đặt Dependencies
```bash
cd backend
npm install
```

### Bước 2: Khởi chạy Server
```bash
npm start
```
Server sẽ chạy tại: **`http://localhost:3000`**
- **Health Endpoint**: `http://localhost:3000/health` hoặc `http://localhost:3000/api/health`
- **Hairstyles**: `http://localhost:3000/api/hairstyles`
- **Barbers**: `http://localhost:3000/api/barbers/approved`

---

## 🌐 3. Hướng Dẫn Deploy Lên Vercel (Miễn Phí 100%)

1. Mở Terminal tại thư mục `backend/` và gõ lệnh:
   ```bash
   npx vercel
   ```
2. Bấm `Y` và chọn các thiết lập mặc định.
3. Vercel sẽ cấp đường dẫn dạng:
   👉 **`https://hairfit-ai-backend.vercel.app`**
4. Cập nhật `API_BASE_URL` trong file `frontend/.env` sang URL của Vercel.

---

## 📌 4. Danh Sách Các RESTful API Endpoints Chuẩn

| Method | Endpoint | Mô Tả |
| :--- | :--- | :--- |
| `GET` | `/health`, `/api/health` | Kiểm tra trạng thái máy chủ Web API |
| `GET` | `/api/hairstyles` | Lấy danh mục kiểu tóc chuẩn AI |
| `GET` | `/api/hairstyles/:id` | Lấy chi tiết kiểu tóc theo ID |
| `GET` | `/api/barbers/approved` | Danh sách thợ cắt tóc đã được duyệt |
| `GET` | `/api/barbers/featured` | Danh sách thợ cắt tóc nổi bật (rating cao nhất) |
| `GET` | `/api/barbers/:id` | Lấy chi tiết hồ sơ thợ cắt tóc |
| `GET` | `/api/barbers/:id/reviews` | Danh sách đánh giá của một thợ |
| `GET` | `/api/users/:id` | Lấy thông tin tài khoản người dùng |
| `POST` | `/api/users/sync` | Đồng bộ tài khoản sau khi đăng nhập Firebase |
| `GET` | `/api/appointments/customer/:customerId` | Lịch sử lịch hẹn của khách hàng |
| `GET` | `/api/appointments/barber/:barberId` | Danh sách lịch hẹn cần tiếp nhận của thợ |
| `POST` | `/api/appointments/:id/confirm` | Thợ xác nhận tiếp nhận lịch hẹn |
| `POST` | `/api/appointments/:id/reject` | Thợ từ chối lịch hẹn |
| `POST` | `/api/appointments/:id/complete` | Thợ hoàn tất dịch vụ |
| `GET` | `/api/bookings/slots` | Kiểm tra các khung giờ đã bị giữ chỗ |
| `POST` | `/api/bookings` | Tạo lịch hẹn mới (chống trùng lịch ACID) |
| `GET` | `/api/admin/stats` | Thống kê tổng quan cho Admin Dashboard |
| `POST` | `/api/ai-consult` | Gợi ý kiểu tóc theo dáng mặt |

<!-- CreBy: MenBoyBMN -->
