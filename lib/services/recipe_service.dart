import 'dart:convert';
import 'package:flutter/services.dart';
import '../data/reciepe_model.dart';

class RecipeService {
  Future<List<Recipe>> getRecipes() async {
    final String jsonString = await rootBundle.loadString('lib/data/recipes.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Recipe.fromJson(json)).toList();
  }

  Future<List<Recipe>> searchRecipes(String query) async {
    final recipes = await getRecipes();
    return recipes.where(
      (recipe) => recipe.name.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  Future<List<Recipe>> filterByType(String cuisine) async {
    final recipes = await getRecipes();
    return recipes.where(
      (recipe) => recipe.cuisine.toLowerCase() == cuisine.toLowerCase()
    ).toList();
  }

  Future<List<String>> getCuisineTypes() async {
    final recipes = await getRecipes();
    return recipes.map((recipe) => recipe.cuisine).toSet().toList();
  }
}
