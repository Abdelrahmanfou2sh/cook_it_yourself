import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/recipe_entity.dart';
import '../../domain/repositories/i_recipe_repository.dart';
import '../datasources/local_data_source.dart';
import '../datasources/remote_data_source.dart';
import '../models/recipe_model.dart';

class RecipeRepositoryImpl implements IRecipeRepository {
  final IRecipeRemoteDataSource remoteDataSource;
  final IRecipeLocalDataSource localDataSource;

  RecipeRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<RecipeEntity>>> getRecipes() async {
    try {
      final remoteRecipes = await remoteDataSource.getRecipes();
      await localDataSource.cacheRecipes(remoteRecipes);
      return Right(remoteRecipes);
    } on ServerException {
      try {
        final localRecipes = await localDataSource.getCachedRecipes();
        return Right(localRecipes);
      } on CacheException {
        return Left(CacheFailure('فشل في الوصول إلى التخزين المحلي'));
      }
    }
  }

  @override
  Future<Either<Failure, RecipeEntity>> getRecipeById(String id) async {
    try {
      final recipe = await remoteDataSource.getRecipeById(id);
      return Right(recipe);
    } on ServerException {
      return Left(ServerFailure('فشل في الوصول إلى السيرفر'));
    }
  }

  @override
  Future<Either<Failure, List<RecipeEntity>>> getRecipesByCategory(
    String category,
  ) async {
    try {
      final recipes = await remoteDataSource.getRecipesByCategory(category);
      return Right(recipes);
    } on ServerException {
      return Left(ServerFailure('فشل في الوصول إلى السيرفر'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleFavorite(String id) async {
    try {
      await localDataSource.toggleFavorite(id);
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure('فشل في الوصول إلى التخزين المحلي'));
    }
  }

  @override
  Future<Either<Failure, List<RecipeEntity>>> getFavoriteRecipes() async {
    try {
      final recipes = await localDataSource.getFavoriteRecipes();
      return Right(recipes);
    } on CacheException {
      return Left(CacheFailure('فشل في الوصول إلى التخزين المحلي'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleLike(String id) async {
    try {
      await remoteDataSource.toggleLike(id);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure('فشل في الوصول إلى السيرفر'));
    }
  }

  @override
  Future<Either<Failure, void>> saveRecipe(RecipeEntity recipe) async {
    try {
      await localDataSource.saveRecipe(recipe as RecipeModel);
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure('فشل في الوصول إلى التخزين المحلي'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRecipe(String id) async {
    try {
      await localDataSource.deleteRecipe(id);
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure('فشل في الوصول إلى التخزين المحلي'));
    }
  }
}
