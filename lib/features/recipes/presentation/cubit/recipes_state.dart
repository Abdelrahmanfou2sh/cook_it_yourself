import 'package:equatable/equatable.dart';
import '../../domain/entities/recipe_entity.dart';

sealed class RecipesState extends Equatable {
  const RecipesState();

  @override
  List<Object?> get props => [];
}

class RecipesInitial extends RecipesState {
  const RecipesInitial();
}

class RecipesLoading extends RecipesState {
  const RecipesLoading();
}

class RecipesLoaded extends RecipesState {
  final List<RecipeEntity> recipes;

  const RecipesLoaded(this.recipes);

  @override
  List<Object?> get props => [recipes];
}

class RecipeLoaded extends RecipesState {
  final RecipeEntity recipe;

  const RecipeLoaded(this.recipe);

  @override
  List<Object?> get props => [recipe];
}

class RecipesByCategory extends RecipesState {
  final List<RecipeEntity> recipes;
  final String category;

  const RecipesByCategory(this.recipes, this.category);

  @override
  List<Object?> get props => [recipes, category];
}

class FavoriteRecipes extends RecipesState {
  final List<RecipeEntity> recipes;

  const FavoriteRecipes(this.recipes);

  @override
  List<Object?> get props => [recipes];
}

class RecipesError extends RecipesState {
  final String message;

  const RecipesError(this.message);

  @override
  List<Object?> get props => [message];
}

class RecipeActionSuccess extends RecipesState {
  final String message;

  const RecipeActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}