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

  // Replace print with logger or remove
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
      // Use rethrow instead of throw e
      rethrow;
    }
  }

  // In loadSuggestedRecipes method, replace print with logger or remove
  // logger.log('Error loading suggested recipes: $e');
  Future<void> searchByIngredients(List<String> ingredients) async {
    emit(RecipesLoading());
    try {
      final recipes = await _apiService.searchRecipesByIngredients(ingredients);

      // Get current cuisineTypes and dietTypes if available
      List<String> cuisineTypes = [];
      List<String> dietTypes = [];

      if (state is RecipesLoaded) {
        final currentState = state as RecipesLoaded;
        cuisineTypes = currentState.cuisineTypes;
        dietTypes = currentState.dietTypes;
      } else {
        // Fallback to default values if not available
        cuisineTypes = _apiService.getArabicCuisines();
        dietTypes = _apiService.getDietTypes();
      }

      emit(
        RecipesLoaded(
          recipes: recipes,
          cuisineTypes: cuisineTypes,
          dietTypes: dietTypes,
        ),
      );
    } catch (e) {
      emit(RecipesError(e.toString()));
    }
  }

  Future<void> loadSuggestedRecipes() async {
      try {
        if (state is RecipesLoaded) {
          final currentState = state as RecipesLoaded;
          
          // الحصول على الوقت الحالي
          final now = DateTime.now();
          String mealType;
          
          // تحديد نوع الوجبة بناءً على الوقت
          if (now.hour >= 6 && now.hour < 11) {
            mealType = 'breakfast';
          } else if (now.hour >= 11 && now.hour < 15) {
            mealType = 'lunch';
          } else if (now.hour >= 15 && now.hour < 18) {
            mealType = 'snack';
          } else {
            mealType = 'dinner';
          }
          
          // البحث عن وصفات مناسبة للوقت الحالي
          final data = await _apiService.searchRecipes(query: mealType);
          final recipes = data.map((json) => Recipe.fromJson(json)).toList();
          
          emit(
            RecipesLoaded(
              recipes: recipes,
              cuisineTypes: currentState.cuisineTypes,
              dietTypes: currentState.dietTypes,
              selectedCuisine: currentState.selectedCuisine,
              selectedDiet: currentState.selectedDiet,
              searchQuery: currentState.searchQuery,
              suggestedRecipes: recipes,
            ),
          );
        }
      } catch (e) {
        print('Error loading suggested recipes: $e');
        // لا نصدر حالة خطأ هنا لتجنب تعطيل الواجهة
      }
    }
}
