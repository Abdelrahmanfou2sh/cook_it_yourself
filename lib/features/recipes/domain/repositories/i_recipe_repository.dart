import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/recipe_entity.dart';

abstract class IRecipeRepository {
  Future<Either<Failure, List<RecipeEntity>>> getRecipes();
  Future<Either<Failure, RecipeEntity>> getRecipeById(String id);
  Future<Either<Failure, List<RecipeEntity>>> getRecipesByCategory(String category);
  Future<Either<Failure, void>> toggleFavorite(String id);
  Future<Either<Failure, List<RecipeEntity>>> getFavoriteRecipes();
  Future<Either<Failure, void>> toggleLike(String id);
  Future<Either<Failure, void>> saveRecipe(RecipeEntity recipe);
  Future<Either<Failure, void>> deleteRecipe(String id);
}