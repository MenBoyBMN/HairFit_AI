# KẾ HOẠCH TRIỂN KHAI PHÂN HỆ QUẢN TRỊ TOÀN DIỆN (ADMIN PORTAL PLAN)
## HairFit AI — Nền Tảng Đặt Lịch Cắt Tóc & Tư Vấn Kiểu Tóc Thông Minh

> **Tài liệu:** Kế Hoạch Thiết Kế & Triển Khai Phân Hệ Quản Trị Hệ Thống (Admin Control Hub)  
> **Phiên bản:** v1.0  
> **Ngày lập:** 2026-10-04  
> **Tham chiếu cốt lõi:**  
> - `HairFit_AI_Specification.md` (Đặc tả chi tiết hệ thống)  
> - `HairFit_AI_Execution_Plan.md` (Kế hoạch thực thi chung)  
> - `firestore.rules` (Quy tắc bảo mật Firestore)  

---

## 1. TỔNG QUAN & MỤC TIÊU CHIẾN LƯỢC

### 1.1 Hiện Trạng & Vấn Đề
Hiện tại, phân hệ Admin của HairFit AI mới chỉ có duy nhất màn hình `approve_barbers_screen.dart`. Màn hình này chỉ giải quyết được một khâu nhỏ: duyệt hồ sơ thợ từ trạng thái `pending` sang `approved`/`rejected`. 

**Những khoảng trống vận hành nghiêm trọng đang tồn tại:**
1. **Thiếu bức tranh tổng thể:** Admin không có bảng điều khiển trung tâm (Dashboard) để theo dõi các chỉ số sống còn của hệ thống (Active Users, Lịch hẹn trong ngày, Tỷ lệ hoàn thành, Tải hệ thống).
2. **Mất kiểm soát người dùng & thợ:** Không thể xem danh sách tất cả thợ (chỉ thấy thợ đang chờ duyệt); không có danh sách khách hàng; không thể khóa (`isBlocked`) tài khoản vi phạm hoặc gian lận.
3. **Mù thông tin vận hành lịch hẹn:** Toàn bộ luồng đặt lịch (Appointments) diễn ra giữa khách và thợ mà Admin không thể giám sát, không thể hủy lịch khẩn cấp khi có sự cố, không thể giải phóng slot bị kẹt (`bookedSlots`).
4. **Dữ liệu kiểu tóc và AI bị đóng băng:** Danh mục kiểu tóc (`hairstyleCatalog`) đang phụ thuộc dữ liệu seed tĩnh; không có UI để Admin thêm kiểu tóc hot trend, điều chỉnh tag dáng mặt (`FaceShape`).
5. **Kiểm duyệt nội dung bị bỏ ngỏ:** Chưa có màn hình quản lý đánh giá (`reviews`), xử lý đánh giá tiêu cực/bôi nhọ thợ.

### 1.2 Mục Tiêu Cốt Lõi
Xây dựng phân hệ **Admin Control Hub** hoàn chỉnh, biến HairFit AI từ một ứng dụng di động cơ bản thành một **hệ sinh thái nền tảng khép kín**, cho phép Admin nắm toàn quyền kiểm soát 100% tài nguyên hệ thống theo mô hình:

```
                            ┌─────────────────────────────────────────┐
                            │        HAIRFIT AI - ADMIN PORTAL        │
                            └────────────────────┬────────────────────┘
                                                 │
      ┌──────────────────┬───────────────────────┼───────────────────────┬──────────────────┐
      ▼                  ▼                       ▼                       ▼                  ▼
[1. Dashboard]     [2. Thợ & Tiệm]         [3. Người dùng]         [4. Lịch hẹn]      [5. Kiểu tóc AI]
- Thống kê KPIs    - Danh sách duyệt       - Danh sách khách/thợ   - Giám sát lịch    - Quản lý catalog
- Biểu đồ lịch     - Quản trị hồ sơ        - Khóa/Mở tài khoản     - Xử lý slot kẹt   - Gắn tag dáng mặt
- Tỷ lệ hoàn tất   - Tạm khóa/Mở thợ       - Phân quyền Role       - Hủy khẩn cấp     - Mẹo tạo kiểu
                                                 │
                                 ┌───────────────┴───────────────┐
                                 ▼                               ▼
                          [6. Đánh giá]                   [7. Cài đặt & Dev]
                          - Duyệt & xóa review            - Seed Data 1-Click
                          - Xử lý khiếu nại               - Tham số hệ thống
```

---

## 2. KIẾN TRÚC ĐIỀU HƯỚNG & GIAO DIỆN (ADMIN SHELL & ROUTING)

### 2.1 Cấu Trúc Admin Shell Layout
Hệ thống Admin sẽ sử dụng bố cục **Adaptive Shell** linh hoạt:
- **Màn hình lớn (Tablet / Web / Desktop):** Hiển thị `NavigationRail` hoặc `Sidebar` cố định bên trái, nội dung hiển thị bên phải.
- **Màn hình điện thoại (Mobile):** Sử dụng `AppBar` với `NavigationDrawer` vuốt ngang và `BottomNavigationBar` cho các tác vụ thường xuyên nhất.

```
+-------------------------------------------------------------------------------+
| HairFit AI Admin Portal                    [Refresh] [Admin Info] [Đăng xuất]  |
+-------------------+-----------------------------------------------------------+
| [📊 Dashboard]    | NỘI DUNG CHÍNH CỦA MODULE ĐANG CHỌN                       |
| [💈 Quản lý Thợ]  |                                                           |
| [👥 Người dùng]   | (Hiển thị DataTable, Thẻ KPIs, Bộ lọc trạng thái,         |
| [📅 Lịch hẹn]     |  Form chỉnh sửa, Hộp thoại xác nhận)                     |
| [✂️ Kiểu tóc AI]  |                                                           |
| [⭐ Đánh giá]     |                                                           |
| [⚙️ Cài đặt/Seed] |                                                           |
+-------------------+-----------------------------------------------------------+
```

### 2.2 Sơ Đồ Định Tuyến Mới (Routing Tree trong `app_router.dart`)

```dart
// Admin Base Route: /admin
/admin/dashboard         // [MỚI] Trang tổng quan chỉ số KPIs & biểu đồ
/admin/barbers           // [NÂNG CẤP] Quản lý thợ (Gồm Tab 'Cần duyệt' và Tab 'Tất cả thợ')
/admin/users             // [MỚI] Danh sách tài khoản (Khách/Thợ), Khóa/Mở tài khoản
/admin/appointments      // [MỚI] Giám sát & Điều phối tất cả lịch hẹn toàn hệ thống
/admin/hairstyles        // [MỚI] Quản lý danh mục kiểu tóc & gắn nhãn dáng mặt AI
/admin/reviews           // [MỚI] Kiểm duyệt đánh giá & xử lý vi phạm
/admin/settings          // [MỚI] Công cụ Seed Data 1-Click & Cấu hình tham số hệ thống
```

> **Ghi chú về Route Guard:** Cập nhật lại `app_router.dart` để khi Admin đăng nhập thành công sẽ mặc định chuyển hướng vào `/admin/dashboard` thay vì nhảy ngay vào `/admin/approve-barbers`.

---

## 3. ĐẶC TẢ CHI TIẾT 7 PHÂN HỆ QUẢN TRỊ

---

### PHÂN HỆ 1: DASHBOARD TỔNG QUAN & ANALYTICS THỜI GIAN THỰC (OVERVIEW HUB)

#### 1. Mục tiêu
Cung cấp góc nhìn toàn cảnh về sức khỏe của nền tảng, các chỉ số vận hành quan trọng trong ngày mà không cần vào từng bảng dữ liệu.

#### 2. Các chỉ số hiển thị (KPI Cards)
* **Tổng người dùng:** Số lượng Customer vs Số lượng Barber đang hoạt động.
* **Hồ sơ thợ chờ duyệt:** Đếm số thợ có `approvalStatus == 'pending'` (Kèm nút bấm chuyển nhanh sang duyệt).
* **Lịch hẹn hôm nay:**
  * Tổng số lịch hẹn được đặt trong ngày.
  * Phân rã: Chờ xác nhận (`pending`), Đã xác nhận (`confirmed`), Đã hoàn tất (`completed`), Đã hủy (`cancelled`).
* **Tỷ lệ hoàn thành (Completion Rate):** `completed / (completed + cancelled + rejected) * 100%`.
* **Thống kê AI Tư Vấn:** Số lượng khuôn mặt đã được phân tích, dáng mặt phổ biến nhất (Tròn, Vuông, Oval...).

#### 3. Biểu đồ trực quan
* **Biểu đồ cột/đường:** Lượng đặt lịch trong 7 ngày gần nhất.
* **Biểu đồ tròn (Pie Chart):** Cơ cấu trạng thái lịch hẹn hôm nay.
* **Bảng Top 5:**
  * Top 5 Thợ có điểm rating cao nhất và nhiều lịch nhất.
  * Top 5 Kiểu tóc được khách hàng quan tâm/chọn nhiều nhất.

---

### PHÂN HỆ 2: QUẢN LÝ ĐỐI TÁC THỢ CẮT TÓC (BARBER & SALON MANAGEMENT)

#### 1. Mục tiêu
Quản lý toàn diện vòng đời của thợ cắt tóc: từ lúc nộp hồ sơ, hoạt động kinh doanh, cập nhật tiệm, đến khi tạm ngưng hoặc xử lý vi phạm.

#### 2. Cấu trúc 2 Tab chuyên biệt
* **Tab 1: Hồ sơ chờ duyệt (Pending Barbers - Kế thừa & tối ưu từ hiện tại):**
  * Danh sách thợ nộp hồ sơ mới.
  * Xem ảnh bằng cấp, chứng chỉ, salon, danh sách dịch vụ, giá tiền, giờ mở cửa.
  * Nút: `Duyệt hồ sơ` (chuyển sang `approved`), `Từ chối` (chuyển sang `rejected` kèm lý do).
* **Tab 2: Danh bạ thợ toàn hệ thống (All Barbers):**
  * Danh sách tất cả thợ (`approved`, `rejected`, `suspended`).
  * Thanh tìm kiếm nhanh: Tên thợ, Tên tiệm tóc, Số điện thoại, Địa chỉ quận/huyện.
  * Bộ lọc: Trạng thái duyệt, Điểm rating (từ cao đến thấp), Khoảng giá dịch vụ.

#### 3. Các hành động can thiệp
* **Xem & Sửa nhanh thông tin tiệm:** Hỗ trợ thợ khi họ gặp trục trặc kỹ thuật (đổi số điện thoại, sửa tên tiệm, cập nhật giờ làm việc).
* **Hiệu chỉnh tọa độ Bản đồ (Lat / Lng):** Xem marker tiệm trên OpenStreetMap trực tiếp trong Admin. Có thể kéo thả marker hoặc nhập lại tọa độ nếu thợ ghim nhầm vị trí.
* **Tạm khóa / Mở khóa thợ (`suspended`):** Khi thợ bị khách khiếu nại nhiều lần về thái độ hoặc hủy lịch tùy tiện. Thợ bị suspended sẽ bị ẩn khỏi bản đồ tìm kiếm của khách ngay lập tức.
* **Ghim thợ uy tín (Featured Barber):** Bật cờ `isFeatured = true` để đưa thợ lên đầu danh sách trang chủ.

---

### PHÂN HỆ 3: QUẢN LÝ NGƯỜI DÙNG & BẢO MẬT TÀI KHOẢN (USER & ROLE MANAGEMENT)

#### 1. Mục tiêu
Quản lý tập trung toàn bộ danh sách tài khoản trong collection `users`, bảo vệ nền tảng khỏi các hành vi phá hoại hoặc spam lịch hẹn.

#### 2. Chức năng chính
* **Danh sách tài khoản đồng bộ:**
  * Hiển thị Avatar, Tên hiển thị, Email, Số điện thoại, Vai trò (`customer`, `barber`, `admin`), Ngày tham gia.
  * Bộ lọc phân loại theo Vai trò và Trạng thái tài khoản (`Active` / `Blocked`).
  * Tìm kiếm theo Email hoặc Số điện thoại.
* **Chi tiết hồ sơ người dùng:**
  * Xem số lượng lịch hẹn đã từng đặt (đối với khách) hoặc số lịch đã nhận (đối với thợ).
  * Tỷ lệ hủy lịch của khách hàng (phát hiện khách chuyên "bùng" lịch).
* **Khóa / Mở khóa tài khoản (`isBlocked`):**
  * Nút gạt chuyển trạng thái `isBlocked` (dựa trên trường có sẵn trong `UserModel`).
  * Popup nhập lý do khóa tài khoản (lưu vết `blockReason` và `blockedAt`).
  * Khi tài khoản bị khóa: Router Guard và Firestore Rules sẽ lập tức chặn mọi thao tác và buộc đăng xuất về trang login.
* **Quản trị phân quyền (Role Assignment):**
  * Cho phép Admin chỉ định một tài khoản khác trở thành `admin` hoặc giáng cấp về `customer`.

---

### PHÂN HỆ 4: QUẢN LÝ & ĐIỀU PHỐI LỊCH HẸN (APPOINTMENTS & OPERATIONS CONTROL)

#### 1. Mục tiêu
Đóng vai trò là "Trung tâm điều phối không lưu" của toàn bộ hệ thống đặt lịch, cho phép giám sát dòng lịch hẹn theo thời gian thực và xử lý sự cố tức thì.

#### 2. Bảng Master Lịch Hẹn (Master Appointments Table)
* **Hiển thị đầy đủ thông tin:**
  * Mã lịch hẹn, Tên khách hàng (kèm SĐT), Tên thợ/Tiệm (kèm SĐT).
  * Dịch vụ lựa chọn, Kiểu tóc đã chọn (nếu có từ AI), Tổng tiền.
  * Ngày giờ hẹn (`appointmentDate`, `timeSlot`).
  * Trạng thái hiện tại: `pending` | `confirmed` | `completed` | `cancelled` | `rejected`.
* **Bộ lọc đa chiều:**
  * Lọc theo khoảng ngày (Hôm nay, Tuần này, Tháng này, Tùy chọn).
  * Lọc theo trạng thái cụ thể.
  * Tìm kiếm theo tên khách, tên thợ hoặc mã lịch hẹn.

#### 3. Các công cụ can thiệp nghiệp vụ khẩn cấp (Emergency Overrides)
* **Hủy lịch khẩn cấp (Admin Cancel):** Khi nhận được cuộc gọi khẩn cấp từ khách hoặc thợ báo sự cố bất khả kháng (tiệm mất điện, sự cố sức khỏe). Hệ thống tự động giải phóng slot và ghi chú lý do hủy bởi Admin.
* **Giải phóng Slot Kẹt (`bookedSlots Rescue`):** 
  * Trong trường hợp xảy ra lỗi mạng hoặc xung đột giao dịch khiến document trong `bookedSlots` bị treo mà không tạo được `appointments`, Admin có nút "Mở khóa slot" để đưa slot về trạng thái trống cho thợ.
* **Xuất báo cáo lịch hẹn:** Xem tóm tắt thống kê số ca hoàn tất, số ca hủy để đối soát cuối ngày.

---

### PHÂN HỆ 5: QUẢN LÝ DANH MỤC KIỂU TÓC & CẤU HÌNH AI (HAIRSTYLE CATALOG & AI ENGINE)

#### 1. Mục tiêu
Chuyển đổi danh mục kiểu tóc từ dữ liệu tĩnh (`SeedDataService`) thành dữ liệu động lưu trên Firestore `hairstyleCatalog`, cho phép cập nhật xu hướng tóc mới mà không cần release lại ứng dụng.

#### 2. Quản lý Danh mục Kiểu tóc (CRUD)
* **Thêm mới / Sửa kiểu tóc:**
  * Tên kiểu tóc (ví dụ: *Undercut Quiff, Side Part 7/3, Mullet Hiện Đại, Buzz Cut, Layer Hàn Quốc...*).
  * Ảnh đại diện chất lượng cao (URL hình ảnh).
  * Độ dài tóc phù hợp: Ngắn (`short`), Trung bình (`medium`), Dài (`long`).
  * Mô tả đặc điểm kiểu tóc.
  * Hướng dẫn tạo kiểu tại nhà (Styling tips): Loại sáp khuyên dùng, kỹ thuật sấy phồng.
* **Gắn nhãn Dáng mặt Phù hợp (`suitableFaceShapes`):**
  * Checkbox chọn các dáng mặt tương thích: `Round` (Mặt tròn), `Oval` (Trái xoan), `Square` (Mặt vuông), `Heart` (Trái tim), `Diamond` (Kim cương), `Oblong` (Mặt dài).
  * Đây là dữ liệu làm căn cứ trực tiếp để AI Engine gợi ý kiểu tóc cho khách sau khi quét mặt.
* **Bật/Tắt hiển thị:** Tạm ẩn kiểu tóc nếu không còn thịnh hành.

#### 3. Thống kê & Giám sát AI
* Thống kê số lượt khách chọn từng kiểu tóc sau khi được AI gợi ý.
* Bảng tham số hình học nhận diện khuôn mặt (hiển thị để tham khảo các ngưỡng tỷ lệ của thuật toán `FaceShapeAnalyzer`).

---

### PHÂN HỆ 6: QUẢN LÝ ĐÁNH GIÁ & KIỂM DUYỆT NỘI DUNG (REVIEWS & MODERATION)

#### 1. Mục tiêu
Duy trì môi trường đánh giá minh bạch, công bằng; ngăn chặn hành vi bôi nhọ tiệm tóc hoặc spam đánh giá tiêu cực giả mạo.

#### 2. Chức năng chính
* **Danh sách đánh giá toàn hệ thống (Collection `reviews`):**
  * Hiển thị: Tên khách hàng, Thợ được đánh giá, Số sao (1 - 5 sao), Nội dung nhận xét, Ngày đánh giá.
  * Bộ lọc theo số sao: Dễ dàng lọc riêng các đánh giá 1 - 2 sao để Admin rà soát nguyên nhân không hài lòng.
  * Lọc theo Thợ: Xem tất cả phản hồi của một tiệm cụ thể.
* **Hành động kiểm duyệt (Dựa trên quyền `allow update, delete: if isAdmin()` trong Firestore Rules):**
  * **Ẩn đánh giá vi phạm:** Tạm ẩn bình luận có nội dung xúc phạm, dùng từ ngữ không chuẩn mực hoặc chứa số điện thoại quảng cáo rác.
  * **Xóa vĩnh viễn đánh giá giả mạo:** Cho phép xóa sau khi đã xác minh sự cố giữa khách và thợ.
  * **Cập nhật lại điểm trung bình của Thợ:** Nút tính toán và đồng bộ lại `ratingAvg` và `ratingCount` trong `barberProfiles` khi có review bị xóa.

---

### PHÂN HỆ 7: CÀI ĐẶT HỆ THỐNG & BỘ CÔNG CỤ PHÁT TRIỂN / DEMO (SYSTEM SETTINGS & DEV TOOLS)

#### 1. Mục tiêu
Hỗ trợ tối đa cho việc kiểm thử, trình diễn đồ án và tùy biến tham số nghiệp vụ mà không phải can thiệp vào mã nguồn.

#### 2. Trình Gieo Dữ Liệu 1-Click (1-Click Seed Data Manager)
* **Nút "Seed Toàn Bộ Dữ Liệu Demo":**
  * Tự động tạo 10 kiểu tóc chuẩn vào `hairstyleCatalog`.
  * Tự động tạo 5 thợ cắt tóc mẫu (kèm tọa độ thực tế xung quanh Hà Nội / TP.HCM, bảng giá, giờ làm việc).
  * Tự động tạo các lịch hẹn mẫu ở nhiều trạng thái khác nhau (`pending`, `confirmed`, `completed`, `cancelled`) để Admin có ngay dữ liệu trực quan để biểu diễn.
* **Nút "Xóa Dữ Liệu Thử Nghiệm":** Dọn dẹp các lịch hẹn test, slot test để chuẩn bị cho buổi demo chính thức.

#### 3. Cấu hình tham số nghiệp vụ (System Configurations)
* **Bán kính tìm kiếm thợ tối đa:** Cấu hình khoảng cách mặc định trên bản đồ (ví dụ: 10km, 20km).
* **Quy định thời gian hủy lịch:** Khách chỉ được hủy trước giờ hẹn tối thiểu bao nhiêu tiếng (ví dụ: 1 tiếng, 2 tiếng).
* **Bật/Tắt Chế độ Bảo Trì (Maintenance Mode):** Cho phép Admin tạm ngưng hệ thống khi cần nâng cấp cơ sở dữ liệu.

---

## 4. TỔ CHỨC CẤU TRÚC MÃ NGUỒN (CODEBASE ARCHITECTURE)

Dự kiến các tệp mã nguồn mới và cập nhật trong `lib/`:

```
lib/
├── features/
│   └── admin/
│       ├── data/
│       │   └── admin_repository.dart           # [MỚI] Tương tác Firestore cho các tác vụ Admin
│       ├── presentation/
│       │   ├── admin_shell_screen.dart         # [MỚI] Khung giao diện Admin (Navigation Drawer/Sidebar)
│       │   ├── admin_dashboard_screen.dart     # [MỚI] Màn hình Dashboard KPIs & biểu đồ
│       │   ├── approve_barbers_screen.dart     # [CÓ SẴN - TỐI ƯU HÓA] Tab duyệt thợ pending
│       │   ├── admin_barbers_screen.dart       # [MỚI] Quản lý danh sách tất cả thợ & sửa thông tin
│       │   ├── admin_users_screen.dart         # [MỚI] Quản lý khách hàng, thợ, khóa/mở tài khoản
│       │   ├── admin_appointments_screen.dart  # [MỚI] Giám sát & điều phối lịch hẹn toàn hệ thống
│       │   ├── admin_hairstyles_screen.dart    # [MỚI] Quản trị danh mục kiểu tóc & gắn dáng mặt
│       │   ├── admin_reviews_screen.dart       # [MỚI] Kiểm duyệt đánh giá & xử lý vi phạm
│       │   ├── admin_settings_screen.dart      # [MỚI] Bộ công cụ Seed Data & Cấu hình tham số
│       │   └── widgets/
│       │       ├── admin_kpi_card.dart         # [MỚI] Widget hiển thị thẻ thống kê số liệu
│       │       ├── admin_status_badge.dart     # [MỚI] Chip hiển thị trạng thái màu sắc trực quan
│       │       └── emergency_cancel_dialog.dart# [MỚI] Dialog xác nhận hủy lịch khẩn cấp
├── providers/
│   ├── admin_provider.dart                     # [NÂNG CẤP] Bổ sung controllers & streams cho toàn bộ Admin
│   └── admin_stats_provider.dart               # [MỚI] Provider tổng hợp số liệu KPIs cho Dashboard
└── routing/
    └── app_router.dart                         # [CẬP NHẬT] Đăng ký routes và đổi default redirect
```

---

## 5. LỘ TRÌNH THỰC HIỆN THEO GIAI ĐOẠN (PHASED ROADMAP)

Để đảm bảo hiệu quả cao nhất và tránh quá tải ngữ cảnh, quá trình triển khai được chia thành **5 giai đoạn tuần tự**:

```
[Phase 1] ───► [Phase 2] ───► [Phase 3] ───► [Phase 4] ───► [Phase 5]
Khung Shell     Người Dùng     Quản Lý       Kiểu Tóc AI    Cài Đặt &
& Dashboard     & Thợ Tóc      Lịch Hẹn      & Đánh Giá     Seed Data
```

### 🎯 Phase 1: Xây Dựng Khung Shell & Dashboard Tổng Quan (Core Foundation)
* **Nhiệm vụ 1.1:** Xây dựng `AdminRepository` với các hàm đếm số lượng người dùng, thợ, lịch hẹn hôm nay.
* **Nhiệm vụ 1.2:** Tạo `admin_stats_provider.dart` cung cấp Stream dữ liệu thống kê thời gian thực.
* **Nhiệm vụ 1.3:** Xây dựng giao diện `AdminShellScreen` hỗ trợ chuyển đổi giữa các module qua Sidebar / NavigationDrawer.
* **Nhiệm vụ 1.4:** Thiết kế giao diện `AdminDashboardScreen` với các thẻ KPI Cards nổi bật và tóm tắt công việc cần làm trong ngày.
* **Nhiệm vụ 1.5:** Cập nhật `app_router.dart` để liên kết khung điều hướng mới.

### 🎯 Phase 2: Quản Lý Toàn Diện Thợ Cắt Tóc & Người Dùng
* **Nhiệm vụ 2.1:** Nâng cấp module thợ thành `AdminBarbersScreen` gồm 2 Tab: *Cần duyệt* và *Tất cả thợ*.
* **Nhiệm vụ 2.2:** Bổ sung tính năng Khóa / Mở thợ (`suspended`), sửa nhanh thông tin tiệm và cập nhật tọa độ bản đồ.
* **Nhiệm vụ 2.3:** Xây dựng màn hình `AdminUsersScreen`: Danh sách tất cả tài khoản `users`.
* **Nhiệm vụ 2.4:** Triển khai tính năng Khóa / Mở tài khoản (`isBlocked`) kèm lý do khóa.

### 🎯 Phase 3: Quản Lý & Điều Phối Lịch Hẹn Hệ Thống
* **Nhiệm vụ 3.1:** Xây dựng `AdminAppointmentsScreen` hiển thị danh sách toàn bộ lịch hẹn.
* **Nhiệm vụ 3.2:** Tích hợp bộ lọc theo ngày, theo trạng thái (`pending`, `confirmed`, `completed`, `cancelled`).
* **Nhiệm vụ 3.3:** Xây dựng tính năng Hủy lịch khẩn cấp (`Emergency Cancel`) và tự động giải phóng slot tương ứng trong `bookedSlots`.
* **Nhiệm vụ 3.4:** Bổ sung tính năng kiểm tra và mở khóa các slot bị kẹt (`Slot Rescue`).

### 🎯 Phase 4: Quản Trị Danh Mục Kiểu Tóc & Kiểm Duyệt Đánh Giá
* **Nhiệm vụ 4.1:** Xây dựng `AdminHairstylesScreen`: Quản lý danh sách kiểu tóc trên Firestore collection `hairstyleCatalog`.
* **Nhiệm vụ 4.2:** Form Thêm/Sửa kiểu tóc: Tên, ảnh, độ dài tóc, mẹo tạo kiểu và chọn các dáng mặt phù hợp (`FaceShape`).
* **Nhiệm vụ 4.3:** Xây dựng `AdminReviewsScreen`: Xem tất cả đánh giá, lọc review 1 - 2 sao.
* **Nhiệm vụ 4.4:** Tính năng Ẩn / Xóa review tiêu cực hoặc spam, cập nhật lại điểm trung bình cho thợ.

### 🎯 Phase 5: Bộ Công Cụ Cài Đặt, Seed Data & Hoàn Thiện Bảo Mật
* **Nhiệm vụ 5.1:** Xây dựng `AdminSettingsScreen`: Nút gieo dữ liệu demo 1-Click (thợ, kiểu tóc, lịch hẹn mẫu).
* **Nhiệm vụ 5.2:** Tùy chỉnh tham số hệ thống (bán kính tìm kiếm, thời gian hủy lịch tối thiểu).
* **Nhiệm vụ 5.3:** Rà soát và gia cố các quy tắc Firestore trong `firestore.rules` đảm bảo chỉ có `isAdmin()` mới được phép can thiệp các collection nhạy cảm.
* **Nhiệm vụ 5.4:** Kiểm thử toàn diện luồng nghiệp vụ Admin trên thiết bị thật / máy ảo Android.

---

## 6. ĐỐI SOÁT VỚI BẢO MẬT FIRESTORE (SECURITY RULES COMPLIANCE)

Hệ thống Firestore Rules hiện tại (`firestore.rules`) đã được thiết kế rất chặt chẽ và sẵn sàng hỗ trợ đầy đủ các tính năng Admin trên:

| Collection | Quyền Admin hiện tại trong `firestore.rules` | Ứng dụng thực tế trong kế hoạch |
|---|---|---|
| `/users/{userId}` | `allow read, write, delete: if isAdmin();` | Cho phép xem toàn bộ user, đổi role, bật cờ `isBlocked = true` |
| `/barberProfiles/{barberId}` | `allow read, write, delete: if isAdmin();` | Cho phép duyệt, từ chối, khóa thợ, sửa thông tin tiệm và vị trí GPS |
| `/appointments/{appointmentId}` | `allow read, update, delete: if isAdmin();` | Cho phép xem tất cả lịch hẹn, cập nhật trạng thái `cancelled` khẩn cấp |
| `/bookedSlots/{slotId}` | `allow read, delete: if isAuthenticated();` | Cho phép Admin can thiệp giải phóng slot bị kẹt |
| `/hairstyleCatalog/{styleId}` | `allow read: if true; allow write: if isAdmin();` | Chỉ duy nhất Admin được quyền thêm, sửa, xóa danh mục kiểu tóc |
| `/reviews/{reviewId}` | `allow read: if true; allow update, delete: if isAdmin();` | Chỉ duy nhất Admin được quyền kiểm duyệt hoặc xóa bỏ đánh giá |
| `/chats/{chatId}` | `allow read: if ... || isAdmin();` | Cho phép Admin giám sát hội thoại khi có khiếu nại tranh chấp |

---

## 7. TIÊU CHÍ NGHIỆM THU (ACCEPTANCE CRITERIA)

Một phân hệ Admin đạt chuẩn khi vượt qua kịch bản kiểm thử sau:
1. ✅ **Đăng nhập phân quyền:** Đăng nhập với tài khoản có `role == 'admin'` sẽ tự động chuyển hướng vào `AdminShellScreen` với Dashboard trực quan. Tài khoản `customer` hoặc `barber` cố tình gõ link `/admin` sẽ bị chặn ngay lập tức.
2. ✅ **Số liệu chính xác:** Các thẻ thống kê trên Dashboard phản ánh đúng số lượng thực tế trong cơ sở dữ liệu Firestore.
3. ✅ **Quản lý thợ 360 độ:** Có thể duyệt thợ mới, xem danh sách thợ cũ, khóa thợ vi phạm và cập nhật tọa độ salon thành công.
4. ✅ **Khóa tài khoản tức thì:** Khi Admin bấm Khóa một khách hàng hoặc thợ, tài khoản đó bị văng ra trang Login ngay ở request tiếp theo.
5. ✅ **Điều phối lịch hẹn mượt mà:** Xem được toàn bộ danh sách lịch hẹn của các cặp khách - thợ; Admin bấm Hủy khẩn cấp thì slot được giải phóng ngay lập tức trên lịch của thợ.
6. ✅ **Động hóa kiểu tóc AI:** Thêm một kiểu tóc mới trong Admin và gắn nhãn mặt tròn (`Round`), khi khách hàng quét mặt ra dáng mặt tròn thì kiểu tóc mới đó xuất hiện ngay trong danh sách gợi ý.
7. ✅ **Demo 1-Click tiện lợi:** Nhấn nút Seed Data trên giao diện Admin, toàn bộ hệ thống được lấp đầy dữ liệu mẫu đẹp mắt chỉ sau vài giây.
