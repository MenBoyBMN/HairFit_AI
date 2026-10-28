# 💈 HairFit AI

## 🌟 1. Giới Thiệu Dự Án
**HairFit AI** là một ứng dụng di động thông minh giúp kết nối khách hàng với các thợ cắt tóc chuyên nghiệp, đồng thời tích hợp công nghệ Trí tuệ nhân tạo (AI) ngay trên điện thoại để tư vấn kiểu tóc phù hợp nhất với từng cá nhân.

**Vấn đề giải quyết:**
- **Đối với khách hàng:** Thường xuyên băn khoăn không biết khuôn mặt mình hợp với kiểu tóc nào, sợ rủi ro khi thử kiểu mới và mất thời gian chờ đợi tại salon.
- **Đối với thợ cắt tóc:** Khó khăn trong việc tiếp cận khách hàng mới, quản lý lịch hẹn thủ công dễ bị trùng lặp hoặc quên lịch.

**Ai cần đến HairFit AI?**
- **Người dùng cá nhân:** Những người muốn làm mới bản thân, tìm kiếm kiểu tóc chân ái và muốn đặt lịch cắt tóc nhanh chóng, tiện lợi.
- **Thợ cắt tóc/Salon:** Các chuyên gia tạo mẫu tóc muốn số hóa quy trình quản lý lịch hẹn, xây dựng hồ sơ chuyên nghiệp và tiếp cận đúng tệp khách hàng.

## ✨ 2. Tính Năng Nổi Bật
- **🤖 Chuyên Gia AI Tư Vấn (On-Device ML Kit):** Chỉ cần chụp một bức ảnh, AI tích hợp cục bộ trên điện thoại sẽ tự động phân tích tỷ lệ các điểm mốc (Face Mesh) để xác định dáng mặt (tròn, vuông, trái xoan, trái tim,...) và đề xuất các kiểu tóc tối ưu nhất. Tốc độ phân tích dưới 1 giây, hoạt động ngoại tuyến và bảo mật 100% (ảnh không bao giờ tải lên máy chủ ngoài).
- **🤝 AI Haircut Handshake:** Kết quả kiểu tóc gợi ý từ AI sẽ tự động đồng bộ thẳng vào phiếu lịch hẹn. Khi khách bước vào tiệm, thợ chỉ cần mở app là thấy ngay ảnh tham khảo và lưu ý tạo kiểu mà không cần hỏi lại.
- **🗺️ Bản Đồ Thông Minh & Bộ Lọc Nâng Cao:** Quét salon và thợ cắt quanh vị trí của bạn, hỗ trợ lọc theo mức giá tối đa, salon đang mở cửa và đánh giá cao (⭐ 4.5+).
- **📅 Đặt Lịch & Đổi Lịch (Reschedule) Chống Trùng:** Hệ thống đặt hẹn theo từng slot 30 phút, vận hành bởi giao dịch nguyên tử (Firestore ACID Transaction) triệt tiêu hoàn toàn rủi ro trùng lịch. Khách hàng có thể chủ động đổi lịch hẹn khi có việc đột xuất.
- **💈 Công Cụ Dành Riêng Cho Thợ Cắt Tóc:** 
  - **Sổ tay Thợ (Mini CRM):** Ghi chú bảo mật về thói quen cắt, cạo mai, dị ứng da đầu của từng khách quen.
  - **Album Tác Phẩm (Lookbook):** Trưng bày thư viện ảnh các mẫu tóc thực tế đã cắt trực tiếp trên hồ sơ salon.
  - **Kiểm Soát Nhanh:** Xem doanh thu ngày, nút gạt tạm ngưng nhận khách hôm nay và tính năng khóa slot nghỉ đột xuất.
- **👑 Cổng Quản Trị Hệ Thống (Admin Portal):** Dashboard biểu đồ doanh thu, duyệt hồ sơ thợ cắt tóc mới, giám sát toàn bộ lịch hẹn và kiểm duyệt đánh giá.

## 🛠️ 3. Công Nghệ Sử Dụng
HairFit AI được xây dựng theo tiêu chuẩn phát triển ứng dụng di động hiện đại:
- **Nền tảng phát triển:** Flutter 3.x (Dart 3.x) - ứng dụng đa nền tảng mượt mà trên Android và iOS.
- **Trí tuệ nhân tạo (AI):** Google ML Kit (`google_mlkit_face_mesh_detection`) - xử lý trực tiếp trên thiết bị (On-Device), không phụ thuộc Cloud API trả phí.
- **Cơ sở dữ liệu & Xác thực:** Firebase Serverless (Authentication & Cloud Firestore) - tối ưu chi phí 0đ gói Spark Free Tier, giao dịch ACID an toàn.
- **Bản đồ số:** OpenStreetMap kết hợp thư viện Flutter Map (không tốn chi phí Google Maps API).
- **Quản lý trạng thái:** Riverpod 2.x (`flutter_riverpod`).
- **Điều hướng:** GoRouter 14.x với cơ chế bảo vệ phân quyền (Redirect Guards).

## 📂 4. Cấu Trúc Tổng Quan Của Dự Án
Dự án được phân chia thư mục theo chuẩn **Feature-First** (Nhóm theo tính năng):

```text
HairFit_AI/
├── .AGENTS/            # Quy chuẩn kỹ thuật, luật lệ kiến trúc & kỹ năng dành cho AI Agent
├── About System/       # Tài liệu đặc tả kế hoạch cải tiến, tính năng hệ thống
├── lib/
│   ├── core/           # Nền tảng dùng chung: Màu sắc, kích thước, nút bấm, tiện ích ngày giờ, gọi điện thoại...
│   ├── features/       # Các module tính năng nghiệp vụ:
│   │   ├── admin/          # Cổng quản trị (Dashboard, Duyệt thợ, Quản lý lịch hẹn, Người dùng, Đánh giá)
│   │   ├── ai_consult/     # Quét mặt On-device & tư vấn kiểu tóc chuẩn khuôn mặt
│   │   ├── appointments/   # Quản lý lịch hẹn, Thẻ AI Handshake, Doanh thu ngày, Đổi lịch
│   │   ├── auth/           # Đăng nhập, Đăng ký, Quên mật khẩu, Phân quyền người dùng
│   │   ├── barber_profile/ # Hồ sơ thợ, Giờ làm việc định kỳ, Album tác phẩm Lookbook
│   │   ├── booking/        # Thuật toán tính slot, Luồng đặt lịch, Tóm tắt, Xử lý dời lịch
│   │   ├── chat/           # Hệ thống nhắn tin trực tiếp khách - thợ
│   │   ├── home/           # Trang chủ khách hàng, Thẻ lịch sắp tới, Hồ sơ tóc AI, Salon ruột
│   │   ├── profile/        # Hồ sơ cá nhân & chỉnh sửa thông tin người dùng
│   │   └── search_map/     # Bản đồ tìm kiếm salon & bộ lọc đa tiêu chí
│   ├── models/         # Các Data Models bất biến (UserModel, AppointmentModel, BarberProfileModel...)
│   ├── providers/      # Các Riverpod Providers & StateNotifiers tầng ứng dụng
│   └── routing/        # Cấu hình GoRouter và điều hướng phân quyền
└── test/               # 100+ kịch bản kiểm thử tự động (Unit test, Widget test)
```

## 🚀 5. Hướng Dẫn Cài Đặt (Dành Cho Lập Trình Viên)
Để khởi chạy mã nguồn trên máy tính của bạn:

**Bước 1: Chuẩn bị môi trường**
- Đảm bảo máy tính đã cài đặt [Flutter SDK](https://docs.flutter.dev/get-started/install) (phiên bản 3.x trở lên).
- Cài đặt IDE (Visual Studio Code hoặc Android Studio) kèm extension Flutter & Dart.

**Bước 2: Cài đặt thư viện**
```bash
flutter pub get
```

**Bước 3: Kiểm tra chất lượng mã nguồn**
```bash
flutter analyze
flutter test
```

**Bước 4: Chạy ứng dụng**
```bash
flutter run
```

---

## 📱 6. Hướng Dẫn Cài Đặt & Sử Dụng (Dành Cho Người Dùng Phổ Thông - Non-Dev)

Bạn không cần biết lập trình vẫn có thể dễ dàng cài đặt và trải nghiệm HairFit AI lên điện thoại theo các cách đơn giản dưới đây:

### 🔹 Cách 1: Cài đặt trực tiếp trên điện thoại Android (File APK)
1. **Tải file cài đặt**: Tải file `hairfit-ai.apk` được chia sẻ từ trang [Releases của dự án](../../releases) hoặc từ liên kết do quản trị viên cung cấp.
2. **Mở file APK**: Nhấn vào file vừa tải về trong mục *Tệp đã tải xuống (Downloads)* trên điện thoại.
3. **Cấp quyền cài đặt**:
   - Nếu điện thoại hiện thông báo *"Ứng dụng không rõ nguồn gốc"*: Chọn **Cài đặt (Settings)** ➔ Bật công tắc **Cho phép cài đặt từ nguồn này (Allow from this source)**.
   - Nếu có cảnh báo quét mã của Google Play Protect: Nhấn **Vẫn cài đặt (Install anyway)**.
4. **Mở ứng dụng**: Biểu tượng HairFit AI màu cam hổ phách sẽ xuất hiện trên màn hình chính, nhấn vào để mở app.
5. **Cấp quyền cơ bản khi app hỏi**:
   - **Camera**: Dùng để chụp ảnh nhận diện dáng mặt và tư vấn kiểu tóc.
   - **Vị trí (GPS)**: Dùng để tìm kiếm các salon và tiệm cắt tóc gần bạn nhất.

---

### 🔹 Cách 2: Trải nghiệm trên iPhone (iOS qua Apple TestFlight)
1. Mở App Store trên iPhone, tìm và cài đặt ứng dụng **TestFlight** của Apple.
2. Nhấn vào liên kết mời thử nghiệm HairFit AI do quản trị viên dự án cung cấp (Invitation Public Link).
3. Nhấn **Chấp nhận (Accept)** và chọn **Cài đặt (Install)**.
4. Ứng dụng sẽ tự động được thêm vào iPhone như mọi ứng dụng thông thường khác.

---

### 🔹 Cách 3: Trải nghiệm trên Máy Tính (Qua Giả Lập Android)
Nếu bạn chưa có sẵn điện thoại Android:
1. Tải và cài đặt phần mềm giả lập miễn phí trên máy tính như **LDPlayer**, **BlueStacks** hoặc **NoxPlayer**.
2. Tải file `hairfit-ai.apk` về máy tính.
3. Kéo và thả trực tiếp file `.apk` vào màn hình giả lập, ứng dụng sẽ tự động cài đặt trong 10 giây.
4. Nhấp vào icon app để sử dụng với chuột và webcam máy tính.

---

### 💡 Bắt Đầu Sử Dụng Nhanh Sau Khi Cài Đặt:
- **Nếu bạn là Khách hàng**:
  1. Đăng ký tài khoản mới bằng Email/Mật khẩu hoặc sử dụng tài khoản có sẵn.
  2. Tại trang chủ, chọn nút **"Quét khuôn mặt ngay"** để AI phân tích dáng mặt và chọn kiểu tóc chân ái.
  3. Mở tab **"Bản đồ"** để tìm salon uy tín gần nhất, chọn ngày giờ và bấm **"Đặt lịch"** (kiểu tóc AI tư vấn sẽ tự động được gửi kèm cho thợ).
- **Nếu bạn là Thợ cắt tóc / Chủ Salon**:
  1. Đăng ký tài khoản và chọn vai trò **"Thợ cắt tóc"**.
  2. Điền thông tin salon, địa chỉ, số điện thoại, bảng giá dịch vụ và tải lên các ảnh tác phẩm thực tế (Lookbook).
  3. Sau khi Admin duyệt, bạn có thể bắt đầu tiếp nhận khách, theo dõi doanh thu ngày và quản lý lịch hẹn trực tiếp trên app.

---

## 🤝 7. Đóng Góp & Hỗ Trợ
Nếu bạn có bất kỳ đóng góp nào để cải thiện ứng dụng hoặc cần hỗ trợ cài đặt, vui lòng tạo **Issue** hoặc **Pull Request** trên kho lưu trữ này. Mọi ý kiến phản hồi đều giúp HairFit AI ngày càng hoàn thiện hơn!

---
*HairFit AI - Định Hình Phong Cách, Đặt Lịch Trong Tầm Tay.*
All System CreBy: MenBoyBMN