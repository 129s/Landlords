import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/data/providers/service_providers.dart';
import 'package:landlords_3/data/models/message_model.dart';

final chatProvider = StreamProvider.family<List<MessageModel>, String>((
  ref,
  roomId,
) {
  return ref.watch(chatServiceProvider).watchMessages(roomId);
});
