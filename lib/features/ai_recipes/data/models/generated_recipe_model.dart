import '../../domain/entities/generated_recipe_entity.dart';

class GeneratedRecipeModel extends GeneratedRecipeEntity {
  GeneratedRecipeModel({
    required String id,
    required String prompt,
    required String title,
    required List<String> ingredients,
    required List<String> instructions,
    required DateTime generatedAt,
    required int likes,
    required bool isCached,
  }) : super(
          id: id,
          prompt: prompt,
          title: title,
          ingredients: ingredients,
          instructions: instructions,
          generatedAt: generatedAt,
          likes: likes,
          isCached: isCached,
        );

  factory GeneratedRecipeModel.fromJson(Map<String, dynamic> json) {
    return GeneratedRecipeModel(
      id: json['id'] as String,
      prompt: json['prompt'] as String,
      title: json['title'] as String,
      ingredients: List<String>.from(json['ingredients'] as List),
      instructions: List<String>.from(json['instructions'] as List),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      likes: json['likes'] as int,
      isCached: json['isCached'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prompt': prompt,
      'title': title,
      'ingredients': ingredients,
      'instructions': instructions,
      'generatedAt': generatedAt.toIso8601String(),
      'likes': likes,
      'isCached': isCached,
    };
  }
}