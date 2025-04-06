import 'package:equatable/equatable.dart';
import '../data/reciepe_model.dart';

abstract class RecipesState extends Equatable {
  const RecipesState();

  @override
  List<Object?> get props => [];
}

class RecipesInitial extends RecipesState {}

class RecipesLoading extends RecipesState {
  final List<Recipe>? recipes;
  final List<String>? cuisineTypes;
  final List<String>? dietTypes;
  final String? selectedCuisine;
  final String? selectedDiet;
  final String? searchQuery;

  RecipesLoading({
    this.recipes,
    this.cuisineTypes,
    this.dietTypes,
    this.selectedCuisine,
    this.selectedDiet,
    this.searchQuery,
  });

  // إنشاء حالة تحميل من حالة محملة
  factory RecipesLoading.fromLoaded(RecipesLoaded loaded) {
    return RecipesLoading(
      recipes: loaded.recipes,
      cuisineTypes: loaded.cuisineTypes,
      dietTypes: loaded.dietTypes,
      selectedCuisine: loaded.selectedCuisine,
      selectedDiet: loaded.selectedDiet,
      searchQuery: loaded.searchQuery,
    );
  }
}

// Add suggestedRecipes to RecipesLoaded class
// Add const to constructors
class RecipesLoaded extends RecipesState {
  final List<Recipe> recipes;
  final List<String> cuisineTypes;
  final List<String> dietTypes;
  final String? selectedCuisine;
  final String? selectedDiet;
  final String? searchQuery;
  final List<Recipe>? suggestedRecipes; // Add this parameter

  const RecipesLoaded({
    required this.recipes,
    required this.cuisineTypes,
    required this.dietTypes,
    this.selectedCuisine,
    this.selectedDiet,
    this.searchQuery,
    this.suggestedRecipes, // Add this parameter
  });
}

class RecipesError extends RecipesState {
  final String message;

  const RecipesError(this.message);

  @override
  List<Object?> get props => [message];
}