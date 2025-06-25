import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/recipe_entity.dart';
import '../repositories/i_recipe_repository.dart';

class GetRecipes {
  final IRecipeRepository repository;

  GetRecipes(this.repository);

  Future<Either<Failure, List<RecipeEntity>>> call() async {
    return await repository.getRecipes();
  }
}