import 'package:landlords_3/domain/entities/user_model.dart';

abstract class AuthRepository {
  /// 游客登录
  Future<UserModel> guestLogin(String username);

  /// 获取用户信息
  // Future<UserModel> getUser(String userId); // 可选，如果需要从本地或远程获取用户信息
}
