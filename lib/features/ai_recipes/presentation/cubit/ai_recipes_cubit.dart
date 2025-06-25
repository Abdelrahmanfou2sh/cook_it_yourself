import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/generate_recipe.dart';
import '../../domain/usecases/get_remaining_generations.dart';
import '../../domain/usecases/manage_api_key.dart';
import 'ai_recipes_state.dart';

class AiRecipesCubit extends Cubit<AiRecipesState> {
  final GenerateRecipe _generateRecipe;
  final GetRemainingGenerations _getRemainingGenerations;
  final ManageApiKey _manageApiKey;

  AiRecipesCubit({
    required GenerateRecipe generateRecipe,
    required GetRemainingGenerations getRemainingGenerations,
    required ManageApiKey manageApiKey,
  }) : _generateRecipe = generateRecipe,
       _getRemainingGenerations = getRemainingGenerations,
       _manageApiKey = manageApiKey,
       super(AiRecipesInitial());

  Future<void> generateRecipe(String prompt) async {
    emit(AiRecipesLoading());

    final recipeResult = await _generateRecipe(prompt);
    final remainingResult = await _getRemainingGenerations();

    recipeResult.fold(
      (failure) => emit(AiRecipesError(failure)),
      (recipe) => remainingResult.fold(
        (failure) => emit(AiRecipesError(failure)),
        (remaining) => emit(AiRecipesLoaded(
          recipe: recipe,
          remainingGenerations: remaining,
        )),
      ),
    );
  }

  Future<void> checkApiKey() async {
    final result = await _manageApiKey.checkApiKey();
    result.fold(
      (failure) => emit(AiRecipesError(failure)),
      (isSet) => emit(ApiKeyStatus(isSet)),
    );
  }

  Future<void> setApiKey(String apiKey) async {
    emit(AiRecipesLoading());
    final result = await _manageApiKey.setApiKey(apiKey);
    result.fold(
      (failure) => emit(AiRecipesError(failure)),
      (_) => emit(const ApiKeyStatus(true)),
    );
  }

  Future<void> deleteApiKey() async {
    emit(AiRecipesLoading());
    final result = await _manageApiKey.deleteApiKey();
    result.fold(
      (failure) => emit(AiRecipesError(failure)),
      (_) => emit(const ApiKeyStatus(false)),
    );
  }

  Future<void> getRemainingGenerations() async {
    final result = await _getRemainingGenerations();
    result.fold(
      (failure) => emit(AiRecipesError(failure)),
      (remaining) {
        if (state is AiRecipesLoaded) {
          final currentState = state as AiRecipesLoaded;
          emit(AiRecipesLoaded(
            recipe: currentState.recipe,
            remainingGenerations: remaining,
          ));
        }
      },
    );
  }
}