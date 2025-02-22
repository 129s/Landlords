import 'package:landlords_3/domain/entities/user_model.dart';

class UserDTO extends UserModel {
  UserDTO({
    required super.id,
    required super.username,
    required super.createdAt,
  });

  factory UserDTO.fromJson(Map<String, dynamic> json) {
    return UserDTO(
      id: json['id'] as String,
      username: json['username'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
