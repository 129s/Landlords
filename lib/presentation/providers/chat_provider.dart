import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/data/providers/repo_providers.dart';
import 'package:landlords_3/domain/entities/message_model.dart';

final chatProvider = StreamProvider.family<List<MessageModel>, String>((
  ref,
  roomId,
) {
  return ref.watch(roomRepoProvider).watchMessages(roomId);
});
