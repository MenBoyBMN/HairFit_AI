// ============================================================================
// File: lib/features/ai_chat/domain/ai_chat_message.dart
// Purpose: Model định nghĩa tin nhắn trong phòng Chat AI Tư Vấn Kiểu Tóc.
// ============================================================================

class AIChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const AIChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory AIChatMessage.fromMap(Map<String, dynamic> map) {
    return AIChatMessage(
      id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      text: map['text'] ?? '',
      isUser: map['isUser'] ?? false,
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
    );
  }
}

// CreBy: MenBoyBMN
