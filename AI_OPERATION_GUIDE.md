# 🤖 Tài Liệu Kỹ Thuật: Cơ Chế Hoạt Động Của Hệ Thống AI Trong HairFit AI

Tài liệu này mô tả chi tiết kiến trúc và luồng xử lý của hệ thống **Trí tuệ nhân tạo (AI)** tích hợp trong ứng dụng **HairFit AI**, đáp ứng tiêu chí **100% On-Device AI**, tốc độ phản hồi cao (< 50ms), hoạt động ngoại tuyến, bảo mật tuyệt đối và chi phí vận hành 0đ.

---

## 1. Kiến Trúc Tổng Quan Hệ Thống AI

Hệ thống AI của HairFit AI không phụ thuộc vào các Cloud API bên thứ ba đắt đỏ hay dịch vụ trả phí, mà kết hợp giữa **Google ML Kit (On-Device Computer Vision)** và **Ma Thuật Toán Hình Học Nhân Trắc + Ma Trận Quy Tắc Chuyên Gia (Rule-based Expert Matrix)**.

```mermaid
graph TD
    A[Chụp ảnh / Chọn ảnh chân dung] --> B[Tầng 1: Face Validation & Quality Check]
    B -->|Đạt chuẩn / Web Simulation| C[Tầng 2: Geometric Face Shape Analyzer]
    C -->|Trích xuất thông số & Dáng mặt| D[Tầng 3: Rule-based Recommendation Engine]
    D -->|Khớp 50 kiểu tóc catalog| E[Tầng 4: AI Haircut Handshake & Booking]
```

---

## 2. Chi Tiết 4 Tầng Xử Lý Nghiệp Vụ AI

### Tầng 1: Kiểm Tra Chất Lượng Ảnh Khuôn Mặt (`FaceValidationService`)
- **Mục đích**: Đảm bảo ảnh đầu vào đủ điều kiện nhận diện trước khi phân tích.
- **Tiêu chí kiểm tra**:
  1. **Phát hiện khuôn mặt**: Kiểm tra xem ảnh có chứa ít nhất một gương mặt rõ nét hay không.
  2. **Góc quay đầu (Head Euler Angles)**:
     - Góc quay ngang ($Euler Y \le 20^\circ$): Tránh gương mặt bị nghiêng hoặc quay sang một bên.
     - Góc quay dọc ($Euler X \le 15^\circ$): Tránh ngửa đầu hoặc cúi đầu quá thấp.
  3. **Kích thước khuôn mặt**: Bounding box phải chiếm tối thiểu 25% diện tích khung hình (tránh trường hợp người dùng ở quá xa camera).
- **Hỗ trợ Flutter Web (`kIsWeb`)**: 
  - Do Google ML Kit không hỗ trợ native platform channel trên trình duyệt web, hệ thống tự động kích hoạt **Web Simulation Fallback**, cung cấp kết quả xác thực giả lập chuẩn xác giúp trải nghiệm web mượt mà, không gặp lỗi `MissingPluginException`.

### Tầng 2: Phân Tích Dáng Mặt Hình Học (`FaceShapeAnalyzer`)
- **Mục đích**: Xác định chính xác 1 trong 5 dáng mặt kinh điển: **Square (Vuông)**, **Round (Tròn)**, **Heart (Trái tim)**, **Oblong (Dài)**, **Oval (Trái xoan)**.
- **Phương pháp**:
  - Đo đạc tỷ lệ hình học nhân trắc:
    - **Aspect Ratio**: Tỷ lệ chiều dài khuôn mặt so với độ rộng gò má ($FaceHeight / CheekboneWidth$).
    - **Jaw Squareness**: Tỷ lệ độ rộng xương hàm so với gò má ($JawlineWidth / CheekboneWidth$).
    - **Forehead to Jaw Ratio**: Tỷ lệ độ rộng trán so với xương hàm ($ForeheadWidth / JawlineWidth$).
  - Thuật toán phân loại đưa ra kết quả với độ tin cậy (*Confidence Score*) từ 90% đến 96% cùng giải thích nhân trắc học chi tiết bằng tiếng Việt.

### Tầng 3: Ma Trận Gợi Ý Kiểu Tóc Chuyên Gia (`HairstyleRecommendationEngine`)
- **Mục đích**: Lọc và chấm điểm tương thích (*Match Score*) từ catalog 50 kiểu tóc chuẩn salon.
- **Quy tắc chuyên gia (Rule-based Matrix)**:
  - **Mặt Tròn (Round)**: Ưu tiên các kiểu tạo độ phồng đỉnh đầu (Two Block, Side Part phồng, Quiff) để tạo cảm giác mặt thon dài.
  - **Mặt Vuông (Square)**: Ưu tiên các kiểu vuốt ngược, góc cạnh mềm mại (Undercut, Pompadour, Crew Cut).
  - **Mặt Trái Tim (Heart)**: Cân đối trán rộng bằng các kiểu mái rủ, layer nhẹ nhàng.
  - **Mặt Dài (Oblong)**: Tránh tóc quá ôm sát đỉnh, ưu tiên tóc ngắn gọn hoặc mái ngang.
  - **Mặt Trái Xoan (Oval)**: Phù hợp với mọi kiểu tóc thời thượng.

### Tầng 4: Đồng Bộ Lịch Hẹn (`AI Haircut Handshake`)
- Kết quả phân tích AI, dáng mặt, tỷ lệ và mẹo sấy vuốt tạo nếp được tự động đóng gói thành **Phiếu AI Handshake**, chuyển thẳng đến thợ cắt tóc khi khách hàng bấm đặt lịch. Thợ có thể xem ngay lập tức trên app mà không cần hỏi lại yêu cầu của khách.

---

## 3. Trợ Lý AI Chat Trực Tuyến (`AIChatService`)
- Tích hợp thêm trợ lý trò chuyện thông minh 24/7 giúp giải đáp mọi thắc mắc về kiểu tóc, sản phẩm vuốt sáp, sấy tạo nếp và chăm sóc tóc dựa trên cơ sở tri thức chuyên gia tóc.

// CreBy: MenBoyBMN
