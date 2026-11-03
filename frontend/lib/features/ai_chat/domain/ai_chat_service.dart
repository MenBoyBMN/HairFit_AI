// ============================================================================
// File: lib/features/ai_chat/domain/ai_chat_service.dart
// Purpose: Dịch vụ AI Chat thông minh chuyên gia tư vấn kiểu tóc & chăm sóc tóc.
// ============================================================================

import 'package:flutter/foundation.dart';

@immutable
class AIChatService {
  const AIChatService();

  Future<String> getAIResponse(String userQuery) async {
    // Simulate thinking delay for natural chat experience
    await Future.delayed(const Duration(milliseconds: 600));

    final query = userQuery.toLowerCase().trim();

    if (query.contains('mặt tròn') || query.contains('tròn')) {
      return 'Đối với khuôn mặt tròn, bạn nên chọn các kiểu tóc tạo độ phồng ở đỉnh đầu và ôm gọn hai bên mang tai như **Two Block**, **Side Part phồng**, hoặc **Buzz Cut ngắn gọn**. Điều này giúp khuôn mặt trông thon gọn và thanh thoát hơn rất nhiều!';
    } else if (query.contains('mặt vuông') || query.contains('vuông') || query.contains('góc cạnh')) {
      return 'Khuôn mặt vuông có các đường nét góc cạnh rất nam tính và cá tính. Các kiểu tóc phù hợp nhất là **Undercut vuốt ngược**, **Pompadour**, hoặc **Crew Cut**. Chúng sẽ làm mềm mại các góc hàm nhưng vẫn giữ được sự nam tính mạnh mẽ.';
    } else if (query.contains('mặt trái xoan') || query.contains('oval') || query.contains('trái xoan')) {
      return 'Chúc mừng bạn sở hữu dáng mặt **Oval (Trái xoan)** - đây là dáng mặt tỷ lệ vàng! Bạn có thể hợp với hầu hết mọi kiểu tóc từ truyền thống đến hiện đại như **Crop**, **Quiff**, **Mullet**, hay **Side Part** cổ điển.';
    } else if (query.contains('sáp') || query.contains('vuốt') || query.contains('gôm') || query.contains('keo')) {
      return 'Để giữ nếp tóc chuẩn salon suốt cả ngày, bạn nên chọn loại sáp (wax) có độ giữ nếp cao (Hold từ 4/5 trở lên) và độ bóng mờ (Matte Finish) để trông tự nhiên nhất. Ví dụ như các dòng sáp gốc đất sét (Clay) phù hợp cho tóc dày và cứng.';
    } else if (query.contains('rụng tóc') || query.contains('thưa') || query.contains('hói')) {
      return 'Với tóc thưa hoặc mỏng, bạn nên tránh để tóc quá dài hoặc ép sát vào da đầu. Hãy chọn kiểu tóc ngắn gọn gàng như **Crop textured**, **Short Quiff** kết hợp sấy phồng chân tóc để tạo cảm giác mái tóc dày dặn hơn.';
    } else if (query.contains('đặt lịch') || query.contains('salon') || query.contains('thợ')) {
      return 'Bạn có thể dễ dàng tìm kiếm thợ cắt tóc uy tín gần nhất và đặt lịch hẹn ngay trên ứng dụng bằng cách vào mục **Bản đồ & Tìm thợ**, chọn salon ưng ý và chọn khung giờ phù hợp. Đặc biệt, kết quả tư vấn AI của bạn sẽ tự động được gửi kèm cho thợ qua tính năng AI Handshake!';
    } else if (query.contains('xin chào') || query.contains('hi') || query.contains('hello') || query.contains('chào')) {
      return 'Xin chào! Tôi là Trợ lý AI chuyên gia tạo mẫu tóc của HairFit AI. Tôi có thể giúp gì cho bạn hôm nay? Bạn có thể hỏi về kiểu tóc hợp dáng mặt, mẹo vuốt sáp hay cách đặt lịch hẹn nhé!';
    } else {
      return 'Cảm ơn câu hỏi của bạn! Để có kết quả chính xác nhất cho mái tóc của bạn, tôi khuyên bạn nên sử dụng tính năng **Quét khuôn mặt AI** ngay trên app để hệ thống phân tích chi tiết tỷ lệ hình học và đề xuất các kiểu tóc chân ái phù hợp nhất.';
    }
  }
}

// CreBy: MenBoyBMN
