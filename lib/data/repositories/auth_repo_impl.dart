import 'package:landlords_3/domain/entities/user_model.dart';
import 'package:landlords_3/domain/repositories/auth_repo.dart';
import 'package:landlords_3/core/network/socket_service.dart'; // 引入 SocketService
import 'package:dio/dio.dart';

class AuthRepoImpl implements AuthRepository {
  final SocketService _socketService = SocketService(); // 获取 SocketService 实例
  final Dio _dio = Dio(); // 创建 Dio 实例

  @override
  Future<UserModel> guestLogin(String username) async {
    try {
      // 调用服务端接口进行游客登录
      final response = await _dio.post(
        'http://localhost:3000/api/auth/guest', // 替换为你的服务端接口地址
        data: {'username': username},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final user = UserModel(
          id: data['id'],
          username: data['username'],
          createdAt: DateTime.parse(data['createdAt']),
        );

        // 登录成功后，设置 SocketService 的 userId
        _socketService.setUserId(user.id);

        // 重新连接 Socket
        _socketService.reconnect();

        return user;
      } else {
        throw Exception('游客登录失败: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('游客登录失败: ${e.toString()}');
    }
  }
}
