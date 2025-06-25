import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/recipe_entity.dart';
import '../repositories/i_recipe_repository.dart';

class ToggleLike {
  final IRecipeRepository repository;

  ToggleLike(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.toggleLike(id);
  }
}

class SaveRecipe {
  final IRecipeRepository repository;

  SaveRecipe(this.repository);

  Future<Either<Failure, void>> call(RecipeEntity recipe) async {
    return await repository.saveRecipe(recipe);
  }
}

class DeleteRecipe {
  final IRecipeRepository repository;

  DeleteRecipe(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteRecipe(id);
  }
}