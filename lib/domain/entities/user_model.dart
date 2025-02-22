class UserModel {
  final String id;
  final String username;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.username,
    required this.createdAt,
  });

  UserModel copyWith({String? id, String? username, DateTime? createdAt}) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'UserModel{id: $id, username: $username, createdAt: $createdAt}';
  }
}
