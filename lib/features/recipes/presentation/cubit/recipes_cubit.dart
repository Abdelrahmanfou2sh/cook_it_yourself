import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/recipe_entity.dart';
import '../../domain/usecases/get_recipes.dart';
import '../../domain/usecases/get_recipe_by_id.dart';
import '../../domain/usecases/get_recipes_by_category.dart';
import '../../domain/usecases/manage_favorites.dart';
import '../../domain/usecases/manage_recipes.dart';
import 'recipes_state.dart';

class RecipesCubit extends Cubit<RecipesState> {
  final GetRecipes getRecipes;
  final GetRecipeById getRecipeById;
  final GetRecipesByCategory getRecipesByCategory;
  final ToggleFavorite toggleFavorite;
  final GetFavoriteRecipes getFavoriteRecipes;
  final ToggleLike toggleLike;
  final SaveRecipe saveRecipe;
  final DeleteRecipe deleteRecipe;

  RecipesCubit({
    required this.getRecipes,
    required this.getRecipeById,
    required this.getRecipesByCategory,
    required this.toggleFavorite,
    required this.getFavoriteRecipes,
    required this.toggleLike,
    required this.saveRecipe,
    required this.deleteRecipe,
  }) : super(const RecipesInitial());

  Future<void> loadRecipes() async {
    emit(const RecipesLoading());
    final result = await getRecipes();
    result.fold(
      (failure) => emit(RecipesError(failure.toString())),
      (recipes) => emit(RecipesLoaded(recipes)),
    );
  }

  Future<void> loadRecipeById(String id) async {
    emit(const RecipesLoading());
    final result = await getRecipeById(id);
    result.fold(
      (failure) => emit(RecipesError(failure.toString())),
      (recipe) => emit(RecipeLoaded(recipe)),
    );
  }

  Future<void> loadRecipesByCategory(String category) async {
    emit(const RecipesLoading());
    final result = await getRecipesByCategory(category);
    result.fold(
      (failure) => emit(RecipesError(failure.toString())),
      (recipes) => emit(RecipesByCategory(recipes, category)),
    );
  }

  Future<void> handleToggleFavorite(String id) async {
    final result = await toggleFavorite(id);
    result.fold(
      (failure) => emit(RecipesError(failure.toString())),
      (_) => emit(const RecipeActionSuccess('Recipe favorite status updated')),
    );
  }

  Future<void> loadFavoriteRecipes() async {
    emit(const RecipesLoading());
    final result = await getFavoriteRecipes();
    result.fold(
      (failure) => emit(RecipesError(failure.toString())),
      (recipes) => emit(FavoriteRecipes(recipes)),
    );
  }

  Future<void> handleToggleLike(String id) async {
    final result = await toggleLike(id);
    result.fold(
      (failure) => emit(RecipesError(failure.toString())),
      (_) => emit(const RecipeActionSuccess('Recipe like status updated')),
    );
  }

  Future<void> handleSaveRecipe(RecipeEntity recipe) async {
    final result = await saveRecipe(recipe);
    result.fold(
      (failure) => emit(RecipesError(failure.toString())),
      (_) => emit(const RecipeActionSuccess('Recipe saved successfully')),
    );
  }

  Future<void> handleDeleteRecipe(String id) async {
    final result = await deleteRecipe(id);
    result.fold(
      (failure) => emit(RecipesError(failure.toString())),
      (_) => emit(const RecipeActionSuccess('Recipe deleted successfully')),
    );
  }
}