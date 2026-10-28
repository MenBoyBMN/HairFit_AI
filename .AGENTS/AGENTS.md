# HairFit AI - Sổ Tay Kỹ Thuật & Hướng Dẫn Dành Cho AI Agent

Chào mừng bạn đến với mã nguồn **HairFit AI**. Tài liệu này thiết lập các tiêu chuẩn kỹ thuật, nguyên tắc kiến trúc bất biến và quy tắc hành vi bắt buộc dành cho mọi AI Agent và lập trình viên làm việc trong không gian làm việc này.

---

## 1. Tổng Quan Dự Án & Triết Lý Cốt Lõi

**HairFit AI** là nền tảng di động thông minh hỗ trợ tư vấn kiểu tóc nam, tìm kiếm salon/thợ cắt tóc và đặt lịch hẹn trực tuyến. Ứng dụng được xây dựng trên nền tảng **Flutter**, vận hành bởi công nghệ **Thị giác Máy tính Trên Thiết Bị (On-Device ML Kit Face Mesh)** và kiến trúc **Firebase Serverless Tối Ưu Chi Phí 0 Đồng (Zero-Cost)**.

### Các Nguyên Tắc Kiến Trúc Bất Biến (Architectural Invariants)
1. **Hạ Tầng 0 Đồng (Zero-Cost Infrastructure)**:
   - Toàn bộ ứng dụng được tối ưu hóa nghiêm ngặt để vận hành bền vững trong gói miễn phí Firebase Spark (Free Tier).
   - **Tuyệt đối không sử dụng Cloud API trả phí**: Nhận diện hình dáng khuôn mặt và gợi ý kiểu tóc xử lý **100% cục bộ trên thiết bị (on-device)** thông qua Google ML Kit và công thức toán học tính tỷ lệ các điểm mốc (landmarks).
   - Giảm thiểu tối đa số lần đọc/ghi Firestore nhờ chiến lược caching, chia nhỏ sub-collection và thiết kế truy vấn theo composite index.
2. **Tính Toàn Vẹn Giao Dịch Đặt Lịch (Atomic Booking Integrity)**:
   - Các thao tác đặt lịch, đổi lịch (reschedule) và hủy lịch bắt buộc phải dùng **Firestore Transactions** để bảo đảm tính chất ACID, triệt tiêu hoàn toàn rủi ro trùng lịch (double-booking).
3. **Kiểm Soát Truy Cập Phân Quyền (RBAC - Role-Based Access Control)**:
   - Ba vai trò người dùng rõ ràng: `customer` (Khách hàng), `barber` (Thợ cắt tóc), `admin` (Quản trị viên).
   - Bảo mật đa tầng: Kết hợp Route guards ở tầng điều hướng (GoRouter) và quy tắc kiểm soát truy cập ở tầng cơ sở dữ liệu (Firestore Security Rules).
4. **Cổng Kiểm Tra Chất Lượng Code (Quality & Testing Gate)**:
   - Lệnh `flutter analyze` bắt buộc phải đạt **0 cảnh báo / 0 lỗi** (no issues found).
   - Mọi kịch bản kiểm thử trong thư mục `test/` phải chạy thành công (100% pass) trước khi hoàn tất công việc.

---

## 2. Ngăn Xếp Công Nghệ (Technical Stack)

| Thành Phần | Công Nghệ | Phiên Bản / Đặc Tả Kỹ Thuật |
| :--- | :--- | :--- |
| **Framework** | Flutter / Dart | Flutter 3.x, Dart 3.x (`analysis_options.yaml` nghiêm ngặt) |
| **Quản Lý Trạng Thái** | Riverpod | `flutter_riverpod: ^2.5.1` (StateNotifier, StreamProvider, FutureProvider) |
| **Điều Hướng & Định Tuyến** | GoRouter | `go_router: ^14.2.0` (Khai báo định tuyến, bảo vệ phân quyền redirect guards) |
| **Cơ Sở Dữ Liệu & Xác Thực**| Firebase | Cloud Firestore & Firebase Auth (Gói Serverless Spark 0đ) |
| **Trí Tuệ Nhân Tạo / ML** | Google ML Kit | Nhận diện lưới khuôn mặt On-device (`google_mlkit_face_mesh_detection`) |
| **Lưu Trữ Cục Bộ** | SharedPreferences | Bộ nhớ đệm tùy chọn người dùng, lưu trữ ngoại tuyến hồ sơ dáng mặt |
| **Hệ Thống Thiết Kế (UI)** | Vanilla Material 3 Tùy Chỉnh | Giao diện Dark mode sang trọng, kính mờ (glassmorphism), AppColors, AppDimensions |

---

## 3. Cấu Trúc Dự Án Theo Tính Năng (Feature-First)

Mã nguồn tuân thủ nghiêm ngặt mô hình kiến trúc **Feature-First**:

```
lib/
├── core/                        # Nền tảng dùng chung cho toàn bộ ứng dụng
│   ├── constants/               # AppColors, AppDimensions, AppTextStyles, BusinessConstants
│   ├── errors/                  # Định nghĩa ngoại lệ và mã lỗi tùy chỉnh
│   ├── services/                # Các dịch vụ tầng thấp (AuthService, SeedDataService)
│   ├── utils/                   # Hàm tiện ích bổ trợ (DateFormatter, UrlHelper, Formatters)
│   └── widgets/                 # Các thành phần UI nguyên tử tái sử dụng (AppButton, AppTextField,...)
├── features/                    # Các module nghiệp vụ (Feature-First)
│   ├── admin/                   # Cổng quản trị (Dashboard, Quản lý Thợ, Lịch hẹn, Người dùng, Đánh giá)
│   ├── ai_consult/              # Quét khuôn mặt, phân tích điểm mốc hình học, tư vấn kiểu tóc
│   ├── appointments/            # Quản lý lịch hẹn, Thẻ đồng bộ AI Handshake, Doanh thu ngày, Đổi lịch
│   ├── auth/                    # Đăng nhập, Đăng ký, Quên mật khẩu, Onboarding phân quyền
│   ├── barber_profile/          # Biên tập hồ sơ thợ, Giờ làm việc định kỳ, Album tác phẩm Lookbook
│   ├── booking/                 # Thuật toán tính slot, Luồng đặt lịch, Tóm tắt, Xử lý dời lịch
│   ├── home/                    # Trang chủ khách hàng, Thẻ lịch sắp tới, Hồ sơ tóc AI, Salon ruột
│   └── search_map/              # Tìm salon trên bản đồ, Bộ lọc đa tiêu chí, Chi tiết salon & thợ
├── models/                      # Domain Data Models (Bất biến - Immutable với copyWith, fromMap, toMap)
├── providers/                   # Các Riverpod Providers & StateNotifiers tầng ứng dụng
└── routing/                     # Cấu hình GoRouter (AppRouter, danh sách đường dẫn, redirect guards)
```

---

## 4. Quy Chuẩn Kỹ Thuật & Best Practices

### 4.1 Quản Lý Trạng Thái (Riverpod 2.x)
- Toàn bộ logic nghiệp vụ phải đặt trong `StateNotifier` hoặc `AsyncNotifier`. Tuyệt đối không thay đổi trạng thái trực tiếp trong Widget.
- Dùng `ref.watch` trong hàm `build()` để giao diện lắng nghe phản ứng; dùng `ref.read` trong các sự kiện callback (như `onPressed`, `onTap`).
- Khi tạo Provider lắng nghe luồng dữ liệu từ Firestore, ưu tiên sử dụng `StreamProvider.autoDispose` hoặc Family Providers để giải phóng bộ nhớ tự động, tiết kiệm lượt đọc Firestore.
- Trong các bài viết kiểm thử (Widget tests), luôn hỗ trợ khả năng ghi đè độc lập thông qua `ProviderScope(overrides: [...])`.

### 4.2 Data Models & Xử Lý Tuần Tự Hóa (Serialization)
- Mọi Data Model bắt buộc phải là lớp bất biến (immutable). Cần có đầy đủ:
  - Phương thức `copyWith()` để cập nhật dữ liệu an toàn.
  - Phương thức `fromMap(Map<String, dynamic> map, String id)` với giá trị fallback phòng hộ, không để văng lỗi khi thiếu trường dữ liệu.
  - Phương thức `toMap()` chuyển đổi dữ liệu chuẩn cho Firestore.
  - Xử lý enum bằng chuỗi ký tự (ví dụ: `AppointmentStatus.pending.name`).

### 4.3 Nhất Quán Trong Giao Diện & Thiết Kế (UI/UX)
- **Chuẩn Dark Mode**: Nền chính là `AppColors.background` (`#121212`), bề mặt card là `AppColors.surface` (`#1E1E1E`), màu nhấn thương hiệu là `AppColors.primary` (`#FF6B00` - Cam Hổ Phách) và `AppColors.accent`.
- Tuyệt đối không hardcode mã màu hoặc kích thước khoảng cách tùy tiện—luôn dùng các hằng số từ `AppColors`, `AppDimensions` và `AppTextStyles`.
- Thiết kế bố cục an toàn, chống tràn layout: Trên nhiều kích thước màn hình khác nhau, luôn bọc các phần tử linh hoạt bằng `Flexible`, `Expanded`, hoặc `SingleChildScrollView`.
- **Quy định Ngôn ngữ**:
  - Toàn bộ chuỗi văn bản giao diện, nhãn nút, thông báo, câu báo lỗi: **Tiếng Việt** (phong cách salon/barber chuyên nghiệp, lịch sự).
  - Tên biến, hàm, class, chú thích code (comments), commit messages: **Tiếng Anh**.

### 4.4 Giao Dịch Đặt Lịch & Xử Lý Đồng Thời Trên Firestore
- Trước khi khóa một khung giờ (slot), hệ thống bắt buộc phải kiểm tra:
  1. Trạng thái nhận khách của thợ trong ngày (`isAcceptingBookingsToday`).
  2. Khung giờ làm việc định kỳ (`workingHours`) và các ngày/giờ nghỉ đột xuất (`exceptions`).
  3. Các lượt đặt đang hoạt động trong bộ sưu tập `booked_slots`.
- Mọi thao tác ghi/cập nhật giữ chỗ slot phải được bao bọc trong `FirebaseFirestore.instance.runTransaction()`.

---

## 5. Lệnh Xác Thực Trước Khi Hoàn Tất Tác Vụ

Trước khi đánh dấu bất kỳ tính năng hay sửa đổi nào là hoàn tất, bạn bắt buộc phải thực thi chuỗi lệnh sau:
```bash
# 1. Phân tích tĩnh cú pháp, kiểm tra cảnh báo và quy chuẩn lint
flutter analyze

# 2. Chạy toàn bộ bộ test tự động (unit test & widget test)
flutter test

# 3. Định dạng lại mã nguồn theo chuẩn Dart
dart format .
```
Cả `flutter analyze` và `flutter test` đều phải vượt qua với **0 lỗi và 0 cảnh báo**.

---

## 6. Quy Tắc Hành Vi & Sử Dụng Tool Của Agent

1. **Giao Tiếp & Phản Hồi**:
   - Trả lời ngắn gọn, đúng trọng tâm — không lan man, không lặp lại context.
   - Luôn trả lời người dùng bằng **tiếng Việt** trừ khi có yêu cầu cụ thể khác.
   - Code, commit message, tên biến, tên hàm, class: giữ **tiếng Anh** theo chuẩn quốc tế.

2. **Tối Ưu Ngữ Cảnh & Đọc File**:
   - Đọc file có scope rõ ràng (dùng `StartLine`/`EndLine`, offset/limit khi file lớn), tuyệt đối tránh đọc toàn bộ file hàng trăm dòng khi chỉ cần xem một đoạn logic cụ thể.

3. **Sử Dụng Tool Hiệu Quả**:
   - Ưu tiên sử dụng tool chuyên dụng (`view_file`, `replace_file_content`, `grep_search`) thay vì dùng lệnh shell (`cat`, `sed`, `awk`, `powershell`) để thao tác với file.

4. **Quy Định Khi Tạo File Mới (Bắt Buộc Thêm Credit Note)**:
   - Mọi file mã nguồn mới được tạo ra trong dự án (đặc biệt là các file `.dart` trong `lib/` và `test/`), bắt buộc phải có dòng ghi chú credit ở cuối trang:
     ```dart
     // CreBy: MenBoyBMN
     ```
   - Đối với các định dạng file tài liệu hoặc cấu hình khác (`.md`, `.yaml`, `.py`, `.sh`), bổ sung comment credit tương ứng ở cuối file (ví dụ: `# CreBy: MenBoyBMN` hoặc `<!-- CreBy: MenBoyBMN -->`).

