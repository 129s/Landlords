import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/data/providers/room_repo_providers.dart';
import 'package:landlords_3/domain/entities/message_model.dart';

final chatMessagesProvider = StreamProvider.family<List<MessageModel>, String>((
  ref,
  roomId,
) {
  return ref.watch(roomRepoProvider).watchMessages(roomId);
});
