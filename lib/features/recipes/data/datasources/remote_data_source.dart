import 'package:dio/dio.dart';
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

  RecipeRemoteDataSource({required this.dio, this.baseUrl = 'https://api.example.com/recipes'});

  @override
  Future<List<RecipeModel>> getRecipes() async {
    try {
      final response = await dio.get(baseUrl);
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data as List<dynamic>;
        return jsonList.map((json) => RecipeModel.fromJson(json)).toList();
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
      final response = await dio.get('$baseUrl/$id');
      if (response.statusCode == 200) {
        return RecipeModel.fromJson(response.data);
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
      final response = await dio.get('$baseUrl/category/$category');
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data as List<dynamic>;
        return jsonList.map((json) => RecipeModel.fromJson(json)).toList();
      } else {
        throw ServerException();
      }
    } on DioException {
      throw ServerException();
    }
  }

  @override
  Future<void> toggleLike(String id) async {
    try {
      final response = await dio.post('$baseUrl/$id/like');
      if (response.statusCode != 200) {
        throw ServerException();
      }
    } on DioException {
      throw ServerException();
    }
  }
}