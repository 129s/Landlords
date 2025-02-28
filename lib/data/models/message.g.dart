// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
  id: json['id'] as String,
  roomId: json['roomId'] as String,
  senderId: json['senderId'] as String,
  senderName: json['senderName'] as String,
  content: json['content'] as String,
  timestamp: Message._fromJson((json['timestamp'] as num).toInt()),
);

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
  'id': instance.id,
  'roomId': instance.roomId,
  'senderId': instance.senderId,
  'senderName': instance.senderName,
  'content': instance.content,
  'timestamp': Message._toJson(instance.timestamp),
};
