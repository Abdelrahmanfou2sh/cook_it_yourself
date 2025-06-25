import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/i_ai_recipe_repository.dart';
import '../../domain/entities/generated_recipe_entity.dart';
import '../datasources/local_data_source.dart';
import '../datasources/remote_data_source.dart';

class AiRecipeRepositoryImpl implements IAiRecipeRepository {
  final AiRecipeLocalDataSource _localDataSource;
  final AiRecipeRemoteDataSource _remoteDataSource;
  static const int maxDailyGenerations = 5;

  AiRecipeRepositoryImpl(
    this._localDataSource,
    this._remoteDataSource,
  );

  @override
  Future<Either<Failure, GeneratedRecipeEntity>> generateRecipe(String prompt) async {
    try {
      final apiKey = await _localDataSource.getApiKey();
      if (apiKey == null) {
        return Left(ApiKeyNotFoundFailure());
      }

      final generationCount = await _localDataSource.getGenerationCount();
      if (generationCount >= maxDailyGenerations) {
        return Left(DailyLimitExceededFailure());
      }

      // Check cached recipes first
      final cachedRecipes = await _localDataSource.getCachedRecipes();
      try {
        final cachedRecipe = cachedRecipes.firstWhere(
          (recipe) => recipe.prompt.toLowerCase() == prompt.toLowerCase(),
        );
        return Right(cachedRecipe);
      } catch (_) {
        // No cached recipe found, continue with generation
      }

      // Generate new recipe
      final recipe = await _remoteDataSource.generateRecipe(prompt, apiKey);
      await _localDataSource.cacheRecipe(recipe);
      await _localDataSource.incrementGenerationCount();

      return Right(recipe);
    } on ServerException {
      return Left(ServerFailure('فشل في الاتصال بالخادم'));
    } on CacheException {
      return Left(CacheFailure('فشل في الوصول إلى التخزين المحلي'));
    }
  }

  @override
  Future<Either<Failure, double>> getRemainingGenerations() async {
    try {
      final count = await _localDataSource.getGenerationCount();
      return Right((maxDailyGenerations - count).toDouble());
    } on CacheException {
      return Left(CacheFailure('فشل في الوصول إلى التخزين المحلي'));
    }
  }

  @override
  Future<Either<Failure, bool>> isApiKeySet() async {
    try {
      final apiKey = await _localDataSource.getApiKey();
      return Right(apiKey != null);
    } on CacheException {
      return Left(CacheFailure('فشل في الوصول إلى التخزين المحلي'));
    }
  }

  @override
  Future<Either<Failure, void>> setApiKey(String apiKey) async {
    try {
      await _localDataSource.setApiKey(apiKey);
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure('فشل في حفظ مفتاح API'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteApiKey() async {
    try {
      await _localDataSource.deleteApiKey();
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure('فشل في حذف مفتاح API'));
    }
  }
}