import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/api_service.dart';
import '../data/reciepe_model.dart';
import 'recipes_state.dart';

class RecipesCubit extends Cubit<RecipesState> {
  final ApiService _apiService;

  RecipesCubit(this._apiService) : super(RecipesInitial());

  Future<void> loadRecipes() async {
    try {
      emit(RecipesLoading());

      final recipesData = await _apiService.searchRecipes();
      final recipes = recipesData.map((json) => Recipe.fromJson(json)).toList();

      emit(
        RecipesLoaded(
          recipes: recipes,
          cuisineTypes:
              _apiService.getArabicCuisines(), // تحديث لاستخدام المطابخ العربية
          dietTypes: _apiService.getDietTypes(),
        ),
      );
    } catch (e) {
      emit(RecipesError(e.toString()));
    }
  }

  Future<void> searchRecipes(String query) async {
    try {
      if (state is RecipesLoaded) {
        final currentState = state as RecipesLoaded;

        final searchData = await _apiService.searchRecipes(query: query);
        final searchResults =
            searchData.map((json) => Recipe.fromJson(json)).toList();

        emit(
          RecipesLoaded(
            recipes: searchResults,
            cuisineTypes: currentState.cuisineTypes,
            dietTypes: currentState.dietTypes, // Add dietTypes
            searchQuery: query,
            selectedCuisine: currentState.selectedCuisine,
            selectedDiet: currentState.selectedDiet,
          ),
        );
      }
    } catch (e) {
      emit(RecipesError(e.toString()));
    }
  }

  Future<void> filterByCuisine(String cuisine) async {
    try {
      // احتفظ بالحالة الحالية
      if (state is RecipesLoaded) {
        final currentState = state as RecipesLoaded;
        
        // أصدر حالة تحميل مع الاحتفاظ بالبيانات الحالية
        emit(RecipesLoading.fromLoaded(currentState));
        
        // قم بتحميل البيانات الجديدة
        final data = await _apiService.searchRecipes(cuisine: cuisine);
        final recipes = data.map((json) => Recipe.fromJson(json)).toList();
        
        emit(
          RecipesLoaded(
            recipes: recipes,
            cuisineTypes: currentState.cuisineTypes,
            dietTypes: currentState.dietTypes,
            selectedCuisine: cuisine,
            selectedDiet: currentState.selectedDiet,
            searchQuery: currentState.searchQuery,
          ),
        );
      }
    } catch (e) {
      emit(RecipesError(e.toString()));
    }
  }

  Future<void> filterByDiet(String diet) async {
    try {
      // احتفظ بالحالة الحالية
      if (state is RecipesLoaded) {
        final currentState = state as RecipesLoaded;
        
        // أصدر حالة تحميل مع الاحتفاظ بالبيانات الحالية
        emit(RecipesLoading.fromLoaded(currentState));
        
        // قم بتحميل البيانات الجديدة
        final data = await _apiService.searchRecipes(diet: diet);
        final recipes = data.map((json) => Recipe.fromJson(json)).toList();
        
        emit(
          RecipesLoaded(
            recipes: recipes,
            cuisineTypes: currentState.cuisineTypes,
            dietTypes: currentState.dietTypes,
            selectedCuisine: currentState.selectedCuisine,
            selectedDiet: diet,
            searchQuery: currentState.searchQuery,
          ),
        );
      }
    } catch (e) {
      emit(RecipesError(e.toString()));
    }
  }

  void clearFilters() async {
    try {
      if (state is RecipesLoaded) {
        final currentState = state as RecipesLoaded;
        final recipesData = await _apiService.searchRecipes();
        final recipes =
            recipesData.map((json) => Recipe.fromJson(json)).toList();

        emit(
          RecipesLoaded(
            recipes: recipes,
            cuisineTypes: currentState.cuisineTypes,
            dietTypes: currentState.dietTypes,
            selectedCuisine: null, // إعادة تعيين إلى null
            selectedDiet: null, // إعادة تعيين إلى null
          ),
        );
      }
    } catch (e) {
      emit(RecipesError(e.toString()));
    }
  }

  Future<List<Recipe>> fetchRecipesPage(int pageKey, int pageSize) async {
    try {
      // Get current filters if any
      String query = '';
      String cuisine = '';
      String diet = '';
      
      if (state is RecipesLoaded) {
        final currentState = state as RecipesLoaded;
        query = currentState.searchQuery ?? '';
        cuisine = currentState.selectedCuisine ?? '';
        diet = currentState.selectedDiet ?? '';
      }
      
      // Calculate offset based on pageKey
      final offset = pageKey * pageSize;
      
      // Fetch data from API
      final data = await _apiService.searchRecipes(
        query: query,
        cuisine: cuisine,
        diet: diet,
        number: pageSize,
        offset: offset,
      );
      
      // Convert to Recipe objects
      final recipes = data.map((json) => Recipe.fromJson(json)).toList();
      
      return recipes;
    } catch (e) {
      print('Error fetching page: $e');
      throw e;
    }
  }
}
