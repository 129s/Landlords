import 'package:landlords_3/domain/entities/message_model.dart';

class MessageDTO extends MessageModel {
  MessageDTO({
    required super.id,
    required super.roomId,
    required super.senderId,
    required super.senderName,
    required super.content,
    required super.timestamp,
    required super.type,
  });

  factory MessageDTO.fromJson(Map<String, dynamic> json) {
    return MessageDTO(
      id: json['id'] as String,
      roomId: json['roomId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      content: json['content'] as String,
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      type: _parseType(json['type'] as String? ?? ''),
    );
  }

  static MessageType _parseType(String typeString) {
    switch (typeString.toLowerCase()) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      default:
        return MessageType.text; // Default to text if unknown
    }
  }
}
