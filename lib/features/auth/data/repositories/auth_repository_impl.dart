import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/local_data_source.dart';
import '../datasources/remote_data_source.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthRemoteDataSource remoteDataSource;
  final IAuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final user = await remoteDataSource.signUp(
        email: email,
        password: password,
        username: username,
      );
      await localDataSource.cacheUser(user);
      return Right(user);
    } on ServerException {
      return Left(ServerFailure('Failed to sign up'));
    } on CacheException {
      return Left(CacheFailure('Failed to cache user'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.signIn(
        email: email,
        password: password,
      );
      await localDataSource.cacheUser(user);
      return Right(user);
    } on ServerException {
      return Left(ServerFailure('Failed to sign in'));
    } on CacheException {
      return Left(CacheFailure('Failed to cache user'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await Future.wait([
        remoteDataSource.signOut(),
        localDataSource.clearCachedUser(),
      ]);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure('Failed to sign out'));
    } on CacheException {
      return Left(CacheFailure('Failed to clear cached user'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final isCached = await localDataSource.isUserCached();
      if (isCached) {
        final cachedUser = await localDataSource.getCachedUser();
        return Right(cachedUser);
      }
      final user = await remoteDataSource.getCurrentUser();
      await localDataSource.cacheUser(user);
      return Right(user);
    } on ServerException {
      return Left(ServerFailure('Failed to get current user'));
    } on CacheException {
      return Left(CacheFailure(
        
        'Failed to get cached user'));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile({
    String? username,
    String? photoUrl,
  }) async {
    try {
      await remoteDataSource.updateProfile(
        username: username,
        photoUrl: photoUrl,
      );
      final updatedUser = await remoteDataSource.getCurrentUser();
      await localDataSource.cacheUser(updatedUser);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure('Failed to update profile'));
    } on CacheException {
      return Left(CacheFailure('Failed to cache updated user'));
    }
  }

  @override
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await remoteDataSource.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure(
        
        'Failed to update password'));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({required String email}) async {
    try {
      await remoteDataSource.resetPassword(email: email);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure(
        
        'Failed to reset password'));
    }
  }

  @override
  Future<Either<Failure, bool>> isSignedIn() async {
    try {
      final result = await remoteDataSource.isSignedIn();
      return Right(result);
    } on ServerException {
      return Left(ServerFailure(
        
        'Failed to check sign in status'));
    }
  }
}
