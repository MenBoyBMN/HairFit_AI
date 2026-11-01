# HairFit AI - RESTful Web API Backend

Backend Web API được phát triển bằng **Node.js (Express.js)** phục vụ cho ứng dụng Flutter **HairFit AI** nhằm đáp ứng 100% tiêu chí đồ án môn học về **Deploy Web API trực tuyến**.

---

## 🚀 1. Hướng Dẫn Chạy Local (Máy Cục Bộ)

### Bước 1: Cài đặt Dependencies
Mở Terminal tại thư mục `backend/`:
```bash
cd backend
npm install
```

### Bước 2: Khởi chạy Web API Server
```bash
npm start
```
Server sẽ chạy tại: **`http://localhost:3000`**

---

## 🌐 2. Hướng Dẫn Deploy Lên Vercel (Miễn phí 100% trong 1 phút)

1. Tải ứng dụng **Vercel CLI** hoặc đăng nhập tại [https://vercel.com](https://vercel.com).
2. Mở Terminal tại thư mục `backend/` và gõ lệnh:
   ```bash
   npx vercel
   ```
3. Bấm `Y` và chọn các thiết lập mặc định.
4. **Kết quả**: Vercel sẽ cấp cho bạn một đường dẫn URL dạng:
   👉 **`https://hairfit-ai-backend.vercel.app`**

---

## 📌 3. Danh Sách Các RESTful API Endpoints
- **`GET /`** : Trang chủ & Danh sách API
- **`GET /api/v1/health`** : Kiểm tra trạng thái máy chủ Web API
- **`GET /api/v1/hairstyles`** : Lấy danh sách 50 kiểu tóc chuẩn AI
- **`GET /api/v1/hairstyles/:id`** : Lấy chi tiết 1 kiểu tóc theo ID
- **`POST /api/v1/ai-consult`** : API Phân tích dáng mặt & gợi ý kiểu tóc
- **`POST /api/v1/booking`** : API Đặt lịch hẹn cắt tóc
