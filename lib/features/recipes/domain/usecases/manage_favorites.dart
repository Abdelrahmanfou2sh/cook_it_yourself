import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/recipe_entity.dart';
import '../repositories/i_recipe_repository.dart';

class ToggleFavorite {
  final IRecipeRepository repository;

  ToggleFavorite(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.toggleFavorite(id);
  }
}

class GetFavoriteRecipes {
  final IRecipeRepository repository;

  GetFavoriteRecipes(this.repository);

  Future<Either<Failure, List<RecipeEntity>>> call() async {
    return await repository.getFavoriteRecipes();
  }
}