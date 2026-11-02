# HairFit AI - Hướng Dẫn Cài Đặt & Khởi Chạy Dự Án Từ Đầu (Step-by-Step Setup Guide)

Tài liệu này cung cấp quy trình từng bước chi tiết nhất dành cho lập trình viên mới nhận bàn giao hoặc clone mã nguồn **HairFit AI** từ GitHub/GitLab về máy tính cá nhân. Hướng dẫn bao quát từ chuẩn bị môi trường, thiết lập Backend (C# .NET 8 & Node.js), kết nối Tunnel ra Internet, cấu hình Firebase và khởi chạy Frontend Flutter trên các nền tảng (Android, Web, Windows Desktop).

---

## 1. Yêu Cầu Tiền Đề & Môi Trường Phát Triển (Prerequisites)

Trước khi bắt đầu, hãy đảm bảo máy tính của bạn đã cài đặt các công cụ sau:

| Thành phần | Phiên bản khuyến nghị | Mục đích sử dụng | Kiểm tra lệnh |
| :--- | :--- | :--- | :--- |
| **Git** | >= 2.40.x | Quản lý mã nguồn | `git --version` |
| **Flutter SDK** | 3.22.x - 3.24.x (Dart 3.x) | Xây dựng giao diện đa nền tảng | `flutter --version` |
| **.NET SDK** | 8.0.x | Chạy ASP.NET Core Web API (Backend chính) | `dotnet --version` |
| **Node.js & npm** | LTS v18.x hoặc v20.x | Chạy Node.js Express Server & deploy Vercel | `node -v` & `npm -v` |
| **Java JDK** | OpenJDK 17 | Biên dịch Android ứng dụng Flutter | `java -version` |
| **Android Studio** | Koala / Ladybug | Quản lý Android SDK & Thiết bị giả lập (AVD) | Mở Android Studio |
| **Trình duyệt Web** | Google Chrome / MS Edge | Kiểm thử nhanh giao diện Flutter Web | Mở Chrome |
| **Ngrok CLI** | Mới nhất | Tạo Static Domain Public URL miễn phí cho API | `ngrok version` |

> [!TIP]
> Bạn có thể chạy lệnh `flutter doctor` trong Terminal để kiểm tra xem Flutter đã nhận diện đủ Android SDK, Chrome và VS Code/Android Studio hay chưa. Nếu thiếu dấu tick nào, hãy làm theo hướng dẫn của `flutter doctor`.

---

## 2. Clone Mã Nguồn Dự Án

Mở Terminal (Command Prompt hoặc PowerShell) tại thư mục làm việc của bạn:

```bash
git clone https://github.com/your-username/HairFit_AI.git
cd HairFit_AI
```

### Cấu Trúc Tổng Quan Sau Khi Clone:
```text
HairFit_AI/
├── frontend/          # Ứng dụng Flutter đa nền tảng (Mobile, Web, Desktop)
├── backend/           # Máy chủ Web API (ASP.NET Core 8 & Node.js Express)
├── server_setup/      # Kịch bản tự động hóa cài đặt & khởi chạy Tunnel máy chủ
├── About System/      # Tài liệu kiến trúc, hướng dẫn hệ thống & kế hoạch
└── .gitignore         # Bộ lọc loại trừ file rác, build artifacts và bí mật
```

---

## 3. Khởi Chạy Máy Chủ Backend (Web API)

Dự án HairFit AI trang bị **2 tùy chọn Backend linh hoạt**, cả 2 đều tương thích 100% với Frontend:
- **Tùy chọn A (Khuyên dùng - Chính thức)**: **ASP.NET Core 8 Web API** (`backend/HairFit.Api`) — Hiệu năng cao, bảo đảm tính toàn vẹn ACID cho giao dịch đặt lịch.
- **Tùy chọn B (Dự phòng / Demo cấp tốc)**: **Node.js Express API** (`backend/server.js`) — Nhẹ, khởi động tức thì, hỗ trợ deploy 1-click lên Vercel Serverless.

---

### Cách 3.1: Chạy ASP.NET Core 8 Web API (Khuyên dùng)

#### Bước 1: Khôi phục dependencies và kiểm tra build
```bash
cd backend/HairFit.Api
dotnet restore
dotnet build
```

#### Bước 2: Khởi chạy máy chủ API
```bash
dotnet run
```
Máy chủ sẽ lắng nghe tại:
- **`http://localhost:5000`** hoặc **`http://0.0.0.0:5000`**
- Kiểm tra trạng thái bằng trình duyệt: Mở `http://localhost:5000/api/health` hoặc `http://localhost:5000/health`. Bạn sẽ nhận được JSON:
  ```json
  { "status": "Healthy", "timestamp": "..." }
  ```

---

### Cách 3.2: Chạy Node.js Express API (Dự phòng)

#### Bước 1: Cài đặt npm dependencies
```bash
cd backend
npm install
```

#### Bước 2: Khởi chạy server Express
```bash
npm start
```
Máy chủ sẽ lắng nghe tại:
- **`http://localhost:3000`**
- Kiểm tra trạng thái: Mở `http://localhost:3000/api/health` trên trình duyệt.

> [!NOTE]
> Muốn triển khai Node.js API lên Vercel miễn phí trong 1 phút:
> ```bash
> cd backend
> npx vercel
> ```
> Vercel sẽ sinh ra URL công khai dạng `https://hairfit-ai-backend.vercel.app`.

---

## 4. Thiết Lập Mạng & Public Tunnel (Để Điện Thoại / Máy Khác Truy Cập)

Khi chạy ứng dụng trên điện thoại thật hoặc thiết bị khác kết nối vào API đang chạy ở máy tính phát triển, bạn cần một đường dẫn công khai (Public URL). HairFit AI đã chuẩn bị sẵn bộ công cụ tự động tại thư mục `server_setup/`.

### 4.1 Sử dụng Ngrok Static Domain (Miễn phí vĩnh viễn & Ổn định nhất)
1. Đăng ký tài khoản miễn phí tại [https://dashboard.ngrok.com](https://dashboard.ngrok.com).
2. Vào mục **Domains** trên Dashboard của Ngrok, bấm **Create Domain** để nhận một Static Domain miễn phí (Ví dụ: `clothing-similarly-delicacy.ngrok-free.dev`).
3. Lấy **Authtoken** tại mục **Your Authtoken**.
4. Mở thư mục `server_setup/`:
   - Nếu máy tính mới: Nhấp đúp chạy file `1_setup_new_machine.bat` (nhập authtoken khi được hỏi).
   - Điền tên miền tĩnh bạn vừa tạo vào file `server_setup/ngrok_domain.txt`.
5. Khởi chạy Server kèm Ngrok chỉ bằng 1 cú nhấp chuột:
   - Chạy `2_start_server_ngrok.bat` (Dành cho .NET API cổng 5000).
   - Hoặc chạy `2_start_server_nodejs.bat` (Dành cho Node.js API cổng 3000).

Cửa sổ đen sẽ duy trì đường hầm mạng:
👉 **`https://your-domain.ngrok-free.dev`** trỏ thẳng về máy tính của bạn!

---

## 5. Cấu Hình & Khởi Chạy Frontend Flutter

### Bước 1: Cấu hình biến môi trường (`frontend/.env`)
Vào thư mục `frontend/`, kiểm tra hoặc tạo file `.env` (dựa trên mẫu `.env.example`):

```properties
# HairFit AI Environment Variables
# Điền URL Backend tương ứng với môi trường bạn đang chạy:

# Trường hợp 1: Chạy qua Ngrok Static Domain (Khuyên dùng cho cả Mobile thật & Web)
API_BASE_URL=https://clothing-similarly-delicacy.ngrok-free.dev

# Trường hợp 2: Chạy cục bộ trên Android Emulator (Backend ASP.NET Core)
# API_BASE_URL=http://10.0.2.2:5000

# Trường hợp 3: Chạy cục bộ trên Chrome Web / Desktop (Backend ASP.NET Core)
# API_BASE_URL=http://localhost:5000

# Trường hợp 4: Kết nối Backend Vercel Cloud
# API_BASE_URL=https://hairfit-ai-backend.vercel.app
```

> [!IMPORTANT]
> `ApiClient` của HairFit AI được lập trình thông minh: Nếu bạn quên chỉnh `localhost` khi chạy trên Android Emulator, hệ thống sẽ **tự động chuyển `localhost` thành `10.0.2.2`** để tránh mất kết nối mạng.

---

### Bước 2: Tải các thư viện Flutter
Mở Terminal tại thư mục `frontend/`:
```bash
cd frontend
flutter pub get
```

---

### Bước 3: Khởi chạy ứng dụng

#### A. Khởi chạy trên Trình duyệt Web (Nhanh nhất để trải nghiệm ngay):
```bash
flutter run -d chrome
```
*Lưu ý: Màn hình lớn sẽ tự động kích hoạt chế độ Responsive Antigravity Navbar sang trọng.*

#### B. Khởi chạy trên Android Emulator hoặc Thiết bị thật:
1. Kết nối điện thoại bật chế độ **USB Debugging** hoặc mở một máy ảo Android Emulator.
2. Kiểm tra danh sách thiết bị nhận diện:
   ```bash
   flutter devices
   ```
3. Chạy ứng dụng:
   ```bash
   flutter run -d <tên_thiết_bị_hoặc_emulator_id>
   ```

#### C. Khởi chạy trên Windows Desktop:
```bash
flutter run -d windows
```

---

## 6. Dữ Liệu Mẫu (Seed Data) & Trải Nghiệm 3 Vai Trò Người Dùng

HairFit AI tích hợp sẵn **Cloud Firestore & Firebase Auth** trên gói Spark Tier 0 đồng (`frontend/lib/core/services/firebase_options.dart`).

### 6.1 Nạp 50 Kiểu Tóc Mẫu Chuẩn AI & Dữ Liệu Thợ Cắt Tóc
Khi khởi chạy ứng dụng lần đầu, bạn có thể khởi tạo cơ sở dữ liệu mẫu bằng 2 cách:
1. **Tự động qua UI**: Vào ứng dụng, mở menu Cài đặt / Trợ giúp và chọn **"Nạp dữ liệu mẫu (Seed Data)"**.
2. **Qua SeedDataService**: Lớp `SeedDataService` trong mã nguồn sẽ tự động kiểm tra, nếu collection `hairstyles` hoặc `barbers` trên Firestore chưa có dữ liệu, service sẽ tự động nạp 50 kiểu tóc với đầy đủ thông số hình học (tỷ lệ mặt, độ dài, chất tóc) và danh sách salon tại Hà Nội / TP.HCM.

### 6.2 Tài Khoản Mẫu Trải Nghiệm Theo Vai Trò (RBAC)

Bạn có thể tự đăng ký tài khoản mới trên giao diện Register hoặc đăng nhập với các tài khoản thử nghiệm:

| Vai trò (Role) | Chức năng chính | Giao diện tương ứng |
| :--- | :--- | :--- |
| **Customer** (Khách hàng) | Quét mặt On-device AI, xem kiểu tóc hợp, tìm salon trên bản đồ OSM, đặt lịch hẹn, xem Thẻ Tóc AI Handshake. | `CustomerHomeScreen` (`/home`) |
| **Barber** (Thợ cắt tóc) | Quản lý lịch hẹn theo thời gian thực, xem doanh thu ngày, cài đặt giờ làm việc, cập nhật danh mục dịch vụ, quét mã AI của khách. | `BarberAppointmentsScreen` (`/barber/appointments`) |
| **Admin** (Quản trị viên) | Bảng điều khiển phân tích hệ thống, duyệt hồ sơ thợ đăng ký mới, đình chỉ tài khoản vi phạm, quản lý đánh giá. | `AdminDashboardScreen` (`/admin/dashboard`) |

---

## 7. Kiểm Tra Tính Toàn Vẹn Của Mã Nguồn (Quality Gate)

Để đảm bảo mọi thứ sau khi clone và chỉnh sửa đều đạt chuẩn 100% trước khi commit, hãy thực thi chuỗi lệnh kiểm tra:

```bash
# 1. Kiểm tra tĩnh mã nguồn Dart/Flutter (bắt buộc 0 issues)
cd frontend
flutter analyze

# 2. Chạy bộ 121+ bài kiểm thử tự động (Unit, Widget, Responsive)
flutter test

# 3. Định dạng lại toàn bộ mã nguồn
dart format .

# 4. Kiểm thử Backend .NET (5/5 unit tests)
cd ../backend
dotnet test
```

Tất cả các lệnh trên đều phải vượt qua với **0 lỗi và 0 cảnh báo**.

---

## 8. Bảng Xử Lý Sự Cố Thường Gặp (Troubleshooting FAQs)

### ❓ Lỗi 1: `Unable to find bundled Java version` hoặc `Android Gradle build failed`
- **Nguyên nhân**: Phiên bản Java JDK không tương thích hoặc chưa trỏ đúng biến môi trường `JAVA_HOME`.
- **Cách xử lý**: Cài đặt OpenJDK 17. Đặt biến môi trường hệ thống `JAVA_HOME = C:\Program Files\Eclipse Adoptium\jdk-17...` và khởi động lại Terminal.

### ❓ Lỗi 2: Không thể kết nối từ điện thoại thật vào máy tính (`Connection refused`)
- **Nguyên nhân**: Điện thoại không thể gọi trực tiếp IP nội bộ hoặc firewall của máy tính chặn cổng 5000/3000.
- **Cách xử lý**: Khởi chạy Ngrok tunnel bằng script `server_setup/2_start_server_ngrok.bat` và dán URL `https://...ngrok-free.dev` vào file `frontend/.env`.

### ❓ Lỗi 3: Lỗi bản đồ hiển thị mảng xám hoặc thiếu bản đồ
- **Nguyên nhân**: Kết nối mạng bị gián đoạn khi tải tile OpenStreetMap.
- **Cách xử lý**: `TileServerConfig` trong mã nguồn đã được tích hợp sẵn cache thông minh và cấu hình User-Agent tiêu chuẩn của OpenStreetMap để không bị chặn kết nối, không tốn bất kỳ chi phí mua API key nào.

---

<!-- CreBy: MenBoyBMN -->

