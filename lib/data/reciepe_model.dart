class Recipe {
  final int id;
  final String title;
  final String image;
  final String sourceName;
  final int readyInMinutes;
  final int servings;
  final List<String> cuisines;
  final List<String> dishTypes;
  final List<String> diets;
  final List<String> extendedIngredients;
  final String instructions;
  final double spoonacularScore;

  Recipe({
    required this.id,
    required this.title,
    required this.image,
    required this.sourceName,
    required this.readyInMinutes,
    required this.servings,
    this.cuisines = const [],
    this.dishTypes = const [],
    this.diets = const [],
    this.extendedIngredients = const [],
    required this.instructions,
    required this.spoonacularScore,
  });

  // في طريقة fromJson
  factory Recipe.fromJson(Map<String, dynamic> json) {
    // استخراج خطوات التحضير
    List<String> steps = [];
    if (json['analyzedInstructions'] != null && json['analyzedInstructions'].isNotEmpty) {
      final instructions = json['analyzedInstructions'][0];
      if (instructions != null && instructions['steps'] != null) {
        steps = (instructions['steps'] as List)
            .map((step) => step['step'].toString())
            .toList();
      }
    }
    
    return Recipe(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      sourceName: json['sourceName'] ?? 'Unknown',
      readyInMinutes: json['readyInMinutes'] ?? 0,
      servings: json['servings'] ?? 0,
      cuisines: List<String>.from(json['cuisines'] ?? []),
      dishTypes: List<String>.from(json['dishTypes'] ?? []),
      diets: List<String>.from(json['diets'] ?? []),
      extendedIngredients: (json['extendedIngredients'] as List<dynamic>?)
          ?.map((ingredient) => ingredient['original'].toString())
          .toList() ?? [],
      instructions: json['instructions'] ?? '',
      spoonacularScore: (json['spoonacularScore'] ?? 0.0).toDouble(),
    );
  }

  // للتسهيل في الواجهة
  String get name => title;
  String get cuisine => cuisines.isNotEmpty ? cuisines.first : 'عام';
  String get time => '$readyInMinutes دقيقة';
  List<String> get ingredients => extendedIngredients;
  List<String> get steps => instructions
      .split('.')
      .where((step) => step.trim().isNotEmpty)
      .toList();
}
