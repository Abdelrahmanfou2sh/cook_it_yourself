import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required String id,
    required String email,
    required String username,
    String? photoUrl,
    required DateTime createdAt,
    List<String> favoriteRecipes = const [],
    List<String> createdRecipes = const [],
  }) : super(
          id: id,
          email: email,
          username: username,
          photoUrl: photoUrl,
          createdAt: createdAt,
          favoriteRecipes: favoriteRecipes,
          createdRecipes: createdRecipes,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      photoUrl: json['photoUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      favoriteRecipes: List<String>.from(json['favoriteRecipes'] as List<dynamic>),
      createdRecipes: List<String>.from(json['createdRecipes'] as List<dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'favoriteRecipes': favoriteRecipes,
      'createdRecipes': createdRecipes,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? photoUrl,
    DateTime? createdAt,
    List<String>? favoriteRecipes,
    List<String>? createdRecipes,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      favoriteRecipes: favoriteRecipes ?? this.favoriteRecipes,
      createdRecipes: createdRecipes ?? this.createdRecipes,
    );
  }
}