import 'dart:async';

import 'package:landlords_3/core/services/socket_service.dart';
import 'package:landlords_3/data/models/message.dart';
import 'package:logger/logger.dart';

/// ChatService 类：
///
/// 单例类，用于管理聊天相关的 Socket 事件和数据。
/// 它依赖于 SocketService 来进行底层的 Socket 通信。
///
/// 主要功能：
///   - 提供发送聊天消息的方法，并发送相应的 Socket 事件。
///   - 监听服务器发送的聊天消息事件。
///   - 提供聊天消息列表的流，以便其他组件可以监听聊天消息的变化。
///
/// 使用方式：
///   - 通过 ChatService() 获取单例实例。
///   - 使用 sendMessage() 方法发送聊天消息。
///   - 使用 messageStream 监听聊天消息的变化。
///   - 使用 onNewMessage() 方法监听新的聊天消息事件 (可选)。

class ChatService {
  final _logger = Logger();
  final SocketService _socketService = SocketService();

  // 聊天消息列表
  final List<Message> _messages = [];

  // 流控制
  final _messageController = StreamController<List<Message>>.broadcast();

  // get
  Stream<List<Message>> get messageStream => _messageController.stream;
  List<Message> get messages => _messages;

  // 单例
  static final _instance = ChatService._internal();
  ChatService._internal() {
    _setupEventListeners();
  }
  factory ChatService() => _instance;

  // 初始化事件监听器
  void _setupEventListeners() {
    _socketService.on<Map<String, dynamic>>('new_message', _handleNewMessage);
    // 添加其他聊天相关的事件监听器
  }

  // 处理新的聊天消息事件
  void _handleNewMessage(Map<String, dynamic> data) {
    try {
      final message = Message.fromJson(data);
      _messages.add(message);
      _messageController.add(_messages);
      _logger.i('New message received: ${message.toJson()}');
    } catch (e) {
      _logger.e('Error parsing new message: $e');
    }
  }

  // 发送聊天消息
  void sendMessage(Message message) {
    _socketService.emit('send_message', message.toJson());
    _logger.i('Sending message: ${message.toJson()}');
  }

  // 释放资源
  void dispose() {
    _messageController.close();
    // 移除所有事件监听器，避免内存泄漏
    _socketService.off('new_message');
    // 移除其他事件监听器
  }
}
