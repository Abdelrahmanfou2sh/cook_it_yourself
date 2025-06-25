import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/generated_recipe_entity.dart';

abstract class IAiRecipeRepository {
  Future<Either<Failure, GeneratedRecipeEntity>> generateRecipe(String prompt);
  Future<Either<Failure, double>> getRemainingGenerations();
  Future<Either<Failure, bool>> isApiKeySet();
  Future<Either<Failure, void>> setApiKey(String apiKey);
  Future<Either<Failure, void>> deleteApiKey();
}