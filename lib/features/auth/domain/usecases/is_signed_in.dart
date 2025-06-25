import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/i_auth_repository.dart';

class IsSignedIn {
  final IAuthRepository repository;

  IsSignedIn(this.repository);

  Future<Either<Failure, bool>> call() async {
    return await repository.isSignedIn();
  }
}