import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String username;
  final String? photoUrl;
  final DateTime createdAt;
  final List<String> favoriteRecipes;
  final List<String> createdRecipes;

  const UserEntity({
    required this.id,
    required this.email,
    required this.username,
    this.photoUrl,
    required this.createdAt,
    this.favoriteRecipes = const [],
    this.createdRecipes = const [],
  });

  @override
  List<Object?> get props => [
        id,
        email,
        username,
        photoUrl,
        createdAt,
        favoriteRecipes,
        createdRecipes,
      ];
}