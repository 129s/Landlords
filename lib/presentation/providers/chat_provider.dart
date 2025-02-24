import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/data/providers/service_providers.dart';
import 'package:landlords_3/data/models/message.dart';

final chatProvider = StreamProvider.family<List<Message>, String>((
  ref,
  roomId,
) {
  return ref.watch(chatServiceProvider).watchMessages(roomId);
});
