# Quy Tắc Hành Vi & Sử Dụng Tool Của Agent

## 1. Phong Cách Giao Tiếp & Phản Hồi
- **Đúng trọng tâm**: Trả lời ngắn gọn, trực diện, không lan man, không lặp lại context đã có trong lịch sử trò chuyện.
- **Ngôn ngữ phản hồi**: Mặc định giao tiếp với người dùng bằng **tiếng Việt**, trừ khi người dùng có yêu cầu cụ thể khác.
- **Quy chuẩn mã nguồn**: Toàn bộ mã nguồn, tên class, hàm, biến, comment trong code, và commit message bắt buộc phải viết bằng **tiếng Anh** theo chuẩn quy ước (naming conventions).

## 2. Chiến Lược Đọc File Có Scope (Context Optimization)
- **Tránh đọc nguyên file lớn**: Đối với các file dài hơn 50 dòng, luôn truyền `StartLine` và `EndLine` (hoặc offset/limit) để chỉ nạp vùng mã cần phân tích.
- **Tìm kiếm có chủ đích**: Dùng `grep_search` để định vị chính xác vị trí biểu thức / hàm / biến trước khi đọc chi tiết.

## 3. Ưu Tiên Tool Chuyên Dụng Thay Vì Shell Commands
- **Đọc file**: Dùng `view_file` (hỗ trợ line slice, byte offset).
- **Sửa file**: Dùng `replace_file_content` hoặc `multi_replace_file_content` để tạo diff chính xác, không dùng `sed`, `awk`, `powershell scripts` hoặc echo đè file.
- **Tìm kiếm**: Dùng `grep_search` thay vì gọi lệnh bash `grep` hoặc `findstr`.
- **Liệt kê thư mục**: Dùng `list_dir` thay vì `ls` hoặc `dir`.
- Lệnh shell (`run_command`) chỉ dành riêng cho các tác vụ công cụ như: `flutter analyze`, `flutter test`, `dart format`, hoặc `git`.

## 4. Bắt Buộc Gắn Credit Note Khi Tạo File Mới
- Bất kỳ file mã nguồn mới nào được tạo trong dự án (nhất là các file `.dart` trong `lib/` và `test/`), ở dòng cuối cùng của file bắt buộc phải thêm ghi chú:
  ```dart
  // CreBy: MenBoyBMN
  ```
- Đối với các file tài liệu hoặc cấu hình khác (`.md`, `.yaml`, `.py`, `.sh`), chèn định dạng comment tương ứng ở cuối trang (`# CreBy: MenBoyBMN` hoặc `<!-- CreBy: MenBoyBMN -->`).

