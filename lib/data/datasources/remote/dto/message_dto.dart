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
      id: json['id'],
      roomId: json['roomId'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      type: _parseType(json['type']),
    );
  }

  static MessageType _parseType(String type) {
    switch (type) {
      case 'system':
        return MessageType.system;
      case 'image':
        return MessageType.image;
      default:
        return MessageType.text;
    }
  }
}
