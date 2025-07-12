import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/recipe_model.dart';

abstract class IRecipeLocalDataSource {
  Future<List<RecipeModel>> getCachedRecipes();
  Future<void> cacheRecipes(List<RecipeModel> recipes);
  Future<void> toggleFavorite(String id);
  Future<List<RecipeModel>> getFavoriteRecipes();
  Future<void> saveRecipe(RecipeModel recipe);
  Future<void> deleteRecipe(String id);
}

class RecipeLocalDataSource implements IRecipeLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String CACHED_RECIPES_KEY = 'CACHED_RECIPES';

  RecipeLocalDataSource({required this.sharedPreferences});

  @override
  Future<List<RecipeModel>> getCachedRecipes() async {
    final jsonString = sharedPreferences.getString(CACHED_RECIPES_KEY);
    if (jsonString != null) {
      try {
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList.map((json) => RecipeModel.fromJson(json)).toList();
      } catch (e) {
        // في حالة فشل تحليل JSON
        await sharedPreferences.remove(CACHED_RECIPES_KEY);
        return [];
      }
    }
    return [];
  }

  @override
  Future<void> cacheRecipes(List<RecipeModel> recipes) async {
    final List<Map<String, dynamic>> jsonList =
        recipes.map((recipe) => recipe.toJson()).toList();
    await sharedPreferences.setString(
      CACHED_RECIPES_KEY,
      json.encode(jsonList),
    );
  }

  @override
  Future<void> toggleFavorite(String id) async {
    final recipes = await getCachedRecipes();
    final index = recipes.indexWhere((recipe) => recipe.id == id);
    if (index != -1) {
      final recipe = recipes[index];
      recipes[index] = recipe.copyWith(isFavorite: !recipe.isFavorite);
      await cacheRecipes(recipes);
    }
  }

  @override
  Future<List<RecipeModel>> getFavoriteRecipes() async {
    final recipes = await getCachedRecipes();
    return recipes.where((recipe) => recipe.isFavorite).toList();
  }

  @override
  Future<void> saveRecipe(RecipeModel recipe) async {
    final recipes = await getCachedRecipes();
    final index = recipes.indexWhere((r) => r.id == recipe.id);
    if (index != -1) {
      recipes[index] = recipe;
    } else {
      recipes.add(recipe);
    }
    await cacheRecipes(recipes);
  }

  @override
  Future<void> deleteRecipe(String id) async {
    final recipes = await getCachedRecipes();
    recipes.removeWhere((recipe) => recipe.id == id);
    await cacheRecipes(recipes);
  }
}
