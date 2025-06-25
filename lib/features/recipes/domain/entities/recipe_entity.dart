class RecipeEntity {
  final String id;
  final String title;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;
  final String imageUrl;
  final int preparationTime;
  final int cookingTime;
  final int servings;
  final String difficulty;
  final String category;
  final int likes;
  final bool isFavorite;
  final DateTime createdAt;

  const RecipeEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.imageUrl,
    required this.preparationTime,
    required this.cookingTime,
    required this.servings,
    required this.difficulty,
    required this.category,
    required this.likes,
    required this.isFavorite,
    required this.createdAt,
  });
}