import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable()
class Message {
  final String id;
  final String roomId;
  final String senderId;
  final String senderName;
  final String content;
  @JsonKey(fromJson: _fromJson, toJson: _toJson)
  final DateTime timestamp;

  Message({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);

  static DateTime _fromJson(int timestamp) =>
      DateTime.fromMillisecondsSinceEpoch(timestamp);
  static int _toJson(DateTime time) => time.millisecondsSinceEpoch;
}
