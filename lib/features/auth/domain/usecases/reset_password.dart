import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/i_auth_repository.dart';

class ResetPassword {
  final IAuthRepository repository;

  ResetPassword(this.repository);

  Future<Either<Failure, void>> call({required String email}) async {
    return await repository.resetPassword(email: email);
  }
}