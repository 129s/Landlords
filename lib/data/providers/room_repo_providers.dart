import 'package:landlords_3/data/repositories/room_repo_impl.dart';
import 'package:landlords_3/domain/repositories/room_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final roomRepoProvider = Provider<RoomRepository>((ref) {
  return RoomRepoImpl();
});
