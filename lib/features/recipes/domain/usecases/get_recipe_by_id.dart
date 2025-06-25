import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/recipe_entity.dart';
import '../repositories/i_recipe_repository.dart';

class GetRecipeById {
  final IRecipeRepository repository;

  GetRecipeById(this.repository);

  Future<Either<Failure, RecipeEntity>> call(String id) async {
    return await repository.getRecipeById(id);
  }
}