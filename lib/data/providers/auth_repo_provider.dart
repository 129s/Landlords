import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/data/repositories/auth_repo_impl.dart';
import 'package:landlords_3/domain/repositories/auth_repo.dart';

final authRepoProvider = Provider<AuthRepository>((ref) {
  return AuthRepoImpl();
});
