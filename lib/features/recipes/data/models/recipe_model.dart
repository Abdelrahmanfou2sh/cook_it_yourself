import '../../domain/entities/recipe_entity.dart';

class RecipeModel extends RecipeEntity {
  RecipeModel({
    required String id,
    required String title,
    required String description,
    required List<String> ingredients,
    required List<String> instructions,
    required String imageUrl,
    required int preparationTime,
    required int cookingTime,
    required int servings,
    required String difficulty,
    required String category,
    required int likes,
    required bool isFavorite,
    required DateTime createdAt,
  }) : super(
          id: id,
          title: title,
          description: description,
          ingredients: ingredients,
          instructions: instructions,
          imageUrl: imageUrl,
          preparationTime: preparationTime,
          cookingTime: cookingTime,
          servings: servings,
          difficulty: difficulty,
          category: category,
          likes: likes,
          isFavorite: isFavorite,
          createdAt: createdAt,
        );

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      ingredients: List<String>.from(json['ingredients'] as List),
      instructions: List<String>.from(json['instructions'] as List),
      imageUrl: json['imageUrl'] as String,
      preparationTime: json['preparationTime'] as int,
      cookingTime: json['cookingTime'] as int,
      servings: json['servings'] as int,
      difficulty: json['difficulty'] as String,
      category: json['category'] as String,
      likes: json['likes'] as int,
      isFavorite: json['isFavorite'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'ingredients': ingredients,
      'instructions': instructions,
      'imageUrl': imageUrl,
      'preparationTime': preparationTime,
      'cookingTime': cookingTime,
      'servings': servings,
      'difficulty': difficulty,
      'category': category,
      'likes': likes,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  RecipeModel copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? ingredients,
    List<String>? instructions,
    String? imageUrl,
    int? preparationTime,
    int? cookingTime,
    int? servings,
    String? difficulty,
    String? category,
    int? likes,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return RecipeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      imageUrl: imageUrl ?? this.imageUrl,
      preparationTime: preparationTime ?? this.preparationTime,
      cookingTime: cookingTime ?? this.cookingTime,
      servings: servings ?? this.servings,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      likes: likes ?? this.likes,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}