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
      if (prompt.trim().isEmpty) {
        return Left(ServerFailure('يرجى إدخال وصف للوصفة'));
      }

      final apiKey = await _localDataSource.getApiKey();
      if (apiKey == null) {
        return Left(ApiKeyNotFoundFailure('يرجى إضافة مفتاح API أولاً'));
      }

      final generationCount = await _localDataSource.getGenerationCount();
      if (generationCount >= maxDailyGenerations) {
        return Left(DailyLimitExceededFailure(
            'لقد وصلت إلى الحد الأقصى للوصفات اليومية ($maxDailyGenerations)\nيرجى المحاولة غداً'));
      }

      // Check cached recipes first
      try {
        final cachedRecipes = await _localDataSource.getCachedRecipes();
        final cachedRecipe = cachedRecipes.firstWhere(
          (recipe) => recipe.prompt.toLowerCase() == prompt.toLowerCase(),
        );
        return Right(cachedRecipe);
      } on CacheException {
        // Continue with generation if cache access fails
      } catch (_) {
        // No cached recipe found, continue with generation
      }

      // Generate new recipe
      final recipe = await _remoteDataSource.generateRecipe(prompt, apiKey);
      
      try {
        await _localDataSource.cacheRecipe(recipe);
        await _localDataSource.incrementGenerationCount();
      } on CacheException {
        // If caching fails, still return the generated recipe
        // but log the error or handle it appropriately
      }

      return Right(recipe);
    } on ServerException catch (e) {
      // تحسين رسائل الخطأ لتكون أكثر وضوحاً
      if (e.message.contains('مفتاح API')) {
        return Left(AuthFailure('مفتاح API غير صالح. يرجى التحقق من المفتاح في الإعدادات'));
      } else if (e.message.contains('تجاوز حد الاستخدام')) {
        return Left(DailyLimitExceededFailure('تم تجاوز حد الاستخدام اليومي. يرجى المحاولة غداً'));
      } else if (e.message.contains('اتصال')) {
        return Left(ServerFailure('يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى'));
      } else {
        return Left(ServerFailure(e.message));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure('حدث خطأ في التخزين المحلي: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ في النظام. يرجى إعادة تشغيل التطبيق والمحاولة مرة أخرى'));
    }
  }

  @override
  Future<Either<Failure, double>> getRemainingGenerations() async {
    try {
      final count = await _localDataSource.getGenerationCount();
      return Right((maxDailyGenerations - count).toDouble());
    } on CacheException {
      return Left(CacheFailure('لا يمكن الوصول إلى التخزين المحلي، يرجى المحاولة مرة أخرى'));
    }
  }

  @override
  Future<Either<Failure, bool>> isApiKeySet() async {
    try {
      final apiKey = await _localDataSource.getApiKey();
      return Right(apiKey != null);
    } on CacheException {
      return Left(CacheFailure('لا يمكن التحقق من مفتاح API، يرجى المحاولة مرة أخرى'));
    }
  }

  @override
  Future<Either<Failure, void>> setApiKey(String apiKey) async {
    try {
      await _localDataSource.setApiKey(apiKey);
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure('لا يمكن حفظ مفتاح API، يرجى المحاولة مرة أخرى'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteApiKey() async {
    try {
      await _localDataSource.deleteApiKey();
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure('لا يمكن حذف مفتاح API، يرجى المحاولة مرة أخرى'));
    }
  }
}