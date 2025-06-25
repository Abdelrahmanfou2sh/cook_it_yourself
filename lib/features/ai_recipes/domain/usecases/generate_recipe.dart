import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/generated_recipe_entity.dart';
import '../repositories/i_ai_recipe_repository.dart';

class GenerateRecipe {
  final IAiRecipeRepository repository;

  GenerateRecipe(this.repository);

  Future<Either<Failure, GeneratedRecipeEntity>> call(String prompt) {
    return repository.generateRecipe(prompt);
  }
}