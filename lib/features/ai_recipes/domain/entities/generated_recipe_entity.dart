class GeneratedRecipeEntity {
  final String id;
  final String prompt;
  final String title;
  final List<String> ingredients;
  final List<String> instructions;
  final DateTime generatedAt;
  final int likes;
  final bool isCached;

  const GeneratedRecipeEntity({
    required this.id,
    required this.prompt,
    required this.title,
    required this.ingredients,
    required this.instructions,
    required this.generatedAt,
    required this.likes,
    required this.isCached,
  });
}