import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/i_ai_recipe_repository.dart';

class GetRemainingGenerations {
  final IAiRecipeRepository repository;

  GetRemainingGenerations(this.repository);

  Future<Either<Failure, double>> call() {
    return repository.getRemainingGenerations();
  }
}