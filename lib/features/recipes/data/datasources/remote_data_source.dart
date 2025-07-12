import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../core/error/exceptions.dart';
import '../models/recipe_model.dart';

abstract class IRecipeRemoteDataSource {
  Future<List<RecipeModel>> getRecipes();
  Future<RecipeModel> getRecipeById(String id);
  Future<List<RecipeModel>> getRecipesByCategory(String category);
  Future<void> toggleLike(String id);
}

class RecipeRemoteDataSource implements IRecipeRemoteDataSource {
  final Dio dio;
  final String baseUrl;

  RecipeRemoteDataSource({
    required this.dio,
    this.baseUrl = 'https://api.spoonacular.com/recipes',
  });

  String get _apiKey => dotenv.env['SPOONACULAR_API_KEY'] ?? '';

  @override
  Future<List<RecipeModel>> getRecipes() async {
    try {
      final response = await dio.get(
        '$baseUrl/complexSearch',
        queryParameters: {
          'apiKey': _apiKey,
          'addRecipeInformation': 'true',
          'number': '20',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonList =
            response.data['results'] as List<dynamic>;
        return jsonList
            .map((json) => _convertSpoonacularToRecipeModel(json))
            .toList();
      } else {
        throw ServerException();
      }
    } on DioException {
      throw ServerException();
    }
  }

  @override
  Future<RecipeModel> getRecipeById(String id) async {
    try {
      final response = await dio.get(
        '$baseUrl/$id/information',
        queryParameters: {'apiKey': _apiKey},
      );
      if (response.statusCode == 200) {
        return _convertSpoonacularToRecipeModel(response.data);
      } else {
        throw ServerException();
      }
    } on DioException {
      throw ServerException();
    }
  }

  @override
  Future<List<RecipeModel>> getRecipesByCategory(String category) async {
    try {
      final response = await dio.get(
        '$baseUrl/complexSearch',
        queryParameters: {
          'apiKey': _apiKey,
          'addRecipeInformation': 'true',
          'type': category,
          'number': '20',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonList =
            response.data['results'] as List<dynamic>;
        return jsonList
            .map((json) => _convertSpoonacularToRecipeModel(json))
            .toList();
      } else {
        throw ServerException();
      }
    } on DioException {
      throw ServerException();
    }
  }

  @override
  Future<void> toggleLike(String id) async {
    // يتم التعامل مع المفضلة محلياً فقط لأن Spoonacular لا يدعم هذه الخاصية
    return;
  }

  String _cleanHtmlTags(String text) {
    return text
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'");
  }

  RecipeModel _convertSpoonacularToRecipeModel(Map<String, dynamic> json) {
    // تنظيف وصف الوصفة من HTML tags
    final description = json['summary'] ?? '';
    final cleanDescription = _cleanHtmlTags(description);

    // استخراج المكونات
    final List<String> ingredients = json['extendedIngredients'] != null
        ? (json['extendedIngredients'] as List<dynamic>)
            .map((ing) => _cleanHtmlTags(ing['original'].toString()))
            .toList()
        : <String>[];

    // استخراج خطوات التحضير
    final List<String> instructions = json['analyzedInstructions']?.isNotEmpty == true
        ? (json['analyzedInstructions'][0]['steps'] as List<dynamic>)
            .map((step) => _cleanHtmlTags(step['step'].toString()))
            .toList()
        : <String>[];

    // تحويل وقت التحضير والطهي
    final prepTime = json['preparationMinutes'] ?? 10;
    final cookTime = json['cookingMinutes'] ?? 45;

    return RecipeModel(
      id: json['id'].toString(),
      title: _cleanHtmlTags(json['title'] ?? ''),
      description: cleanDescription,
      ingredients: ingredients,
      instructions: instructions,
      imageUrl: json['image'] ?? '',
      preparationTime: prepTime,
      cookingTime: cookTime,
      servings: json['servings'] ?? 8,
      difficulty: _getDifficultyFromTime(json['readyInMinutes'] ?? (prepTime + cookTime)),
      category: json['dishTypes']?.isNotEmpty == true ? json['dishTypes'][0] : 'Other',
      likes: json['aggregateLikes'] ?? 0,
      isFavorite: false,
      createdAt: DateTime.now(),
    );
  }

  String _getDifficultyFromTime(int totalMinutes) {
    if (totalMinutes <= 30) return 'Easy';
    if (totalMinutes <= 60) return 'Medium';
    return 'Hard';
  }
}
