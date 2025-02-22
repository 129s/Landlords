// data\providers\room_repo_providers.dart
import 'package:landlords_3/data/repositories/room_repo_impl.dart';
import 'package:landlords_3/domain/repositories/room_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final roomRepoProvider = Provider.family<RoomRepository, Ref>((ref, refValue) {
  // Use Provider.family
  return RoomRepoImpl(refValue); // Pass ref to RoomRepoImpl
});
