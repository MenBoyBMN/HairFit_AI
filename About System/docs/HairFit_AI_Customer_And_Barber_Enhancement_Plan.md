# KẾ HOẠCH NÂNG CẤP TRẢI NGHIỆM KHÁCH HÀNG & THỢ CẮT TÓC
## HairFit AI — Customer & Barber Feature Enhancement Plan

> **Tài liệu:** Kế Hoạch Nâng Cấp Chức Năng Phía Khách Hàng (Customer) & Thợ Cắt Tóc (Barber)  
> **Phiên bản:** v1.0  
> **Ngày lập:** 2026-10-04  
> **Tham chiếu cốt lõi:**  
> - `HairFit_AI_Specification.md` (Đặc tả chi tiết hệ thống)  
> - `HairFit_AI_Admin_Portal_Plan.md` (Kế hoạch phân hệ Admin Hub)  
> - `firestore.rules` (Quy tắc bảo mật Firestore)  

---

## 1. TỔNG QUAN KẾ HOẠCH & MỤC TIÊU CHIẾN LƯỢC

### 1.1 Hiện Trạng Của Hệ Thống Hiện Tại
HairFit AI đã hoàn thành xuất sắc các phân hệ nền tảng:
- Phân quyền Auth 3 vai trò (`customer`, `barber`, `admin`).
- Tư vấn kiểu tóc bằng AI 100% On-Device (Google ML Kit Contours + FaceShapeAnalyzer).
- Tìm thợ xung quanh qua OpenStreetMap miễn phí.
- Đặt lịch chống trùng slot bằng Firestore Transaction.
- Phân hệ Admin Control Hub toàn diện 5 Phase.

Tuy nhiên, khi xét trên góc độ **trải nghiệm người dùng thực tế (End-User Experience)**, vẫn còn những "khoảng trống" khiến ứng dụng chưa đạt đến độ hoàn hảo tối đa:
1. **Khách hàng sau khi đặt lịch bị "mất dấu":** Quay về Trang chủ không thấy thông tin lịch hẹn sắp tới, dễ quên giờ hẹn; kết quả quét dáng mặt AI bị mất sau khi thoát màn hình; chưa lưu được thợ ruột.
2. **Thợ thiếu công cụ quản lý kinh doanh & thời gian:** Không thấy doanh thu trong ngày; khi có việc bận đột xuất 1-2 tiếng thì không có cách nào tạm khóa slot; chưa có chỗ đăng ảnh các tác phẩm tóc đã cắt thực tế.
3. **Chưa có "Cầu nối AI" (AI Handshake) giữa Khách và Thợ:** Khách quét AI ra kiểu tóc và dáng mặt rất đẹp, nhưng khi đến tiệm thì thợ lại không xem được kết quả phân tích đó để tư vấn cho khách.

### 1.2 Mục Tiêu Nâng Cấp
Xây dựng chuỗi tính năng nâng cấp có tính thực chiến cao, tập trung vào 3 trụ cột:
```
           ┌────────────────────────────────────────────────────────┐
           │              HAIRFIT AI - USER EXPERIENCE              │
           └───────────────────────────┬────────────────────────────┘
                                       │
         ┌─────────────────────────────┼─────────────────────────────┐
         ▼                             ▼                             ▼
[1. Phía Khách Hàng]         [2. Cầu Nối Đột Phá]          [3. Phía Thợ Tóc]
- Card lịch hẹn sắp tới      - AI Haircut Handshake        - Doanh thu hàng ngày
- Lưu hồ sơ mặt AI           - Thợ xem dáng mặt & mẹo      - Khóa slot bận đột xuất
- Tiệm tóc yêu thích         - Nút Gọi điện thoại nhanh    - Lookbook ảnh tác phẩm
- Đổi giờ hẹn (Reschedule)   - Chỉ đường Google Maps       - Ghi chú khách quen (CRM)
```

---

## 2. CHI TIẾT CÁC TÍNH NĂNG NÂNG CẤP DÀNH CHO KHÁCH HÀNG

---

### TÍNH NĂNG C1: THẺ "LỊCH HẸN SẮP TỚI" TRÊN TRANG CHỦ (UPCOMING APPOINTMENT LIVE CARD)

#### 1. Vấn đề giải quyết
Hiện tại, sau khi khách đặt lịch hẹn thành công và quay lại Trang chủ (`customer_home_screen.dart`), màn hình hoàn toàn không hiển thị nhắc nhở nào. Khách phải tự nhớ và bấm qua tab Lịch hẹn mới kiểm tra được.

#### 2. Thiết kế chi tiết
* **Vị trí hiển thị:** Ngay dưới thanh tiêu đề AppBar của Trang chủ (phía trên Banner AI CTA).
* **Điều kiện hiển thị:** Chỉ xuất hiện khi khách có ít nhất 1 lịch hẹn ở trạng thái `confirmed` hoặc `pending` diễn ra trong ngày hôm nay hoặc ngày mai.
* **Giao diện thẻ (Card UI):**
  ```
  +-------------------------------------------------------------+
  | ⏰ LỊCH CẮT TÓC SẮP TỚI                     [Còn 1h 30m nữa] |
  | ─────────────────────────────────────────────────────────── |
  | Tiệm: 30Shine Cầu Giấy (Thợ: Nguyễn Văn Hùng)               |
  | Giờ hẹn: 14:00 - 14:30 Hôm nay                              |
  | Dịch vụ: Combo Cắt + Gội + Massage (120.000 đ)              |
  | ─────────────────────────────────────────────────────────── |
  | [🗺️ Chỉ đường]      [💬 Chat với thợ]      [👁️ Chi tiết]    |
  +-------------------------------------------------------------+
  ```
* **Hành động nhanh:**
  * **[Chỉ đường]:** Mở ứng dụng bản đồ dẫn đường tới tọa độ tiệm.
  * **[Chat với thợ]:** Nhảy thẳng vào phòng chat 1:1 với thợ tương ứng.

---

### TÍNH NĂNG C2: HỒ SƠ DÁNG MẶT & KIỂU TÓC AI ĐÃ LƯU (MY AI HAIR PROFILE)

#### 1. Vấn đề giải quyết
Sau khi khách hoàn thành quét mặt bằng ML Kit on-device, kết quả chỉ hiển thị trên `ai_result_screen.dart`. Khi khách thoát ra, kết quả bị xóa khỏi RAM. Lần sau muốn tìm thợ phù hợp, khách lại phải chụp ảnh quét lại.

#### 2. Thiết kế chi tiết
* **Cơ chế lưu trữ:**
  * Khi màn hình kết quả AI trả về dáng mặt (`faceShape`: Round, Oval, Square, Heart, Oblong), hệ thống tự động lưu vào trường `savedFaceShape` trong `UserModel` (Firestore) và cache vào `SharedPreferences`.
* **Hiển thị trên Trang chủ & Trang Profile:**
  * Widget *"Hồ Sơ Dáng Mặt AI Của Bạn"*:
    * Biểu tượng khuôn mặt kèm tên dáng mặt (ví dụ: *Mặt vuông góc cạnh - Square Face*).
    * Tỷ lệ các chỉ số hình học đã đo (Tỷ lệ chiều dài / chiều rộng mặt).
    * Danh sách 3 kiểu tóc chuẩn khuyên dùng được ghim sẵn.
    * Nút *"Tìm thợ cắt kiểu này ngay"* ➔ Chuyển sang Bản đồ và lọc sẵn kiểu tóc đó.
    * Nút *"Quét lại khuôn mặt"* nếu khách muốn đo lại góc chụp khác.

---

### TÍNH NĂNG C3: TIỆM TÓC YÊU THÍCH / THỢ RUỘT (FAVORITE BARBERS BOOKMARK)

#### 1. Vấn đề giải quyết
Khách hàng thường có 1-2 thợ cắt tóc quen ("thợ ruột"). Hiện tại, mỗi lần muốn đặt lịch, khách đều phải mở bản đồ và phóng to thu nhỏ tìm lại thợ.

#### 2. Thiết kế chi tiết
* **Thao tác yêu thích:** Thêm nút biểu tượng trái tim ❤️ ở góc trên màn hình `barber_detail_screen.dart`. Bấm để thêm/xóa thợ khỏi mảng `favoriteBarberIds` trong `users/{customerId}`.
* **Khu vực hiển thị:**
  * Một mục ngang *"Thợ ruột của bạn"* xuất hiện trên Trang chủ Khách hàng.
  * Hiển thị Avatar, Tên thợ, Tên tiệm, Đánh giá ⭐ và nút bấm **[Đặt lịch lại]** 1-chạm cực kỳ nhanh chóng.

---

### TÍNH NĂNG C4: BỘ LỌC NÂNG CAO TRÊN BẢN ĐỒ (`SEARCHMAPSCREEN`)

#### 1. Vấn đề giải quyết
Màn hình tìm kiếm hiện chỉ mới hỗ trợ lọc theo khoảng cách và kiểu tóc. Người dùng không thể lọc thợ theo túi tiền hoặc thời gian tiệm mở cửa.

#### 2. Thiết kế chi tiết
* **Lọc theo khoảng giá dịch vụ:**
  * Chips lựa chọn nhanh: *Tất cả*, *Dưới 100k*, *100k - 200k*, *Trên 200k*.
* **Lọc thợ đánh giá cao:**
  * Chip *⭐ 4.5+ sao* (chỉ hiển thị những thợ có rating cao, uy tín).
* **Lọc thợ đang mở cửa (Open Now):**
  * Tự động kiểm tra thời gian hiện tại của thiết bị so với cấu hình `workingHours` (ví dụ: Thứ Hai 09:00 - 19:00). Nếu tiệm đang trong khung giờ mở cửa thì mới hiển thị marker.

---

### TÍNH NĂNG C5: ĐỔI GIỜ HẸN LINH HOẠT (RESCHEDULE APPOINTMENT)

#### 1. Vấn đề giải quyết
Khách có việc đột xuất vào giờ đã hẹn. Hiện tại khách bắt buộc phải bấm "Hủy lịch", sau đó quay lại trang chi tiết tiệm để đặt lịch mới. Trải nghiệm này gây đứt gãy và dễ làm mất khách.

#### 2. Thiết kế chi tiết
* Thêm nút **[Đổi giờ hẹn]** bên cạnh nút [Hủy lịch] trong màn hình `customer_appointments_screen.dart` (áp dụng cho các lịch ở trạng thái `pending` hoặc `confirmed` trước giờ hẹn tối thiểu 1 tiếng).
* Khi bấm, mở BottomSheet chọn ngày và chọn lại slot thời gian mới của cùng thợ đó.
* **Xử lý Transaction:**
  * Xóa slot cũ trong `bookedSlots`.
  * Tạo slot mới trong `bookedSlots`.
  * Cập nhật lại ngày giờ và slotId trong `appointments`.

---

## 3. CHI TIẾT CÁC TÍNH NĂNG NÂNG CẤP DÀNH CHO THỢ CẮT TÓC

---

### TÍNH NĂNG B1: THỐNG KÊ DOANH THU & LƯỢT KHÁCH HÀNG NGÀY (BARBER DAILY EARNINGS)

#### 1. Vấn đề giải quyết
Thợ cắt tóc vào ứng dụng chỉ thấy danh sách lịch hẹn khô khan, không có số liệu kinh doanh để theo dõi thu nhập và đánh giá năng suất làm việc.

#### 2. Thiết kế chi tiết
* **Header tóm tắt doanh thu:** Đặt ngay trên đầu màn hình `barber_appointments_screen.dart`:
  ```
  +-------------------------------------------------------------+
  | 💈 TỔNG KẾT HÔM NAY (04/10/2026)                            |
  | ─────────────────────────────────────────────────────────── |
  | 💵 Doanh thu ước tính:  750.000 đ                           |
  | 👥 Đã hoàn tất:         5 ca                                |
  | ⏳ Đang chờ đón khách:  2 ca                                |
  | ⭐ Điểm uy tín tiệm:     4.9 (48 đánh giá)                   |
  +-------------------------------------------------------------+
  ```
* Tự động tính toán dựa trên các lịch hẹn hôm nay có trạng thái `completed` và `confirmed`.

---

### TÍNH NĂNG B2: KHÓA SLOT BẬN ĐỘT XUẤT / GIỜ NGHỈ (QUICK BREAK / EMERGENCY SLOT BLOCK)

#### 1. Vấn đề giải quyết
Thợ có việc riêng đột xuất 1-2 tiếng (đi đón con, nghỉ trưa muộn, cúp điện, sửa ghế cắt tóc). Hiện tại thợ không có cách nào chặn khách đặt vào khung giờ đó mà không phải vào sửa lại toàn bộ lịch làm việc trong tuần.

#### 2. Thiết kế chi tiết
* Trên màn hình quản lý lịch của thợ, bổ sung nút **[+ Khóa giờ nghỉ / Bận đột xuất]**.
* Thợ chọn ngày và chọn 1 hoặc nhiều slot giờ (ví dụ: `14:00 - 14:30`, `14:30 - 15:00`).
* Nhập lý do nhanh (ví dụ: *Nghỉ trưa, Việc cá nhân, Mất điện*).
* Hệ thống ghi một bản ghi đặc biệt vào `bookedSlots` với cờ `isBlockedByBarber: true`. Khách hàng khi xem lịch sẽ thấy slot này chuyển sang màu xám "Thợ bận" và không thể bấm chọn.

---

### TÍNH NĂNG B3: CÔNG TẮC "TẠM DỪNG NHẬN KHÁCH HÔM NAY" (PAUSE BOOKINGS TODAY)

#### 1. Vấn đề giải quyết
Những ngày cuối tuần hoặc ngày lễ, khách vãng lai đến quán quá đông khiến thợ không thể nhận thêm khách đặt qua app.

#### 2. Thiết kế chi tiết
* Công tắc Switch trên AppBar của Thợ: **"Nhận khách đặt lịch" ⇋ "Tạm ngưng hôm nay"**.
* Khi gạt sang "Tạm ngưng", hồ sơ thợ sẽ tạm thời không cho phép chọn slot đặt hẹn trong ngày hôm nay (khách chỉ có thể đặt từ ngày mai trở đi).

---

### TÍNH NĂNG B4: THƯ VIỆN TÁC PHẨM THỰC TẾ (BARBER LOOKBOOK / PORTFOLIO)

#### 1. Vấn đề giải quyết
Khách hàng đi cắt tóc luôn ra quyết định dựa trên **hình ảnh thực tế**. Hồ sơ thợ hiện tại chỉ có ảnh avatar và ảnh bìa cover, chưa có album các mẫu tóc thợ đã từng cắt (Fade, uốn, tạo kiểu).

#### 2. Thiết kế chi tiết
* Trong `barber_edit_screen.dart`, bổ sung mục **"Album Tác Phẩm Nổi Bật (Portfolio)"** cho phép tải lên tối đa 6 - 8 ảnh chất lượng cao.
* Trên trang chi tiết thợ mà khách hàng nhìn thấy (`barber_detail_screen.dart`), hiển thị một Grid ảnh tác phẩm trực quan. Khách bấm vào xem ảnh phóng to, thấy thợ cắt đẹp sẽ bấm Đặt lịch ngay lập tức.

---

### TÍNH NĂNG B5: GHI CHÚ KHÁCH QUEN (CLIENT NOTES / MINI CRM)

#### 1. Vấn đề giải quyết
Thợ cắt tóc chuyên nghiệp luôn nhớ thói quen của khách. Nhưng khi có hàng chục khách đặt qua app, thợ không thể nhớ hết ai thích cắt thế nào.

#### 2. Thiết kế chi tiết
* Trên thẻ chi tiết lịch hẹn của thợ, có ô **"Ghi chú khách hàng"** (Chỉ thợ mới nhìn thấy, khách không thấy):
  * Ví dụ thợ lưu: *"Anh Tuấn - Da đầu nhạy cảm, thích cạo tông đơ cữ 2, dùng sáp mùi gỗ nhẹ"*.
  * Lần sau khi anh Tuấn đặt lịch tiếp, thợ mở lịch hẹn ra là thấy ngay ghi chú cũ.

---

## 4. TÍNH NĂNG CẦU NỐI ĐỘT PHÁ: "AI HAIRCUT HANDSHAKE" (THE WOW FACTOR)

> 🌟 **Đây là tính năng độc nhất vô nhị tạo sự khác biệt hoàn toàn cho HairFit AI so với mọi app đặt lịch thông thường trên thị trường.**

### 4.1 Cơ chế hoạt động
```
[Khách chụp ảnh quét mặt] ──► [AI nhận diện: Mặt Tròn] ──► [Khách chọn: Undercut Cổ Điển]
                                                                        │
                                                                 [Bấm Đặt Lịch]
                                                                        │
                                                                        ▼
                                                   [Thẻ Lịch Hẹn Phía Thợ Tự Động Hiện:]
                                                   • Dáng mặt khách: Tròn (Round)
                                                   • Ảnh mẫu kiểu tóc khách muốn cắt
                                                   • Lời khuyên kỹ thuật từ AI cho thợ
```

### 4.2 Giao diện hiển thị phía Thợ Cắt Tóc
Khi thợ mở chi tiết lịch hẹn của khách, sẽ có một thẻ nổi bật viền màu tím công nghệ:

```
+-------------------------------------------------------------+
| 🤖 YÊU CẦU TƯ VẤN TỪ HAIRFIT AI                             |
| ─────────────────────────────────────────────────────────── |
| • Kiểu tóc khách chọn: Undercut Cổ Điển                     |
| • Dáng mặt AI phân tích: Mặt tròn (Round Face)              |
| • Mẹo kỹ thuật từ AI:                                       |
|   "Nên cắt ngắn sát hai bên (High Fade) và vuốt phồng       |
|    phần mái đỉnh đầu để tạo cảm giác khuôn mặt dài và       |
|    thanh thoát hơn."                                        |
|                                                             |
| [🖼️ Xem ảnh mẫu kiểu tóc]       [📸 Xem ảnh góc mặt khách]  |
+-------------------------------------------------------------+
```

### 4.3 Giá trị mang lại
- **Khách hàng:** Cảm thấy yêu cầu của mình được thấu hiểu sâu sắc, không cần phải giải thích dài dòng hay lo lắng thợ cắt sai ý.
- **Thợ cắt tóc:** Có ngay tài liệu tham khảo để bắt đầu cuộc trò chuyện với khách cực kỳ chuyên nghiệp và tự tin.
- **Dự án:** Trở thành điểm sáng đắt giá nhất khi trình diễn demo đồ án!

---

### 4.4 Nút Gọi Điện Thoại Nhanh (`tel:`)
- Bổ sung nút bấm biểu tượng điện thoại 📞 trên thẻ lịch hẹn của cả 2 phía.
- Sử dụng `url_launcher` mở ngay trình quay số của điện thoại để khách gọi cho tiệm (hỏi đường) hoặc thợ gọi cho khách (xác nhận giờ đến).

---

## 5. THIẾT KẾ CẬP NHẬT CƠ SỞ DỮ LIỆU (FIRESTORE SCHEMA UPDATES)

Để hỗ trợ toàn bộ các tính năng trên mà vẫn giữ vững nguyên tắc **Zero-Cost & Không phá vỡ dữ liệu cũ**:

### 5.1 Cập nhật `users/{userId}` (UserModel)
```dart
// Bổ sung các trường tùy chọn:
String? savedFaceShape;          // "round", "oval", "square", "heart", "oblong"
List<String> savedHairstyleIds;  // Danh sách ID kiểu tóc AI gợi ý gần nhất
List<String> favoriteBarberIds;  // Danh sách ID thợ yêu thích của khách
```

### 5.2 Cập nhật `barberProfiles/{barberId}` (BarberProfileModel)
```dart
// Bổ sung các trường tùy chọn:
List<String> portfolioUrls;        // Danh sách ảnh mẫu tóc thực tế của thợ
bool isAcceptingBookingsToday;    // Công tắc tạm ngưng nhận khách hôm nay (mặc định true)
```

### 5.3 Cập nhật `appointments/{appointmentId}` (AppointmentModel)
```dart
// Bổ sung các trường lưu vết AI:
String? customerFaceShape;       // Dáng mặt AI của khách lúc đặt lịch
String? aiStylingTip;            // Lời khuyên kỹ thuật của AI gửi cho thợ
String? hairstyleImageUrl;       // Ảnh mẫu kiểu tóc khách đã chọn
String? barberPrivateNote;       // Ghi chú riêng của thợ về khách quen này
```

### 5.4 Cập nhật `bookedSlots/{slotId}` (BookedSlotModel)
```dart
// Bổ sung cờ đánh dấu:
bool isBlockedByBarber;          // true nếu đây là slot thợ tự khóa để nghỉ đột xuất
String? blockReason;             // "Nghỉ trưa", "Việc cá nhân"...
```

---

## 6. LỘ TRÌNH THỰC HIỆN THEO GIAI ĐOẠN (5-PHASE EXECUTION ROADMAP)

```
[Phase 1] ───► [Phase 2] ───► [Phase 3] ───► [Phase 4] ───► [Phase 5]
Core Wow       Thống Kê       Lưu Hồ Sơ      Bộ Lọc Nâng    Portfolio &
Home & AI      Thợ & Khóa     Dáng Mặt AI    Cao & Đổi      Ghi Chú Khách
Handshake      Slot Bận       & Thợ Ruột     Lịch Hẹn       Quen
```

### 🎯 Phase 1: Core Wow Factors — Card Lịch Sắp Tới & AI Handshake (P0)
* **Nhiệm vụ 1.1:** Bổ sung các trường `customerFaceShape`, `aiStylingTip`, `hairstyleImageUrl` vào `AppointmentModel` và luồng đặt lịch `booking_screen.dart`.
* **Nhiệm vụ 1.2:** Xây dựng widget **UpcomingAppointmentCard** trên `CustomerHomeScreen` (hiển thị lịch hôm nay, nút chỉ đường và chat).
* **Nhiệm vụ 1.3:** Xây dựng widget **AIHaircutHandshakeCard** trong chi tiết lịch hẹn phía thợ (`barber_appointments_screen.dart`).
* **Nhiệm vụ 1.4:** Tích hợp nút Gọi điện thoại nhanh (`url_launcher`).

### 🎯 Phase 2: Năng Suất Thợ — Báo Cáo Doanh Thu & Khóa Slot Đột Xuất (P1)
* **Nhiệm vụ 2.1:** Xây dựng thanh tóm tắt **Barber Daily Earnings Header** trên màn hình lịch thợ (Doanh thu hôm nay, lượt khách hoàn tất).
* **Nhiệm vụ 2.2:** Xây dựng tính năng **Khóa slot bận đột xuất (Quick Break)** cho phép thợ tự khóa 1-chạm khung giờ nghỉ.
* **Nhiệm vụ 2.3:** Bổ sung công tắc **Tạm ngưng nhận khách hôm nay** trên AppBar của thợ.

### 🎯 Phase 3: Cá Nhân Hóa Khách Hàng — Lưu Hồ Sơ Mặt AI & Thợ Ruột (P1)
* **Nhiệm vụ 3.1:** Tự động lưu `savedFaceShape` vào Firestore và SharedPreferences sau khi phân tích AI xong.
* **Nhiệm vụ 3.2:** Xây dựng widget **"Hồ Sơ Dáng Mặt Của Bạn"** trên Home/Profile hiển thị dáng mặt và nút bấm tìm thợ phù hợp.
* **Nhiệm vụ 3.3:** Xây dựng tính năng **Thả tim ❤️ Thợ yêu thích** và danh sách "Thợ ruột" trên Trang chủ.

### 🎯 Phase 4: Tối Ưu Tiện Ích — Bộ Lọc Bản Đồ & Đổi Giờ Hẹn (P2)
* **Nhiệm vụ 4.1:** Bổ sung bộ lọc khoảng giá và lọc thợ mở cửa hôm nay trên `SearchMapScreen`.
* **Nhiệm vụ 4.2:** Xây dựng tính năng **Đổi giờ hẹn (Reschedule)** trên `CustomerAppointmentsScreen`.

### 🎯 Phase 5: Hoàn Thiện Hồ Sơ — Portfolio Tác Phẩm & CRM Khách Quen (P2)
* **Nhiệm vụ 5.1:** Bổ sung mục quản lý ảnh tác phẩm **Portfolio Uploader** trong `barber_edit_screen.dart`.
* **Nhiệm vụ 5.2:** Hiển thị Grid ảnh tác phẩm trên `barber_detail_screen.dart` cho khách xem.
* **Nhiệm vụ 5.3:** Tính năng **Ghi chú khách quen (Client Notes)** dành riêng cho thợ.
* **Nhiệm vụ 5.4:** Kiểm thử toàn diện và nghiệm thu hệ thống.

---

## 7. TIÊU CHÍ NGHIỆM THU (ACCEPTANCE CRITERIA)

1. ✅ **Trang chủ Khách hàng:** Khi có lịch hẹn hôm nay, mở app lên thấy ngay Card lịch sắp tới đếm ngược giờ, bấm [Chỉ đường] mở bản đồ ngoài, bấm [Chat] vào đúng phòng chat với thợ.
2. ✅ **AI Handshake:** Khách chọn kiểu tóc từ AI rồi đặt lịch, thợ mở lịch hẹn ra thấy ngay ảnh kiểu tóc mẫu, dáng mặt khách và lời khuyên cắt fade/layer từ AI.
3. ✅ **Thống kê thợ:** Thợ hoàn tất một lịch hẹn 150.000 đ thì doanh thu hôm nay trên Header thợ tự động nhảy thêm 150.000 đ.
4. ✅ **Khóa slot đột xuất:** Thợ khóa slot 14:00 - 14:30 vì bận việc, khách hàng vào tiệm đó đặt lịch sẽ thấy slot 14:00 bị mờ và không thể đặt được.
5. ✅ **Lưu dáng mặt AI:** Quét mặt xong tắt app mở lại, khách vẫn thấy hồ sơ dáng mặt của mình trên Trang chủ kèm các kiểu tóc phù hợp.
6. ✅ **Độ ổn định:** Toàn bộ dự án vượt qua `flutter analyze` 0 lỗi và tất cả unit test đều Passed.
