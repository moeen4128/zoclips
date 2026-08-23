import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.isVerified,
    super.name,
    super.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] as String? ?? '',
      isVerified: json['is_verified'] as bool? ?? false,
      name: json['name'] as String? ?? json['full_name'] as String?,
      avatarUrl:
          json['avatar_url'] as String? ?? json['profile_picture'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'is_verified': isVerified,
    if (name != null) 'name': name,
    if (avatarUrl != null) 'avatar_url': avatarUrl,
  };
}
