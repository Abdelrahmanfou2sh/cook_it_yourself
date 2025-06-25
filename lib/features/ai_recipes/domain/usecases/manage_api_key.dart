import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/i_ai_recipe_repository.dart';

class ManageApiKey {
  final IAiRecipeRepository repository;

  ManageApiKey(this.repository);

  Future<Either<Failure, bool>> checkApiKey() {
    return repository.isApiKeySet();
  }

  Future<Either<Failure, void>> setApiKey(String apiKey) {
    return repository.setApiKey(apiKey);
  }

  Future<Either<Failure, void>> deleteApiKey() {
    return repository.deleteApiKey();
  }
}