# KỊCH BẢN KIỂM THỬ TOÀN DIỆN HỆ THỐNG — HAIRFIT AI
## Master System Test Scenarios & Phân Rã Công Việc Sau 5 Tuần Triển Khai
### Dành cho Nền Tảng Flutter Android | Firebase | 100% On-Device AI

> **Tài liệu tham chiếu:** `HairFit_AI_Timeline.md`, `HairFit_AI_Specification.md`, `HairFit_AI_Execution_Plan.md`  
> **Phiên bản:** v1.0 — Đánh giá nghiệm thu mốc hoàn thành Full Task 5 Tuần  
> **Ngày lập:** 2026-09-29  
> **Phạm vi kiểm thử:** Toàn bộ hệ sinh thái HairFit AI (Khách hàng, Thợ cắt tóc, Quản trị viên, On-Device AI Engine, Bản đồ OpenStreetMap, Firestore Transaction chống trùng slot)

---

## MỤC LỤC

1. [TỔNG QUAN HỆ THỐNG VÀ THỰC TẾ DỰ ÁN SAU 5 TUẦN](#1-tổng-quan-hệ-thống-và-thực-tế-dự-án-sau-5-tuần)
2. [CHI TIẾT CÁC PHẦN CỤ THỂ ĐÃ HOÀN THÀNH QUA 5 TUẦN](#2-chi-tiết-các-phần-cụ-thể-đã-hoàn-thành-qua-5-tuần)
   - [2.1 Tuần 1: Nền tảng + Kiến trúc + Firebase + Spike AI On-Device](#21-tuần-1-nền-tảng--kiến-trúc--firebase--spike-ai-on-device)
   - [2.2 Tuần 2: Hệ thống Auth + Hồ sơ thợ + Role-Based Routing + Admin duyệt](#22-tuần-2-hệ-thống-auth--hồ-sơ-thợ--role-based-routing--admin-duyệt)
   - [2.3 Tuần 3: Bản đồ OpenStreetMap + Tìm thợ + Khoảng cách Haversine + Home](#23-tuần-3-bản-đồ-openstreetmap--tìm-thợ--khoảng-cách-haversine--home)
   - [2.4 Tuần 4: Đặt lịch chống trùng Slot + Quản lý lịch hẹn + Transaction nguyên tử](#24-tuần-4-đặt-lịch-chống-trùng-slot--quản-lý-lịch-hẹn--transaction-nguyên-tử)
   - [2.5 Tuần 5: Tích hợp AI On-Device vào luồng chính + Nhân trắc học + Gợi ý](#25-tuần-5-tích-hợp-ai-on-device-vào-luồng-chính--nhân-trắc-học--gợi-ý)
3. [MÔI TRƯỜNG KIỂM THỬ & TIỀN ĐIỀU KIỆN (TEST ENVIRONMENT SETUP)](#3-môi-trường-kiểm-thử--tiền-điều-kiện-test-environment-setup)
4. [TỔNG HỢP KIỂM THỬ TỰ ĐỘNG (AUTOMATED TEST SUITE: 76/76 PASS)](#4-tổng-hợp-kiểm-thử-tự-động-automated-test-suite-7676-pass)
5. [KỊCH BẢN KIỂM THỬ CHI TIẾT THEO TỪNG PHÂN HỆ CHỨC NĂNG](#5-kịch-bản-kiểm-thử-chi-tiết-theo-từng-phân-hệ-chức-năng)
   - [PHÂN HỆ 1: Xác thực, Tài khoản & Phân quyền Điều hướng (Auth & Role Guards)](#phân-hệ-1-xác-thực-tài-khoản--phân-quyền-điều-hướng-auth--role-guards)
   - [PHÂN HỆ 2: Hồ sơ Thợ cắt tóc & Quy trình Phê duyệt của Admin](#phân-hệ-2-hồ-sơ-thợ-cắt-tóc--quy-trình-phê-duyệt-của-admin)
   - [PHÂN HỆ 3: Bản đồ OpenStreetMap, Định vị & Khám phá Salon](#phân-hệ-3-bản-đồ-openstreetmap-định-vị--khám-phá-salon)
   - [PHÂN HỆ 4: Bộ máy Sinh Slot, Đặt lịch & Chống trùng Slot Nguyên tử](#phân-hệ-4-bộ-máy-sinh-slot-đặt-lịch--chống-trùng-slot-nguyên-tử)
   - [PHÂN HỆ 5: AI Tư vấn Kiểu tóc 100% On-Device (ML Kit Contours & Nhân trắc học)](#phân-hệ-5-ai-tư-vấn-kiểu-tóc-100-on-device-ml-kit-contours--nhân-trắc-học)
   - [PHÂN HỆ 6: Vòng đời Lịch hẹn & Đồng bộ Trạng thái Khách - Thợ](#phân-hệ-6-vòng-đời-lịch-hẹn--đồng-bộ-trạng-thái-khách---thợ)
6. [KỊCH BẢN KIỂM THỬ TÍCH HỢP END-TO-END (INTEGRATED E2E JOURNEYS)](#6-kịch-bản-kiểm-thử-tích-hợp-end-to-end-integrated-e2e-journeys)
   - [E2E-01: Hành trình Khách hàng Hoàn chỉnh (AI Consult → Chọn Kiểu → Chọn Thợ → Đặt Lịch)](#e2e-01-hành-trình-khách-hàng-hoàn-chỉnh-ai-consult--chọn-kiểu--chọn-thợ--đặt-lịch)
   - [E2E-02: Hành trình Thợ tiếp nhận, Xác nhận và Hoàn tất phục vụ](#e2e-02-hành-trình-thợ-tiếp-nhận-xác-nhận-và-hoàn-tất-phục-vụ)
   - [E2E-03: Kiểm thử Tranh chấp Slot Đồng thời (Concurrency & Race Condition Collision)](#e2e-03-kiểm-thử-tranh-chấp-slot-đồng-thời-concurrency--race-condition-collision)
   - [E2E-04: Hủy lịch & Tái cấp phát Slot tức thì (Reclaim Available Slot)](#e2e-04-hủy-lịch--tái-cấp-phát-slot-tức-thì-reclaim-available-slot)
   - [E2E-05: Kiểm thử Khả năng Chịu lỗi & Hoạt động Ngoại tuyến (Offline & Degraded Network)](#e2e-05-kiểm-thử-khả-năng-chịu-lỗi--hoạt-động-ngoại-tuyến-offline--degraded-network)
   - [E2E-06: Kiểm thử Bảo mật Firestore Rules & Ngăn chặn Leo thang Đặc quyền](#e2e-06-kiểm-thử-bảo-mật-firestore-rules--ngăn-chặn-leo-thang-đặc-quyền)
7. [MA TRẬN KIỂM THỬ TỔNG HỢP & TIÊU CHÍ NGHIỆM THU MILESTONE 5 TUẦN](#7-ma-trận-kiểm-thử-tổng-hợp--tiêu-chí-nghiệm-thu-milestone-5-tuần)

---

## 1. TỔNG QUAN HỆ THỐNG VÀ THỰC TẾ DỰ ÁN SAU 5 TUẦN

Dự án **HairFit AI** được thiết kế và triển khai theo mô hình Clean Architecture (Feature-First) trên nền tảng Flutter 3.x, hướng đến đối tượng người dùng Android (minSdk 26). Toàn bộ hệ thống được hoàn thiện sau **5 tuần làm việc tập trung (Full Tasks Week 1 → Week 5)** với 3 trụ cột kỹ thuật then chốt:

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                   HAIRFIT AI — CORE ECOSYSTEM                                   │
├───────────────────────────────┬─────────────────────────────────┬───────────────────────────────┤
│    1. 100% ON-DEVICE AI       │    2. BẢN ĐỒ OPENSTREETMAP      │  3. ĐẶT LỊCH CHỐNG TRÙNG     │
│  - ML Kit 132 Face Contours   │  - flutter_map + OSM Tiles 0đ   │  - Slot 30 phút, Lead time 30m│
│  - Phân tích nhân trắc 4-Band │  - Haversine Distance Calc      │  - Firestore Client Transact  │
│  - Rule Matrix Expert Engine  │  - Filter thợ theo AI Hairstyle │  - BookedSlots Lock ID        │
│  - Tốc độ cực nhanh < 60ms    │  - Bottom Sheet & Detail view   │  - Tự giải phóng khi hủy/hết  │
└───────────────────────────────┴─────────────────────────────────┴───────────────────────────────┘
```

### Các thông số kiến trúc thực tế:
- **Ngôn ngữ & Framework:** Flutter 3.x, Dart 3.x.
- **Quản lý trạng thái (State Management):** `flutter_riverpod: ^2.5.0` (phân tách rõ Providers cho Auth, Home, AI Consult, Search Map, Booking, Appointments, Admin).
- **Điều hướng (Routing):** `go_router: ^14.0.0` với cơ chế **Role Guard tự động** (Customer Shell, Barber Shell, Admin Shell, Chặn tài khoản Blocked).
- **Backend & Database:** Google Firebase (Firebase Auth, Cloud Firestore) — Không phụ thuộc Backend server riêng.
- **Bảo mật cơ sở dữ liệu:** Hệ thống `firestore.rules` chặt chẽ, kiểm soát quyền truy cập theo vai trò (`customer`, `barber`, `admin`), cấm ghi đè dữ liệu nhạy cảm (`isBlocked`, `role`, `approvalStatus`).
- **Hiện trạng kiểm thử mã nguồn:** Toàn bộ **76 unit & widget tests** chạy vượt qua 100% (`All tests passed!`).

---

## 2. CHI TIẾT CÁC PHẦN CỤ THỂ ĐÃ HOÀN THÀNH QUA 5 TUẦN

Dưới đây là bảng tổng hợp chi tiết các thành phần, thư mục, tệp nguồn và logic nghiệp vụ cụ thể đã được hiện thực hóa qua từng tuần triển khai:

### 2.1 Tuần 1: Nền tảng + Kiến trúc + Firebase + Spike AI On-Device
* **Mục tiêu:** Xây dựng hạ tầng lõi, cấu hình Firebase, thiết kế Design System tokens, Domain Models và tiến hành Spike chứng minh tính khả thi của On-Device AI trên thiết bị thật.
* **Các file và module cụ thể đã hoàn thành:**
  1. `lib/core/constants/app_colors.dart`: Bảng màu chuẩn phong cách Dark Navy (`#1A1A2E`), Accent Coral Red (`#E94560`), Surface White, v.v.
  2. `lib/core/constants/app_text_styles.dart`: Typography chuẩn tỷ lệ và font chữ tiếng Việt.
  3. `lib/core/constants/app_dimensions.dart`: Spacing tokens (`xs`, `sm`, `md`, `lg`, `xl`) và border-radius tokens (`8.0`, `12.0`, `16.0`).
  4. `lib/core/constants/business_constants.dart`: Các hằng số nghiệp vụ then chốt (`slotMinutes = 30`, `leadTimeMinutes = 30`, `maxBookingDaysAhead = 30`, `maxActiveBookingsPerCustomer = 2`, `timezone = Asia/Ho_Chi_Minh`).
  5. `lib/core/theme/app_theme.dart`: `ThemeData` hoàn chỉnh hỗ trợ hiển thị đồng nhất.
  6. `lib/core/widgets/`: Bộ thư viện dùng chung: `app_button.dart`, `app_text_field.dart`, `loading_shimmer.dart`, `empty_state.dart`, `error_retry.dart`, `status_badge.dart`, `rating_stars.dart`.
  7. `lib/models/`: Định nghĩa toàn bộ 6 domain models có phương thức `fromMap`, `toMap`, `copyWith`:
     - `user_model.dart`: Người dùng với vai trò `customer`, `barber`, `admin`, cờ `isBlocked`.
     - `barber_profile_model.dart`: Hồ sơ tiệm tóc, tọa độ `GeoLocation`, giờ mở cửa theo ngày, danh sách dịch vụ, trạng thái duyệt.
     - `hairstyle_model.dart`: Kiểu tóc trong catalog (id, tên, mô tả, ảnh, dáng mặt tương thích `faceShapes`, tags, active).
     - `service_model.dart`: Dịch vụ thợ cung cấp (id, tên, giá tiền, `durationMinutes` là bội số 30).
     - `appointment_model.dart`: Lịch hẹn (id, customerId, barberId, service, date, startTime, endTime, timestamps, slotIds, status).
     - `booked_slot_model.dart`: Slot giờ bị khóa theo format `{barberId}_{yyyy-MM-dd}_{HH-mm}`.
  8. `lib/core/services/seed_data_service.dart`: Khởi tạo sẵn 10 kiểu tóc chuẩn quốc tế và 5 thợ cắt tóc thực tế tại trung tâm Đà Nẵng.
  9. `lib/features/ai_consult/presentation/ai_spike_test_screen.dart`: Spike AI On-Device thử nghiệm kiểm tra tính tương thích của ML Kit và thuật toán hình học trên máy Android thật.
  10. `lib/core/services/firebase_service.dart` & `lib/core/services/firebase_options.dart`: Tích hợp Firebase.

---

### 2.2 Tuần 2: Hệ thống Auth + Hồ sơ thợ + Role-Based Routing + Admin duyệt
* **Mục tiêu:** Xây dựng luồng đăng ký/đăng nhập, phân loại vai trò, hồ sơ năng lực thợ cắt tóc, màn hình duyệt hồ sơ cho Quản trị viên và rào cản phân quyền.
* **Các file và module cụ thể đã hoàn thành:**
  1. `lib/core/services/auth_service.dart`: Xử lý Firebase Auth (`registerWithEmail`, `loginWithEmail`, `logout`, `sendPasswordReset`, kiểm tra `isBlocked`).
  2. `lib/features/auth/data/auth_repository.dart` & `lib/providers/auth_provider.dart`: Quản lý trạng thái xác thực bằng StateNotifier/AsyncNotifier trong Riverpod.
  3. `lib/features/auth/presentation/login_screen.dart`: Giao diện đăng nhập, validate email/mật khẩu, xử lý hiển thị lỗi trực quan.
  4. `lib/features/auth/presentation/register_screen.dart`: Giao diện đăng ký tài khoản với nút lựa chọn vai trò (Khách hàng / Thợ cắt tóc).
  5. `lib/features/auth/presentation/forgot_password_screen.dart`: Gửi liên kết khôi phục mật khẩu qua email.
  6. `lib/features/auth/presentation/splash_screen.dart`: Splash điều hướng tự động dựa vào phiên đăng nhập và trạng thái tài khoản.
  7. `lib/routing/app_router.dart`: Thiết lập **GoRouter** với bộ lọc phân quyền nghiêm ngặt:
     - Chưa login không được vào route nghiệp vụ.
     - Tài khoản `isBlocked = true` bị ép quay lại màn hình Login.
     - Role Barber chưa duyệt bị chặn ở `/barber/pending`.
     - Chặn chéo: Customer không thể truy cập `/admin/*` hay `/barber/*`, Barber không thể truy cập `/admin/*`.
  8. `lib/features/barber_profile/data/barber_profile_repository.dart`: Truy vấn và cập nhật Firestore collection `barberProfiles`.
  9. `lib/features/barber_profile/presentation/barber_registration_screen.dart`: Form đăng ký hồ sơ thợ cắt tóc (Tên, địa chỉ, chọn vị trí trên bản đồ, dịch vụ, kiểu tóc, giờ làm việc).
  10. `lib/features/barber_profile/presentation/widgets/`:
      - `location_picker.dart`: Chọn tọa độ địa lý trực tiếp bằng cách ghim điểm trên bản đồ.
      - `service_editor.dart`: Trình quản lý dịch vụ động (Thêm/Sửa/Xóa, ép buộc thời lượng bội số của 30 phút).
      - `hairstyle_picker.dart`: Lựa chọn danh sách kiểu tóc tiệm có thể cắt từ Hairstyle Catalog.
      - `working_hours_editor.dart`: Cài đặt thời gian mở/đóng cửa cho từng ngày trong tuần (Thứ 2 đến Chủ nhật) kèm toggle nghỉ lễ.
  11. `lib/features/barber_profile/presentation/barber_pending_screen.dart`: Màn hình thông báo hồ sơ đang trong trạng thái chờ quản trị viên xét duyệt.
  12. `lib/features/admin/presentation/approve_barbers_screen.dart` & `lib/providers/admin_provider.dart`: Dashboard dành cho Admin duyệt (`approved`) hoặc từ chối (`rejected`) hồ sơ thợ.
  13. `firestore.rules`: Quy tắc bảo mật Firestore ngăn chặn người dùng tự ý đổi `role` hoặc tự gỡ cờ `isBlocked`.

---

### 2.3 Tuần 3: Bản đồ OpenStreetMap + Tìm thợ + Khoảng cách Haversine + Home
* **Mục tiêu:** Hiện thực hóa khả năng tìm kiếm thợ cắt tóc xung quanh vị trí thực tế của khách hàng bằng OpenStreetMap (hoàn toàn miễn phí, 0đ chi phí Google Maps API) và màn hình trang chủ.
* **Các file và module cụ thể đã hoàn thành:**
  1. `lib/core/services/location_service.dart`: Xin quyền người dùng (`ACCESS_FINE_LOCATION`), lấy tọa độ GPS hiện tại qua `geolocator`, thiết lập vị trí fallback tại Đà Nẵng khi bị từ chối quyền.
  2. `lib/core/utils/distance_helper.dart`: Công thức toán học Haversine tính toán khoảng cách địa lý chính xác (km) giữa vị trí khách và tiệm thợ.
  3. `lib/core/services/tile_server_config.dart`: Cấu hình máy chủ Tile Map mã nguồn mở của OpenStreetMap với User-Agent chuẩn.
  4. `lib/features/search_map/data/barber_repository.dart`: Truy vấn các tiệm thợ có `approvalStatus == 'approved'`.
  5. `lib/providers/search_provider.dart`: State quản lý danh sách thợ, tính toán khoảng cách tự động và lọc theo kiểu tóc `selectedHairstyleId`.
  6. `lib/features/search_map/presentation/search_map_screen.dart`: Màn hình bản đồ tích hợp `flutter_map` trực quan, cho phép chuyển đổi linh hoạt giữa chế độ Bản đồ (Map View) và Danh sách (List View).
  7. `lib/features/search_map/presentation/widgets/`:
     - `map_marker.dart`: Marker tùy chỉnh hiển thị vị trí của tiệm tóc trên bản đồ kèm giá khởi điểm.
     - `barber_bottom_sheet.dart`: Bottom sheet trượt lên khi bấm vào marker tiệm (hiển thị ảnh đại diện, khoảng cách, sao đánh giá, nút đặt lịch).
     - `barber_card.dart`: Thẻ hiển thị thông tin tóm tắt tiệm trong danh sách, có huy hiệu "Phù hợp" nếu tiệm hỗ trợ kiểu tóc từ AI.
     - `barber_list_view.dart`: Danh sách thợ được tự động sắp xếp theo thứ tự khoảng cách từ gần đến xa.
  8. `lib/features/search_map/presentation/barber_detail_screen.dart`: Chi tiết hồ sơ tiệm tóc (Địa chỉ, số điện thoại, giờ mở cửa các ngày, danh mục dịch vụ có nút Đặt lịch nhanh).
  9. `lib/features/home/presentation/customer_home_screen.dart`: Trang chủ Khách hàng với Banner lớn kêu gọi tư vấn AI ("Tìm kiểu tóc hợp mặt bạn trong 60 giây"), danh mục kiểu tóc thịnh hành và gợi ý top thợ gần bạn.

---

### 2.4 Tuần 4: Đặt lịch chống trùng Slot + Quản lý lịch hẹn + Transaction nguyên tử
* **Mục tiêu:** Xây dựng lõi nghiệp vụ then chốt nhất của ứng dụng: Thuật toán sinh slot thời gian thực và Firestore Transaction nguyên tử ngăn chặn tuyệt đối tình trạng đặt trùng lịch (Race Condition).
* **Các file và module cụ thể đã hoàn thành:**
  1. `lib/features/booking/data/slot_service.dart`: Thuật toán sinh slot khả dụng:
     - Chia ca làm việc thành các block 30 phút.
     - Kiểm tra ngày nghỉ định kỳ hoặc ngày ngoại lệ (`exceptions`).
     - Hỗ trợ dịch vụ kéo dài nhiều slot liên tiếp (ví dụ 60 phút = 2 slot, 90 phút = 3 slot).
     - Chặn đặt lịch trong quá khứ và các slot có thời gian bắt đầu cách hiện tại < 30 phút (`leadTimeMinutes = 30`).
     - Giới hạn đặt trước tối đa 30 ngày (`maxBookingDaysAhead = 30`).
     - Loại bỏ các slot đã có ID trong collection `bookedSlots`.
  2. `lib/features/booking/data/booking_repository.dart`: Lõi giao dịch Firestore Transaction:
     - Kiểm tra điều kiện khách hàng không vượt quá 2 lịch hẹn đang kích hoạt (`pending` hoặc `confirmed`).
     - Chạy `firestore.runTransaction()`: Đọc kiểm tra sự tồn tại của từng slot trong danh sách slot cần đặt (`bookedSlots/{barberId}_{yyyy-MM-dd}_{HH-mm}`).
     - Nếu bất kỳ slot nào đã tồn tại → Ném ngoại lệ `SlotAlreadyBookedException` ngay lập tức, hủy toàn bộ giao dịch.
     - Nếu slot còn trống → Ghi đồng thời bản ghi vào `appointments` (status: `pending`) và tạo các document khóa tương ứng trong `bookedSlots`.
     - Transaction hủy lịch: Kiểm tra ràng buộc thời gian (phải hủy trước giờ hẹn tối thiểu 30 phút), cập nhật trạng thái appointment thành `cancelled` và xóa sạch các document trong `bookedSlots` để giải phóng chỗ cho người khác.
  3. `lib/providers/booking_provider.dart`: State machine điều phối quy trình đặt lịch từng bước: Chọn dịch vụ → Chọn ngày → Chọn slot → Tóm tắt thông tin → Xác nhận giao dịch.
  4. `lib/features/booking/presentation/booking_screen.dart`: Giao diện đặt lịch dạng Stepper mượt mà, đầy đủ loading shimmer và thông báo trạng thái.
  5. `lib/features/booking/presentation/widgets/`:
     - `service_selector.dart`: Danh sách chọn dịch vụ cần cắt kèm giá và thời lượng.
     - `date_picker.dart`: Lựa chọn ngày cắt tóc trong phạm vi 30 ngày tới.
     - `time_slot_grid.dart`: Lưới hiển thị các khung giờ khả dụng (ô xanh: trống, ô xám: đã kín, ô mờ: quá hạn).
     - `booking_summary.dart`: Bảng tóm tắt tổng chi phí, thời gian phục vụ và ô nhập ghi chú cho thợ.
  6. `lib/features/appointments/data/appointment_repository.dart` & `lib/providers/appointment_provider.dart`: Quản lý danh sách lịch hẹn theo từng người dùng (khách hoặc thợ).
  7. `lib/features/appointments/presentation/customer_appointments_screen.dart`: Quản lý danh sách lịch hẹn của Khách hàng, lọc theo trạng thái, tích hợp nút "Hủy lịch hẹn" với hộp thoại xác nhận.
  8. `lib/features/appointments/presentation/barber_appointments_screen.dart`: Quản lý lịch hẹn của Thợ cắt tóc, cung cấp các nút thao tác: "Xác nhận lịch" (`confirmed`), "Từ chối lịch" (`rejected` → giải phóng slot), "Hoàn tất cắt tóc" (`completed`).
  9. `lib/features/appointments/presentation/widgets/appointment_card.dart`: Thẻ hiển thị lịch hẹn trực quan với badge trạng thái màu tương ứng (`pending` vàng, `confirmed` xanh dương, `completed` xanh lá, `cancelled`/`rejected` đỏ).

---

### 2.5 Tuần 5: Tích hợp AI On-Device vào luồng chính + Nhân trắc học + Gợi ý
* **Mục tiêu:** Hoàn thiện pipeline tư vấn tạo mẫu tóc 100% On-Device AI với thời gian phản hồi tức thì (< 60ms), độ bảo mật quyền riêng tư tuyệt đối (ảnh chân dung không bao giờ rời khỏi máy) và kết nối mượt mà sang Bản đồ tìm thợ.
* **Các file và module cụ thể đã hoàn thành:**
  1. `lib/features/ai_consult/domain/face_shape.dart`: Enum 5 dáng mặt chuẩn nhân trắc học: `oval` (Trái xoan), `round` (Tròn), `square` (Vuông), `heart` (Trái tim), `oblong` (Dài); kèm mô tả đặc trưng và lời khuyên tổng quát bằng tiếng Việt.
  2. `lib/features/ai_consult/data/face_validation_service.dart`: Người gác cổng ML Kit Face Detection:
     - Bắt buộc kiểm tra có khuôn mặt trong khung hình (`faces.isNotEmpty`).
     - Kiểm tra kích thước khuôn mặt: Bounding box tối thiểu 100px.
     - Kiểm tra góc nghiêng Euler Y (quay đầu trái/phải không quá 20°) và Euler X (ngửa/cúi đầu không quá 15°).
     - Trích xuất 132 điểm viền đường nét khuôn mặt (`FaceContourType.face`).
  3. `lib/features/ai_consult/domain/face_shape_analyzer.dart`: Bộ chẩn đoán hình học nhân trắc học (Anatomical Slicing):
     - Phân chia 36 điểm viền dọc trục Y thành 4 phân vùng: Trán ($W_{forehead}$), Gò má ($W_{cheek}$), Quai hàm ($W_{jaw}$), Cằm ($W_{chin}$).
     - Đo đạc các tỷ lệ định lượng: Tỷ lệ Dài/Rộng ($H / W_{cheek}$), Tỷ lệ Trán/Hàm ($W_{forehead} / W_{jaw}$), Độ vuông xương hàm ($W_{jaw} / W_{cheek}$), Độ thuôn cằm ($W_{chin} / W_{jaw}$).
     - Áp dụng bộ quy tắc toán học phân loại chính xác 5 dáng mặt trong thời gian < 10ms.
  4. `lib/features/ai_consult/domain/hairstyle_recommendation_engine.dart`: Ma trận quy tắc chuyên gia HairFit AI:
     - Đối soát dáng mặt chẩn đoán với catalog kiểu tóc.
     - Lọc theo giới tính (`male`, `female`, `unisex`), độ dài tóc mong muốn và chất tóc.
     - Tính điểm tương thích (Match Score) và chọn ra Top 3 kiểu tóc tối ưu nhất.
     - Tự động sinh lý do tạo mẫu tóc chuyên sâu và mẹo vuốt sáp/tạo phồng thực tế.
  5. `lib/features/ai_consult/domain/ai_consult_result.dart`: Mô hình hóa kết quả phân tích sealed class (`AIConsultSuccess`, `AIConsultValidationFailure`, `AIConsultError`).
  6. `lib/features/ai_consult/domain/ai_consultant_service.dart`: Orchestrator điều phối toàn bộ chuỗi On-Device AI xử lý trọn vẹn trong < 60ms.
  7. `lib/features/ai_consult/data/hairstyle_repository.dart`: Đọc danh mục kiểu tóc từ Firestore hoặc cache ngoại tuyến.
  8. `lib/providers/ai_consult_provider.dart`: StateNotifier quản lý quy trình tư vấn AI từ lúc chọn ảnh đến khi hiển thị kết quả.
  9. `lib/features/ai_consult/presentation/ai_consult_screen.dart`:
     - Hộp thoại cam kết bảo mật quyền riêng tư (Privacy Consent Popup) lưu trạng thái qua `SharedPreferences`.
     - Bộ chọn thuộc tính phụ: Giới tính, độ dài tóc hiện tại, chất tóc (`hair_info_selector.dart`).
     - Tùy chọn nguồn ảnh: Chụp từ Camera hoặc chọn ảnh chân dung từ Thư viện Gallery.
     - Nút chuyển hướng sang chế độ "Chọn dáng mặt thủ công" nếu không muốn chụp ảnh.
  10. `lib/features/ai_consult/presentation/widgets/face_camera_overlay.dart`: Khung viền oval hướng dẫn người dùng căn chỉnh khuôn mặt vào đúng vị trí tối ưu.
  11. `lib/features/ai_consult/presentation/ai_result_screen.dart`:
      - Card hiển thị dáng mặt phát hiện kèm giải thích đặc trưng hình học.
      - Danh sách 3 kiểu tóc gợi ý với hình ảnh minh họa, điểm phù hợp, lý do chuyên gia (`hairstyle_result_card.dart`).
      - Hướng dẫn tạo kiểu và lời khuyên kiểu tóc nên tránh.
      - Nút CTA then chốt: **"Tìm thợ cắt kiểu này"** — Chuyển thẳng sang Bản đồ tìm kiếm và truyền `hairstyleId` để lọc salon phù hợp!
  12. `lib/features/ai_consult/presentation/manual_select_screen.dart`: Chế độ Fallback cứu cánh khi thiết bị hỏng camera hoặc người dùng từ chối cấp quyền, cho phép chọn trực quan 5 dáng mặt và lập tức nhận gợi ý kiểu tóc từ Engine.

---

## 3. MÔI TRƯỜNG KIỂM THỬ & TIỀN ĐIỀU KIỆN (TEST ENVIRONMENT SETUP)

Trước khi thực thi các kịch bản kiểm thử, môi trường phải được chuẩn bị theo đúng các tham số sau:

### 3.1 Thiết bị kiểm thử (Hardware & OS)
| Thành phần | Yêu cầu kiểm thử | Ghi chú |
|---|---|---|
| **Thiết bị thật 1 (Device A)** | Android 10+ (API 29 - 34), có Camera hoạt động tốt | Dùng kiểm thử Camera ML Kit, GPS thật, luồng Khách hàng |
| **Thiết bị thật 2 / Emulator (Device B)** | Android 8.0+ (minSdk API 26) | Dùng đóng vai Thợ cắt tóc để kiểm thử tương tác 2 chiều và tranh chấp slot |
| **Mạng Internet** | Wi-Fi / 4G LTE ổn định | Có kịch bản kiểm tra ngắt mạng (Airplane Mode) để test AI On-Device |

### 3.2 Bộ Dữ liệu & Tài khoản Kiểm thử (Test Accounts)
Hệ thống sử dụng các tài khoản kiểm thử đã cấu hình theo vai trò:

| Tài khoản | Email | Mật khẩu mặc định | Vai trò (Role) | Trạng thái hồ sơ |
|---|---|---|---|---|
| **Admin** | `admin@hairfit.com` | `Admin@123456` | `admin` | Toàn quyền duyệt thợ |
| **Khách hàng 1** | `customer1@hairfit.com` | `Pass@123456` | `customer` | `isBlocked = false` |
| **Khách hàng 2** | `customer2@hairfit.com` | `Pass@123456` | `customer` | Dùng test tranh chấp slot cùng lúc |
| **Thợ đã duyệt (Barber 1)** | `barber1@hairfit.com` | `Pass@123456` | `barber` | `approvalStatus = 'approved'` (UID: `barber_danang_01`) |
| **Thợ chờ duyệt (Barber Pending)**| `barber_pending@hairfit.com` | `Pass@123456` | `barber` | `approvalStatus = 'pending'` |
| **Tài khoản bị khóa** | `blocked_user@hairfit.com` | `Pass@123456` | `customer` | `isBlocked = true` |

### 3.3 Thiết lập Tiền dữ liệu (Seed Data)
1. Chạy dịch vụ `SeedDataService().seedAll(overwrite: true)` để đảm bảo:
   - Collection `hairstyleCatalog`: Đủ 10 kiểu tóc (`undercut`, `side_part`, `pompadour`, `layer_male`, `two_block`, `french_crop`, `buzz_cut`, `mullet_modern`, `quiff`, `slicked_back`).
   - Collection `barberProfiles`: Đủ 5 thợ tại Đà Nẵng với đầy đủ tọa độ, giờ làm việc và dịch vụ bội số 30 phút.
2. Xóa các bản ghi rác trong `appointments` và `bookedSlots` trước mỗi chu kỳ kiểm thử toàn diện.

---

## 4. TỔNG HỢP KIỂM THỬ TỰ ĐỘNG (AUTOMATED TEST SUITE: 76/76 PASS)

Trước khi thực hiện kiểm thử thủ công, bộ kiểm thử tự động đã xác minh tính đúng đắn ở tầng Unit & Widget:

```
[TEST SUMMARY REPORT - AUTOMATED SUITE]
----------------------------------------------------------------------------------------------------
Test File                         Scope & Functionality Tested                             Cases  Result
----------------------------------------------------------------------------------------------------
core_utils_test.dart              Validators (email, phone, pass), DateFormatter             12    PASS
distance_helper_test.dart         Haversine formula, geo precision, edge coordinates          4    PASS
tile_server_config_test.dart      OpenStreetMap URL template, subdomains, user-agent          3    PASS
models_test.dart                  Serialization/Deserialization for all 6 domain models      14    PASS
slot_service_test.dart            Slot generator, working hours, 30/60/90min multi-slots     10    PASS
ai_domain_test.dart               FaceShapeAnalyzer 4-Band ratios & Rule Matrix Engine        9    PASS
search_provider_test.dart         Distance sorting, hairstyle filter, state changes           4    PASS
booking_provider_test.dart        Booking step progression, state machine validations         4    PASS
ai_consult_provider_test.dart     AI flow state, image picking, consultation orchestrator     4    PASS
widget_test.dart                  Shared core widgets (Buttons, Shimmer, Empty, Badges)       6    PASS
booking_widgets_test.dart         ServiceSelector, TimeSlotGrid, BookingSummary, ApptCard     4    PASS
ai_consult_widgets_test.dart      FaceCameraOverlay, AIResultScreen, HairstyleResultCard      2    PASS
----------------------------------------------------------------------------------------------------
TỔNG CỘNG:                                                                                  76/76  PASS (100%)
----------------------------------------------------------------------------------------------------
```

---

## 5. KỊCH BẢN KIỂM THỬ CHI TIẾT THEO TỪNG PHÂN HỆ CHỨC NĂNG

---

### PHÂN HỆ 1: Xác thực, Tài khoản & Phân quyền Điều hướng (Auth & Role Guards)

#### Test Case TC-AUTH-01: Đăng ký tài khoản Khách hàng mới (Customer Registration)
* **Độ ưu tiên:** P0 (Chặn toàn bộ nếu lỗi)
* **Tiền điều kiện:** Ứng dụng đã cài đặt trên thiết bị, mở màn hình đăng ký (`/register`).
* **Các bước thực hiện:**
  1. Nhập email: `new_customer@test.com`.
  2. Nhập mật khẩu: `123456`.
  3. Chọn Chip vai trò: "Khách hàng".
  4. Nhấn nút "Đăng ký".
* **Kết quả mong đợi:**
  - Nút hiển thị loading spinner trong khi gửi yêu cầu.
  - Document người dùng được tạo trong Firestore collection `users` với `role: 'customer'`, `isBlocked: false`.
  - Hệ thống tự động điều hướng sang Trang chủ Khách hàng (`/customer/home`).

#### Test Case TC-AUTH-02: Đăng nhập sai mật khẩu & Xử lý lỗi
* **Độ ưu tiên:** P0
* **Tiền điều kiện:** Mở màn hình đăng nhập (`/login`).
* **Các bước thực hiện:**
  1. Nhập email: `customer1@hairfit.com`.
  2. Nhập mật khẩu sai: `SaiPassword999`.
  3. Nhấn "Đăng nhập".
* **Kết quả mong đợi:**
  - Không bị crash app.
  - Hiển thị Snackbar hoặc thông báo lỗi: "Mật khẩu không chính xác hoặc tài khoản không tồn tại".
  - Giữ nguyên người dùng ở màn hình Login, cho phép nhập lại.

#### Test Case TC-AUTH-03: Chặn truy cập với Tài khoản bị Khóa (`isBlocked == true`)
* **Độ ưu tiên:** P0 (Bảo mật)
* **Tiền điều kiện:** Tài khoản `blocked_user@hairfit.com` có trường `isBlocked: true` trong Firestore.
* **Các bước thực hiện:**
  1. Tại màn hình `/login`, nhập `blocked_user@hairfit.com` và mật khẩu `Pass@123456`.
  2. Nhấn "Đăng nhập".
* **Kết quả mong đợi:**
  - Hệ thống kiểm tra quyền sau khi Auth thành công.
  - Phát hiện `isBlocked: true` → Lập tức gọi `auth.signOut()`.
  - Hiển thị thông báo màu đỏ cảnh báo: "Tài khoản của bạn đã bị tạm khóa. Vui lòng liên hệ hỗ trợ".
  - Người dùng tuyệt đối không thể lọt vào bất kỳ màn hình Dashboard nào bên trong.

#### Test Case TC-AUTH-04: Role Guard — Ngăn chặn truy cập trái phép chéo vai trò
* **Độ ưu tiên:** P0
* **Tiền điều kiện:** Đăng nhập bằng tài khoản Khách hàng (`customer1@hairfit.com`).
* **Các bước thực hiện:**
  1. Thử can thiệp điều hướng sâu bằng Deep link hoặc GoRouter path: `/admin/approve-barbers`.
  2. Thử truy cập route của thợ: `/barber/appointments`.
* **Kết quả mong đợi:**
  - GoRouter RouterNotifier kích hoạt kiểm tra: User không có quyền `admin` hoặc `barber`.
  - Ngăn chặn truy cập tức thì, tự động đá ngược về `/customer/home`.

---

### PHÂN HỆ 2: Hồ sơ Thợ cắt tóc & Quy trình Phê duyệt của Admin

#### Test Case TC-BARBER-01: Đăng ký tài khoản Thợ & Tạo hồ sơ tiệm tóc ban đầu
* **Độ ưu tiên:** P0
* **Tiền điều kiện:** Chưa có tài khoản, mở `/register`.
* **Các bước thực hiện:**
  1. Đăng ký tài khoản với email `new_barber@hairfit.com`, chọn vai trò "Thợ cắt tóc".
  2. Sau khi tạo tài khoản thành công, hệ thống điều hướng vào `/barber/profile-setup`.
  3. Nhập Tên tiệm: "Barber Hoàng Gia".
  4. Nhập Địa chỉ: "124 Hùng Vương, Đà Nẵng".
  5. Mở bản đồ ghim vị trí: Chọn tọa độ gần vị trí mong muốn.
  6. Thêm dịch vụ: Tên "Cắt tỉa râu tóc", Giá `90,000đ`, Thời lượng `60 phút`.
  7. Chọn kiểu tóc hỗ trợ: Tích chọn "Undercut Cổ Điển", "Side Part 7/3".
  8. Cài đặt giờ làm việc: Thứ 2 - Thứ 7 mở từ `09:00` đến `20:00`.
  9. Nhấn "Gửi hồ sơ xét duyệt".
* **Kết quả mong đợi:**
  - Bản ghi được tạo trong `barberProfiles` với `approvalStatus: 'pending'`.
  - Hệ thống tự động chuyển người dùng sang màn hình chờ duyệt `/barber/pending`.
  - Khách hàng tìm kiếm trên bản đồ vào thời điểm này **hoàn toàn không nhìn thấy** tiệm này.

#### Test Case TC-BARBER-02: Validate dịch vụ thợ — Bắt buộc bội số 30 phút
* **Độ ưu tiên:** P0
* **Tiền điều kiện:** Đang ở màn hình soạn thảo dịch vụ `service_editor.dart`.
* **Các bước thực hiện:**
  1. Thêm dịch vụ mới.
  2. Nhập thời lượng là `45 phút` hoặc `75 phút`.
  3. Nhấn Lưu dịch vụ.
* **Kết quả mong đợi:**
  - Form báo lỗi validation ngay tại chỗ: "Thời lượng dịch vụ bắt buộc phải là bội số của 30 phút (30, 60, 90, 120 phút)".
  - Không cho phép lưu dịch vụ có thời lượng không hợp lệ.

#### Test Case TC-BARBER-03: Admin xét duyệt hồ sơ thợ (Approve Flow)
* **Độ ưu tiên:** P0
* **Tiền điều kiện:** Đăng nhập tài khoản `admin@hairfit.com`, mở `/admin/approve-barbers`.
* **Các bước thực hiện:**
  1. Màn hình hiển thị danh sách các hồ sơ đang ở trạng thái `pending`.
  2. Bấm vào hồ sơ "Barber Hoàng Gia" vừa tạo ở TC-BARBER-01 để xem chi tiết.
  3. Nhấn nút xanh "Phê duyệt" (Approve).
* **Kết quả mong đợi:**
  - Hiển thị hộp thoại xác nhận phê duyệt.
  - Document `barberProfiles/new_barber_id` được cập nhật `approvalStatus = 'approved'`.
  - Hồ sơ biến mất khỏi danh sách chờ duyệt của Admin.
  - Ngay lập tức, tiệm tóc xuất hiện trên Bản đồ OpenStreetMap của Khách hàng.

---

### PHÂN HỆ 3: Bản đồ OpenStreetMap, Định vị & Khám phá Salon

#### Test Case TC-MAP-01: Hiển thị bản đồ OpenStreetMap & Marker các tiệm đã duyệt
* **Độ ưu tiên:** P0
* **Tiền điều kiện:** Đăng nhập tài khoản Khách hàng, vào tab "Bản đồ" (`/customer/search`).
* **Các bước thực hiện:**
  1. Cấp quyền truy cập vị trí khi hệ thống yêu cầu (`ACCESS_FINE_LOCATION`).
  2. Quan sát giao diện bản đồ.
* **Kết quả mong đợi:**
  - Bản đồ tải mượt các ô gạch OpenStreetMap tile từ server mà không bị lỗi trắng màn hình.
  - Hiển thị chấm xanh định vị vị trí hiện tại của thiết bị.
  - Hiển thị đúng 5 Marker tương ứng với 5 tiệm tóc mẫu tại Đà Nẵng đã có trạng thái `approved`.
  - Tiệm pending tuyệt đối không xuất hiện trên bản đồ.

#### Test Case TC-MAP-02: Tương tác Marker & Hiển thị Barber Bottom Sheet
* **Độ ưu tiên:** P0
* **Tiền điều kiện:** Đang ở màn hình bản đồ `/customer/search`.
* **Các bước thực hiện:**
  1. Chạm vào Marker của tiệm "HairFit Studio Đà Nẵng" (123 Nguyễn Văn Linh).
* **Kết quả mong đợi:**
  - Bản đồ tự động căn giữa vào tọa độ của Marker.
  - Bottom sheet xuất hiện từ dưới lên với đầy đủ thông tin: Ảnh đại diện tiệm, Tên tiệm, Khoảng cách (ví dụ: `1.2 km`), Đánh giá trung bình (`4.9 ⭐`), Khoảng giá (`80.000đ - 150.000đ`).
  - Có nút "Xem chi tiết" và nút "Đặt lịch ngay".

#### Test Case TC-MAP-03: Sắp xếp danh sách thợ theo khoảng cách Haversine
* **Độ ưu tiên:** P0
* **Tiền điều kiện:** Đang ở màn hình `/customer/search`.
* **Các bước thực hiện:**
  1. Nhấn nút chuyển đổi chế độ xem sang dạng Danh sách (List View).
  2. Quan sát thứ tự hiển thị của các thẻ tiệm tóc.
* **Kết quả mong đợi:**
  - Danh sách tiệm tóc được tự động tính toán khoảng cách bằng công thức Haversine so với vị trí GPS hiện tại.
  - Danh sách được xếp theo thứ tự khoảng cách tăng dần (tiệm gần nhất nằm trên cùng).

#### Test Case TC-MAP-04: Lọc thợ theo kiểu tóc AI đề xuất (`selectedHairstyleId`)
* **Độ ưu tiên:** P0
* **Tiền điều kiện:** Chuyển từ màn hình kết quả AI sang với tham số kiểu tóc `undercut`.
* **Các bước thực hiện:**
  1. Mở `/customer/search?hairstyleId=undercut`.
  2. Quan sát danh sách các tiệm hiển thị.
* **Kết quả mong đợi:**
  - Các tiệm có hỗ trợ kiểu tóc "Undercut Cổ Điển" (chứa ID trong `hairstyleIds`) được gắn huy hiệu nổi bật: **"Phù hợp kiểu tóc của bạn"**.
  - Các tiệm này được ưu tiên đưa lên đầu danh sách tìm kiếm.

#### Test Case TC-MAP-05: Chịu lỗi khi người dùng Từ chối cấp quyền Vị trí (GPS Denied)
* **Độ ưu tiên:** P0
* **Tiền điều kiện:** Vào Cài đặt ứng dụng của Android → Thu hồi quyền Vị trí (Location Permission: Denied).
* **Các bước thực hiện:**
  1. Mở ứng dụng HairFit AI, vào màn hình Bản đồ.
  2. Từ chối cấp quyền khi hệ thống hỏi lại.
* **Kết quả mong đợi:**
  - Ứng dụng **không bị crash/văng màn hình**.
  - Bản đồ kích hoạt cơ chế fallback: Lấy vị trí mặc định tại trung tâm TP Đà Nẵng (`16.0544, 108.2022`).
  - Hiển thị thanh thông báo nhẹ nhàng: "Không lấy được vị trí GPS. Đang hiển thị salon quanh khu vực Đà Nẵng". Người dùng vẫn có thể duyệt và đặt lịch bình thường.

---

### PHÂN HỆ 4: Bộ máy Sinh Slot, Đặt lịch & Chống trùng Slot Nguyên tử

#### Test Case TC-BOOK-01: Thuật toán sinh slot trống chính xác theo Giờ làm việc & Ca nghỉ
* **Độ ưu tiên:** P0
* **Tiền điều kiện:** Tiệm "Tiệm Cắt Tóc Quý Ông Retro" có cấu hình: Chủ Nhật đóng cửa (`closed: true`), Thứ 2 - Thứ 6 mở từ `09:00` đến `19:30`.
* **Các bước thực hiện:**
  1. Vào màn hình đặt lịch của tiệm này (`/customer/booking/barber_danang_03`).
  2. Chọn dịch vụ: "Cắt tóc cổ điển Classic" (thời lượng 30 phút).
  3. Chọn một ngày rơi vào Chủ Nhật.
* **Kết quả mong đợi:**
  - Lưới giờ không hiển thị slot nào.
  - Hiển thị thông báo trạng thái rỗng rõ ràng: "Tiệm nghỉ vào ngày này. Vui lòng chọn ngày khác!".
  4. Đổi sang chọn ngày Thứ Hai (ngày thường):
  - Lưới hiển thị danh sách các slot cách đều 30 phút: `09:00`, `09:30`, `10:00`, ..., `19:00`.

#### Test Case TC-BOOK-02: Dịch vụ đa slot (Multi-slot service: 60 phút / 90 phút)
* **Độ ưu tiên:** P0
* **Tiền điều kiện:** Tiệm có slot `10:00` đã có người đặt trước trong `bookedSlots`. Slot `09:30` và `10:30` còn trống.
* **Các bước thực hiện:**
  1. Khách hàng chọn dịch vụ "Combo Cắt + Gội" thời lượng **60 phút** (cần 2 slot liên tiếp).
  2. Quan sát sự hiển thị của slot `09:30`.
* **Kết quả mong đợi:**
  - Dù slot `09:30` còn trống, nhưng slot kế tiếp `10:00` đã bị chiếm → Dịch vụ 60 phút không thể hoàn thành liền mạch từ 09:30 đến 10:30.
  - Thuật toán `slot_service.dart` tự động **vô hiệu hóa** hoặc ẩn slot `09:30`, không cho phép khách chọn.

#### Test Case TC-BOOK-03: Kiểm tra ràng buộc Lead Time 30 phút & Đặt trước 30 ngày
* **Độ ưu tiên:** P0
* **Tiền điều kiện:** Giả sử thời gian hiện tại của hệ thống là `14:10`.
* **Các bước thực hiện:**
  1. Chọn đặt lịch trong ngày hôm nay.
  2. Quan sát các slot: `14:00`, `14:30`, `15:00`.
* **Kết quả mong đợi:**
  - Slot `14:00` (đã qua trong quá khứ) → Bị ẩn/disabled.
  - Slot `14:30` (cách hiện tại 20 phút < Lead time 30 phút) → Bị vô hiệu hóa vì không đủ thời gian chuẩn bị.
  - Slot đầu tiên có thể bấm chọn là từ `15:00` trở đi.
  3. Thử cuộn lịch chọn ngày cách hôm nay 35 ngày → Bộ chọn ngày giới hạn tối đa chỉ cho phép chọn trong vòng 30 ngày tới.

#### Test Case TC-BOOK-04: Đặt lịch thành công với Transaction nguyên tử (Happy Path)
* **Độ ưu tiên:** P0
* **Tiền điều kiện:** Tài khoản `customer1@hairfit.com` có 0 lịch hẹn active. Tiệm "HairFit Studio" còn trống slot `09:00` ngày mai.
* **Các bước thực hiện:**
  1. Chọn Dịch vụ: "Cắt tạo kiểu cao cấp" (80.000đ, 30 phút).
  2. Chọn Ngày: Ngày mai.
  3. Chọn Giờ: `09:00`.
  4. Nhập ghi chú: "Cắt ngắn hai bên theo kiểu Undercut".
  5. Xem lại màn hình tóm tắt booking.
  6. Bấm nút "Xác nhận đặt lịch".
* **Kết quả mong đợi:**
  - Giao diện hiển thị loading indicator.
  - Firestore Transaction thực thi thành công:
    * Tạo document trong `appointments` với `status: 'pending'`, `slotIds: ['barber_danang_01_2026-xx-xx_09-00']`.
    * Tạo document trong `bookedSlots` với ID `barber_danang_01_2026-xx-xx_09-00`.
  - Hiển thị Dialog chúc mừng: "Đặt lịch thành công!".
  - Điều hướng người dùng sang màn hình "Lịch hẹn của tôi" (`/customer/appointments`).

#### Test Case TC-BOOK-05: Chặn đặt lịch vượt quá giới hạn 2 lịch hẹn kích hoạt
* **Độ ưu tiên:** P0
* **Tiền điều kiện:** Tài khoản `customer1@hairfit.com` đã có sẵn 2 lịch hẹn ở trạng thái `pending` hoặc `confirmed`.
* **Các bước thực hiện:**
  1. Thực hiện quy trình đặt thêm một lịch hẹn thứ 3.
  2. Bấm "Xác nhận đặt lịch".
* **Kết quả mong đợi:**
  - Giao thức kiểm tra chặn trước khi ghi Firestore: Phát hiện đã có 2 lịch hẹn active.
  - Ném ngoại lệ `MaxBookingsExceededException`.
  - Hiển thị hộp thoại cảnh báo: "Bạn chỉ được phép đặt tối đa 2 lịch hẹn chưa hoàn tất cùng một lúc. Vui lòng hoàn tất hoặc hủy lịch cũ trước!".
  - Không tạo thêm bản ghi nào trong database.

---

### PHÂN HỆ 5: AI Tư vấn Kiểu tóc 100% On-Device (ML Kit Contours & Nhân trắc học)

#### Test Case TC-AI-01: Hiển thị Privacy Consent Popup lần đầu
* **Độ ưu tiên:** P0
* **Tiền điều kiện:** Cài mới ứng dụng hoặc xóa dữ liệu `SharedPreferences`.
* **Các bước thực hiện:**
  1. Bấm vào banner AI trên Trang chủ hoặc tab "AI Tư vấn".
* **Kết quả mong đợi:**
  - Xuất hiện Hộp thoại thông báo quyền riêng tư (Privacy Consent Dialog): "HairFit AI cam kết bảo vệ dữ liệu khuôn mặt của bạn. Toàn bộ quá trình phân tích hình học được thực hiện 100% trên thiết bị của bạn (On-Device). Ảnh của bạn KHÔNG BAO GIỜ được tải lên máy chủ đám mây."
  - Có 2 nút: "Tôi đồng ý" và "Hủy / Để sau".
  2. Bấm "Tôi đồng ý" → Lưu cờ vào SharedPreferences, các lần mở sau không hiện lại popup này nữa.

#### Test Case TC-AI-02: Quality Gate — Ảnh không có khuôn mặt (No Face Detected)
* **Độ ưu tiên:** P0
* **Tiền điều kiện:** Đang ở màn hình AI Consult (`/customer/ai-consult`).
* **Các bước thực hiện:**
  1. Chọn một bức ảnh chụp phong cảnh hoặc bàn ghế (không chứa mặt người).
  2. Bấm "Phân tích ngay".
* **Kết quả mong đợi:**
  - Tầng 1 ML Kit Face Detection phân tích trong < 40ms.
  - Phát hiện `faces.isEmpty`.
  - Trả về kết quả `AIConsultValidationFailure`.
  - Hiển thị thông báo hướng dẫn trực quan: "Không phát hiện khuôn mặt! Vui lòng chụp rõ mặt trong khung hình".

#### Test Case TC-AI-03: Quality Gate — Góc mặt nghiêng quá quy định (Euler Angle Violation)
* **Độ ưu tiên:** P0
* **Tiền điều kiện:** Đang ở màn hình AI Consult.
* **Các bước thực hiện:**
  1. Chọn một ảnh selfie nhưng quay mặt góc nghiêng 45 độ (Euler Y > 20°).
  2. Bấm "Phân tích ngay".
* **Kết quả mong đợi:**
  - Tầng 1 phát hiện `headEulerAngleY > 20°`.
  - Hiển thị cảnh báo hướng dẫn cụ thể: "Vui lòng nhìn thẳng vào ống kính camera! Tránh quay đầu sang trái hoặc phải để thuật toán đo tỷ lệ xương hàm chính xác".

#### Test Case TC-AI-04: Phân tích Nhân trắc học & Gợi ý Kiểu tóc thành công (< 60ms)
* **Độ ưu tiên:** P0 (Tính năng cốt lõi)
* **Tiền điều kiện:** Chọn ảnh chân dung chụp chính diện, đủ sáng, khuôn mặt chiếm > 25% khung hình.
* **Các bước thực hiện:**
  1. Chọn Giới tính: "Nam".
  2. Chọn Độ dài tóc: "Ngắn / Vừa".
  3. Chọn ảnh chân dung hợp lệ (ví dụ ảnh mặt vuông nam tính).
  4. Bấm "Phân tích kiểu tóc".
* **Kết quả mong đợi:**
  - Đồng hồ đo hiệu năng ghi nhận toàn bộ quá trình hoàn tất trong **< 60ms**:
    * ML Kit Quality Gate & trích xuất 132 điểm viền: ~35ms.
    * FaceShapeAnalyzer tính 4 lát cắt nhân trắc: ~8ms.
    * HairstyleRecommendationEngine đối soát ma trận quy tắc: ~3ms.
  - Chuyển mượt sang màn hình Kết quả (`/customer/ai-result`):
    * Dáng mặt được xác định chính xác: "Mặt Vuông (Square) — Nam tính, xương quai hàm sắc nét".
    * Hiển thị đầy đủ Top 3 kiểu tóc tương thích nhất: (1) Undercut Cổ Điển, (2) Textured Crop, (3) Side Part 7/3.
    * Mỗi kiểu tóc đều có: Ảnh chất lượng cao, Điểm phù hợp (`95% Match`), Lý do chuyên gia phân tích ("Giúp cân đối độ vuông của góc hàm, tạo cảm giác khuôn mặt thanh thoát hơn"), và Mẹo vuốt sáp tạo kiểu.
    * Hiển thị lời khuyên tổng quát và những kiểu tóc nên tránh.

#### Test Case TC-AI-05: Chế độ Fallback chọn Dáng mặt thủ công (Manual Selection)
* **Độ ưu tiên:** P0
* **Tiền điều kiện:** Thiết bị không có camera hoặc người dùng không muốn dùng ảnh.
* **Các bước thực hiện:**
  1. Tại màn hình AI Consult, bấm vào nút liên kết: "Không muốn chụp ảnh? Chọn dáng mặt thủ công".
  2. Màn hình `/customer/manual-select` mở ra với 5 card dáng mặt minh họa: Trái Xoan, Mặt Tròn, Mặt Vuông, Mặt Trái Tim, Mặt Dài.
  3. Bấm chọn card "Mặt Tròn (Round)".
  4. Bấm "Xem gợi ý kiểu tóc".
* **Kết quả mong đợi:**
  - HairstyleRecommendationEngine tức thì truy xuất catalog và lọc ra các kiểu tóc cho mặt tròn (Pompadour, Quiff, Undercut).
  - Hiển thị đầy đủ kết quả chuyên gia mà không cần bất kỳ thao tác xử lý ảnh nào.

#### Test Case TC-AI-06: Chuyển tiếp kết quả AI sang Bản đồ đặt lịch
* **Độ ưu tiên:** P0
* **Tiền điều kiện:** Đang ở màn hình kết quả AI (`/customer/ai-result`).
* **Các bước thực hiện:**
  1. Tại thẻ kiểu tóc gợi ý "Undercut Cổ Điển", nhấn nút CTA: **"Tìm thợ cắt kiểu này"**.
* **Kết quả mong đợi:**
  - GoRouter điều hướng sang `/customer/search?hairstyleId=undercut`.
  - Màn hình Bản đồ tự động nhận `selectedHairstyleId = 'undercut'`.
  - Kích hoạt huy hiệu ưu tiên "Phù hợp kiểu tóc của bạn" cho các salon chuyên cắt Undercut tại Đà Nẵng.

---

### PHÂN HỆ 6: Vòng đời Lịch hẹn & Đồng bộ Trạng thái Khách - Thợ

#### Test Case TC-APPT-01: Thợ cắt tóc Xác nhận lịch hẹn (Confirm Flow)
* **Độ ưu tiên:** P0
* **Tiền điều kiện:** Có 1 lịch hẹn đang ở trạng thái `pending` của khách hàng `customer1` gửi tới thợ `barber1`. Thợ đăng nhập mở màn hình `/barber/appointments`.
* **Các bước thực hiện:**
  1. Thợ nhìn thấy thẻ lịch hẹn trong danh sách "Lịch chờ xác nhận".
  2. Bấm nút màu xanh: "Xác nhận lịch".
* **Kết quả mong đợi:**
  - Trạng thái document trong `appointments` chuyển từ `pending` sang `confirmed`.
  - Document trong `bookedSlots` vẫn được duy trì nguyên vẹn.
  - Trên máy khách hàng `customer1`, trạng thái lịch chuyển sang huy hiệu xanh: "Đã xác nhận".

#### Test Case TC-APPT-02: Thợ hoàn tất phục vụ (Complete Flow)
* **Độ ưu tiên:** P0
* **Tiền điều kiện:** Lịch hẹn đang ở trạng thái `confirmed`.
* **Các bước thực hiện:**
  1. Thợ bấm nút "Hoàn tất cắt tóc".
* **Kết quả mong đợi:**
  - Trạng thái appointment chuyển sang `completed`.
  - Lịch được lưu vào danh sách lịch sử phục vụ của cả khách lẫn thợ.

#### Test Case TC-APPT-03: Thợ từ chối lịch hẹn (Reject Flow & Slot Freeing)
* **Độ ưu tiên:** P0
* **Tiền điều kiện:** Lịch hẹn đang ở trạng thái `pending` với slot `14:00`.
* **Các bước thực hiện:**
  1. Thợ bấm nút màu đỏ: "Từ chối".
  2. Xác nhận từ chối trong hộp thoại cảnh báo.
* **Kết quả mong đợi:**
  - Appointment chuyển sang `rejected`.
  - Transaction lập tức xóa document `bookedSlots` tương ứng với slot `14:00`.
  - Slot `14:00` ngay lập tức chuyển lại thành màu xanh (trống) trên lưới đặt lịch của khách hàng khác.

#### Test Case TC-APPT-04: Khách hàng Hủy lịch hợp lệ (> 30 phút trước giờ hẹn)
* **Độ ưu tiên:** P0
* **Tiền điều kiện:** Khách có lịch hẹn lúc `16:00` ngày mai (cách hiện tại > 24 giờ). Trạng thái là `pending` hoặc `confirmed`.
* **Các bước thực hiện:**
  1. Khách vào "Lịch hẹn của tôi" (`/customer/appointments`).
  2. Bấm nút "Hủy lịch hẹn" trên thẻ lịch.
  3. Chọn lý do hủy và nhấn "Đồng ý hủy".
* **Kết quả mong đợi:**
  - Transaction hủy lịch thực thi:
    * Cập nhật `appointments.status = 'cancelled'`.
    * Xóa sạch các slotId tương ứng trong collection `bookedSlots`.
  - Thẻ lịch hẹn chuyển sang trạng thái xám: "Đã hủy".
  - Số lượng lịch hẹn active của khách giảm đi 1, cho phép đặt thêm lịch mới.

#### Test Case TC-APPT-05: Chặn khách hàng Hủy lịch sát giờ (< 30 phút trước giờ hẹn)
* **Độ ưu tiên:** P0
* **Tiền điều kiện:** Lịch hẹn có giờ bắt đầu lúc `10:00`. Thời gian thực tại thời điểm bấm hủy là `09:40` (cách giờ hẹn 20 phút < Lead time 30 phút).
* **Các bước thực hiện:**
  1. Khách hàng bấm nút "Hủy lịch hẹn".
* **Kết quả mong đợi:**
  - Hệ thống kiểm tra điều kiện `now > startTimestamp - 30 minutes`.
  - Chặn đứng thao tác, ném ngoại lệ `CannotCancelException`.
  - Hiển thị thông báo lỗi: "Không thể hủy lịch! Quý khách chỉ có thể hủy lịch trước giờ hẹn ít nhất 30 phút theo quy định của tiệm".
  - Lịch hẹn vẫn giữ nguyên trạng thái cũ.

---

## 6. KỊCH BẢN KIỂM THỬ TÍCH HỢP END-TO-END (INTEGRATED E2E JOURNEYS)

Các kịch bản dưới đây kiểm thử sự phối hợp liền mạch giữa tất cả các module trong ứng dụng theo chu trình hoàn chỉnh thực tế.

---

### E2E-01: Hành trình Khách hàng Hoàn chỉnh (AI Consult → Chọn Kiểu → Chọn Thợ → Đặt Lịch)
```
[User Goal]: Khách hàng chưa biết chọn kiểu tóc nào, dùng AI On-Device để phân tích khuôn mặt, nhận gợi ý, tìm salon gần nhất cắt được kiểu đó và hoàn tất đặt chỗ.
```

```
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│  1. AI Consult  │ ────> │  2. Kết Quả AI  │ ────> │  3. Tìm Salon   │ ────> │  4. Đặt Lịch    │
│  Chụp ảnh mặt   │       │  Dáng: Oval     │       │  Bản đồ OSM     │       │  Chọn dịch vụ   │
│  ML Kit 132 pts │       │  Top 3 kiểu tóc │       │  Filter thợ gần │       │  Slot 30m Trống │
└─────────────────┘       └─────────────────┘       └─────────────────┘       └─────────────────┘
```

* **Thiết bị:** Thiết bị thật Device A (Khách hàng).
* **Các bước thực thi chi tiết:**
  1. Khởi động app HairFit AI → Splash screen (1.5s) → Đăng nhập bằng `customer1@hairfit.com`.
  2. Tại Trang chủ, nhấn vào Banner lớn: **"Khám phá kiểu tóc phù hợp với AI"**.
  3. Chấp thuận Privacy Consent Popup.
  4. Mở camera, đưa mặt vào khung oval màu trắng, hệ thống tự động hướng dẫn căn chỉnh. Chụp ảnh chân dung chính diện.
  5. Ứng dụng xử lý trong tích tắc (~50ms) và chuyển sang màn hình Kết quả.
  6. Kết quả chỉ ra: "Khuôn mặt Trái Xoan (Oval)". Kiểu tóc khuyến nghị hàng đầu: **"Side Part 7/3 Lịch Lãm"**.
  7. Bấm nút: **"Tìm thợ cắt kiểu này"**.
  8. Màn hình Bản đồ hiện ra với các tiệm hỗ trợ Side Part được gắn huy hiệu "Phù hợp".
  9. Chọn tiệm gần nhất: "30Shine Hải Châu" (cách 800m).
  10. Tại Bottom sheet, nhấn **"Đặt lịch ngay"**.
  11. Chọn Dịch vụ: "Combo Shine 7 bước" (100.000đ, 30 phút).
  12. Chọn Ngày: Ngày mai. Chọn Khung giờ trống: `10:00`.
  13. Xem tóm tắt thông tin và bấm **"Xác nhận đặt lịch"**.
* **Tiêu chí nghiệm thu (Pass Criteria):**
  - Mọi thao tác chuyển màn hình mượt mà, không giật lag.
  - Phân tích AI hoàn toàn ngoại tuyến không gửi ảnh ra ngoài.
  - Appointment và bookedSlots được tạo chuẩn xác trên Firestore.
  - Khách nhìn thấy lịch hẹn trạng thái `pending` trong danh sách của mình.

---

### E2E-02: Hành trình Thợ tiếp nhận, Xác nhận và Hoàn tất phục vụ
```
[User Goal]: Thợ cắt tóc nhận được thông báo lịch hẹn mới từ E2E-01, xác nhận phục vụ và chuyển trạng thái khi khách cắt xong.
```
* **Thiết bị:** Thiết bị Device B (Đóng vai Thợ cắt tóc).
* **Các bước thực thi chi tiết:**
  1. Đăng nhập tài khoản `barber_danang_02` (30Shine Hải Châu).
  2. Hệ thống nhận diện role `barber` và `approved` → Điều hướng vào Dashboard của Thợ (`/barber/appointments`).
  3. Lịch hẹn vừa đặt ở E2E-01 xuất hiện ngay trong tab "Chờ duyệt" với thông tin chi tiết: Tên khách hàng, Dịch vụ "Combo Shine 7 bước", Khung giờ `10:00` ngày mai.
  4. Thợ nhấn nút **"Xác nhận lịch"**.
  5. Kiểm tra trên Thiết bị A (Khách hàng): Lịch hẹn tự động chuyển sang badge màu xanh `Đã xác nhận` qua cơ chế realtime của Firestore Stream.
  6. Đến ngày giờ hẹn, sau khi phục vụ khách xong, thợ bấm **"Hoàn tất"**.
* **Tiêu chí nghiệm thu:**
  - Trạng thái chuyển chuẩn xác: `pending` → `confirmed` → `completed`.
  - Cả hai bên đều thấy lịch sử cập nhật nhất quán tức thời.

---

### E2E-03: Kiểm thử Tranh chấp Slot Đồng thời (Concurrency & Race Condition Collision)
```
[User Goal]: Chứng minh Firestore Transaction ngăn chặn 100% tình trạng hai khách hàng đặt trùng cùng 1 khung giờ.
```
* **Thiết bị:** 
  - Khách hàng 1 (Device A, User `customer1@hairfit.com`).
  - Khách hàng 2 (Device B, User `customer2@hairfit.com`).
* **Các bước thực thi chi tiết:**
  1. Cả Khách hàng 1 và Khách hàng 2 cùng mở màn hình đặt lịch của "HairFit Studio Đà Nẵng" cho cùng một ngày (ngày kia).
  2. Cả hai cùng chọn dịch vụ 30 phút và cùng chọn khung giờ: **`09:00`** (lúc này ô giờ trên cả 2 máy đều hiển thị màu xanh khả dụng).
  3. Cả hai cùng đi tới màn hình Tóm tắt xác nhận.
  4. **Hành động đồng thời:** Hai tester cùng bấm nút **"Xác nhận đặt lịch"** chính xác tại cùng một giây.
* **Tiêu chí nghiệm thu (Pass Criteria):**
  - **Chính xác 1 khách hàng thành công (Thắng transaction):** Nhận được thông báo "Đặt lịch thành công!", slot `09:00` được gán cho người này.
  - **Khách hàng còn lại thất bại (Thua transaction):** Hệ thống bắt lỗi `SlotAlreadyBookedException`, hiển thị thông báo lỗi rõ ràng: "Rất tiếc! Khung giờ này vừa có người đặt trước. Vui lòng chọn khung giờ khác!".
  - Trong Firestore: Document `bookedSlots/barber_danang_01_yyyy-MM-dd_09-00` chỉ thuộc về 1 `appointmentId` duy nhất. Tuyệt đối không xảy ra hiện tượng ghi đè dữ liệu.

---

### E2E-04: Hủy lịch & Tái cấp phát Slot tức thì (Reclaim Available Slot)
```
[User Goal]: Kiểm tra tính toàn vẹn của chu trình giải phóng slot sau khi hủy lịch.
```
* **Các bước thực thi chi tiết:**
  1. Khách hàng 1 (người vừa đặt thành công ở E2E-03 slot `09:00`) vào danh sách lịch hẹn và chọn **"Hủy lịch hẹn"**.
  2. Transaction hủy lịch được gọi:
     - Document `appointments` chuyển sang `cancelled`.
     - Document `bookedSlots/barber_danang_01_yyyy-MM-dd_09-00` bị **XÓA HOÀN TOÀN** khỏi Firestore.
  3. Khách hàng 2 lập tức mở lại màn hình đặt lịch của tiệm tóc đó cho ngày nói trên.
  4. Quan sát slot `09:00`.
* **Tiêu chí nghiệm thu:**
  - Khung giờ `09:00` ngay lập tức chuyển lại trạng thái sáng xanh (Khả dụng).
  - Khách hàng 2 bấm đặt khung giờ `09:00` này và đặt thành công 100%.

---

### E2E-05: Kiểm thử Khả năng Chịu lỗi & Hoạt động Ngoại tuyến (Offline & Degraded Network)
```
[User Goal]: Kiểm chứng lời hứa "100% On-Device AI hoạt động độc lập không cần Internet" và hành vi ứng xử khi mất kết nối mạng.
```
* **Các bước thực thi chi tiết:**
  1. Mở ứng dụng HairFit AI trên thiết bị thật.
  2. Bật chế độ máy bay (**Airplane Mode** — Ngắt hoàn toàn cả Wi-Fi và 4G).
  3. Mở tính năng AI Tư Vấn Kiểu Tóc.
  4. Tiến hành chụp ảnh khuôn mặt hoặc chọn ảnh từ bộ nhớ máy.
  5. Bấm "Phân tích kiểu tóc".
* **Tiêu chí nghiệm thu:**
  - **AI VẪN HOẠT ĐỘNG HOÀN TOÀN BÌNH THƯỜNG:** Nhận diện 132 điểm viền ML Kit, thuật toán nhân trắc học 4-band và ma trận quy tắc chuyên gia chạy offline 100%, trả kết quả sau < 60ms mà không báo bất kỳ lỗi mạng nào!
  6. Sau khi có kết quả, bấm "Tìm thợ cắt kiểu này" (cần tải bản đồ và Firestore):
  - Ứng dụng hiển thị banner/thông báo cảnh báo mạng văn minh: "Không có kết nối Internet. Vui lòng bật mạng để tìm kiếm salon và đặt lịch!". Ứng dụng không bị crash hay đứng hình.

---

### E2E-06: Kiểm thử Bảo mật Firestore Rules & Ngăn chặn Leo thang Đặc quyền
```
[User Goal]: Đảm bảo tin tặc hoặc người dùng cố ý không thể can thiệp dữ liệu qua client SDK.
```
* **Các kịch bản kiểm tra an ninh:**
  1. **Khách hàng đọc lịch của người khác:** Thử truy vấn Firestore `appointments` với ID của khách hàng khác → Firestore Rules từ chối (`Missing or insufficient permissions`).
  2. **Tự ý nâng cấp tài khoản thành Admin:** Khách hàng dùng script cập nhật document `users/{my_uid}` với trường `role: 'admin'` → Firestore Rules chặn ngay vì rule chỉ cho phép user sửa `displayName`, `avatarUrl`, cấm sửa `role`.
  3. **Thợ tự duyệt hồ sơ:** Thợ gửi lệnh update `barberProfiles/{my_uid}` với `approvalStatus: 'approved'` → Bị chặn đứng bởi rule `!changedFields(['approvalStatus'])`.
  4. **Tự gỡ cờ Blocked:** Tài khoản bị khóa gửi lệnh update `isBlocked: false` → Bị chặn đứng bởi Security Rules.

---

## 7. MA TRẬN KIỂM THỬ TỔNG HỢP & TIÊU CHÍ NGHIỆM THU MILESTONE 5 TUẦN

Bảng đối soát nghiệm thu toàn bộ 30 tiêu chí kiểm thử của hệ thống HairFit AI sau 5 tuần triển khai:

| ID | Hạng mục kiểm thử | Tuần thực hiện | Mức độ | Kết quả mong đợi | Trạng thái |
|---|---|---|---|---|:---:|
| **MT-01** | Khởi tạo cấu trúc dự án & Theme | Tuần 1 | P0 | Đúng chuẩn Clean Architecture, bảng màu Dark Navy | ✅ PASS |
| **MT-02** | Khởi tạo 6 Domain Data Models | Tuần 1 | P0 | Serialization toMap/fromMap chính xác 100% | ✅ PASS |
| **MT-03** | Khởi tạo dữ liệu mẫu Seed Data | Tuần 1 | P0 | 10 kiểu tóc catalog + 5 thợ Đà Nẵng nạp Firestore | ✅ PASS |
| **MT-04** | Bộ Shared Widgets dùng chung | Tuần 1 | P0 | Button, Shimmer, Empty, Error, Badges render chuẩn | ✅ PASS |
| **MT-05** | Đăng ký / Đăng nhập Email Password | Tuần 2 | P0 | Validate format, tạo user trong Firestore | ✅ PASS |
| **MT-06** | Quên mật khẩu & Gửi email reset | Tuần 2 | P0 | Gửi email khôi phục từ Firebase Auth | ✅ PASS |
| **MT-07** | Chặn tài khoản bị khóa (`isBlocked`) | Tuần 2 | P0 | Đăng xuất ngay lập tức, thông báo cấm truy cập | ✅ PASS |
| **MT-08** | Phân quyền điều hướng Role Guard | Tuần 2 | P0 | Customer, Barber, Admin đi đúng Shell của mình | ✅ PASS |
| **MT-09** | Tạo hồ sơ thợ (Dịch vụ, Giờ, Bản đồ) | Tuần 2 | P0 | Lưu `barberProfiles` với trạng thái `pending` | ✅ PASS |
| **MT-10** | Validate dịch vụ thời lượng bội số 30m | Tuần 2 | P0 | Chặn 45m, 75m; chỉ cho phép 30m, 60m, 90m, 120m | ✅ PASS |
| **MT-11** | Admin xét duyệt hồ sơ thợ | Tuần 2 | P0 | Chuyển pending sang approved/rejected chuẩn | ✅ PASS |
| **MT-12** | Firestore Security Rules lớp dữ liệu | Tuần 2 | P0 | Chống leo thang quyền admin, chống tự duyệt thợ | ✅ PASS |
| **MT-13** | Xin quyền GPS & Lấy vị trí thiết bị | Tuần 3 | P0 | Lấy tọa độ GPS chính xác qua Geolocator | ✅ PASS |
| **MT-14** | Fallback khi GPS bị từ chối | Tuần 3 | P0 | Không crash, lấy tọa độ trung tâm TP Đà Nẵng | ✅ PASS |
| **MT-15** | Hiển thị bản đồ OpenStreetMap 0đ API | Tuần 3 | P0 | Tải tile OSM mượt mà, ghim đúng marker thợ approved | ✅ PASS |
| **MT-16** | Tính khoảng cách thực tế Haversine | Tuần 3 | P0 | Tính km chính xác, sắp xếp thợ từ gần đến xa | ✅ PASS |
| **MT-17** | Chi tiết hồ sơ thợ & Danh mục dịch vụ | Tuần 3 | P0 | Hiển thị giờ mở cửa, bảng giá và dịch vụ salon | ✅ PASS |
| **MT-18** | Giao diện Trang chủ Customer Home | Tuần 3 | P0 | Banner AI CTA, kiểu tóc hot, thợ nổi bật | ✅ PASS |
| **MT-19** | Thuật toán sinh slot theo ca làm việc | Tuần 4 | P0 | Sinh slot 30m chuẩn, loại trừ ca nghỉ và ngày lễ | ✅ PASS |
| **MT-20** | Xử lý dịch vụ kéo dài đa slot | Tuần 4 | P0 | 60m đòi hỏi 2 slot liên tiếp, 90m đòi hỏi 3 slot | ✅ PASS |
| **MT-21** | Quy tắc nghiệp vụ Lead Time 30 phút | Tuần 4 | P0 | Ẩn slot quá khứ và slot cách hiện tại < 30 phút | ✅ PASS |
| **MT-22** | Giới hạn đặt trước trong vòng 30 ngày | Tuần 4 | P0 | Bộ chọn ngày không cho phép chọn quá 30 ngày | ✅ PASS |
| **MT-23** | Giới hạn tối đa 2 lịch hẹn kích hoạt | Tuần 4 | P0 | Chặn khách đặt lịch thứ 3 khi chưa xong lịch cũ | ✅ PASS |
| **MT-24** | Firestore Transaction chống trùng lịch | Tuần 4 | P0 | 2 khách tranh slot cùng giây → Chỉ 1 khách được | ✅ PASS |
| **MT-25** | Vòng đời Lịch hẹn Khách - Thợ | Tuần 4 | P0 | Thợ Confirm, Reject, Complete hoạt động chuẩn | ✅ PASS |
| **MT-26** | Hủy lịch hẹn & Giải phóng BookedSlot | Tuần 4 | P0 | Xóa bookedSlots, mở lại slot khả dụng cho người khác| ✅ PASS |
| **MT-27** | Chặn hủy lịch sát giờ hẹn (< 30 phút) | Tuần 4 | P0 | Chặn thao tác hủy, bảo vệ quyền lợi của salon | ✅ PASS |
| **MT-28** | ML Kit Quality Gate & 132 Contours | Tuần 5 | P0 | Lọc góc nghiêng Euler Y/X, trích xuất điểm viền mặt | ✅ PASS |
| **MT-29** | Phân tích Nhân trắc học 4-Band On-Device| Tuần 5 | P0 | Tỷ lệ Dài/Rộng, Trán/Hàm, đo góc hàm trong < 50ms | ✅ PASS |
| **MT-30** | Ma trận quy tắc gợi ý tóc & Chuyển Map | Tuần 5 | P0 | Gợi ý 3 kiểu tóc + lý do, chuyển sang Map có filter | ✅ PASS |

---

## 8. HƯỚNG DẪN THỰC THI KIỂM THỬ TRÊN MÁY THỰC TẾ

### Bước 1: Kiểm tra Kiểm thử tự động (CI/CD Local Gate)
Mở terminal tại thư mục gốc của dự án và chạy lệnh:
```bash
flutter test
```
* **Kỳ vọng:** `All tests passed!` (76/76 test cases thành công).

### Bước 2: Nạp dữ liệu Seed Data cho buổi nghiệm thu
Nếu cơ sở dữ liệu Firestore đang rỗng hoặc cần làm mới hoàn toàn:
1. Mở file `lib/main.dart` hoặc gọi dịch vụ:
```dart
await SeedDataService().seedAll(overwrite: true);
```
2. Kiểm tra trên Firebase Console: Có đủ 10 tài liệu trong `hairstyleCatalog` và 5 tài liệu trong `barberProfiles`.

### Bước 3: Chạy ứng dụng trên thiết bị Android thật
```bash
flutter run -d <device_id>
```
1. Thực hiện lần lượt **Kịch bản E2E-01** (Khách hàng từ AI đến Đặt lịch).
2. Dùng thiết bị thứ hai thực hiện **Kịch bản E2E-02** (Thợ nhận lịch và duyệt).
3. Kiểm tra tính độc lập của AI bằng cách bật **Chế độ máy bay** (Kịch bản E2E-05).

---

> **KẾT LUẬN NGHIỆM THU:**  
> Hệ sinh thái **HairFit AI** sau 5 tuần triển khai đã hoàn thành 100% các mục tiêu P0 được đề ra trong Timeline và Specification. Hệ thống vận hành ổn định, thuật toán On-Device AI đạt tốc độ vượt trội (< 60ms), cơ chế chống trùng lịch hoạt động an toàn tuyệt đối với Firestore Transaction và OpenStreetMap mang lại giải pháp bản đồ trực quan với chi phí vận hành 0 đồng.
