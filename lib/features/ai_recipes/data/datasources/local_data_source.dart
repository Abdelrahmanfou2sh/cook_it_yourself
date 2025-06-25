import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/generated_recipe_model.dart';

class AiRecipeLocalDataSource {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;
  static const String _apiKeyKey = 'openai_api_key';
  static const String _cachedRecipesKey = 'cached_recipes';
  static const String _generationsCountKey = 'generations_count';
  static const String _lastGenerationDateKey = 'last_generation_date';

  AiRecipeLocalDataSource(this._prefs, this._secureStorage);

  Future<void> cacheRecipe(GeneratedRecipeModel recipe) async {
    final recipes = await getCachedRecipes();
    recipes.add(recipe);
    final recipesJson = recipes.map((r) => r.toJson()).toList();
    await _prefs.setString(_cachedRecipesKey, jsonEncode(recipesJson));
  }

  Future<List<GeneratedRecipeModel>> getCachedRecipes() async {
    final recipesString = _prefs.getString(_cachedRecipesKey);
    if (recipesString == null) return [];

    final recipesJson = jsonDecode(recipesString) as List;
    return recipesJson
        .map(
          (json) => GeneratedRecipeModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> setApiKey(String apiKey) async {
    await _secureStorage.write(key: _apiKeyKey, value: apiKey);
  }

  Future<String?> getApiKey() async {
    return await _secureStorage.read(key: _apiKeyKey);
  }

  Future<void> deleteApiKey() async {
    await _secureStorage.delete(key: _apiKeyKey);
  }

  Future<void> incrementGenerationCount() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastDate = _prefs.getString(_lastGenerationDateKey);

    if (lastDate != today) {
      await _prefs.setInt(_generationsCountKey, 1);
      await _prefs.setString(_lastGenerationDateKey, today);
    } else {
      final count = _prefs.getInt(_generationsCountKey) ?? 0;
      await _prefs.setInt(_generationsCountKey, count + 1);
    }
  }

  Future<int> getGenerationCount() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastDate = _prefs.getString(_lastGenerationDateKey);

    if (lastDate != today) {
      await _prefs.setInt(_generationsCountKey, 0);
      await _prefs.setString(_lastGenerationDateKey, today);
      return 0;
    }

    return _prefs.getInt(_generationsCountKey) ?? 0;
  }
}
