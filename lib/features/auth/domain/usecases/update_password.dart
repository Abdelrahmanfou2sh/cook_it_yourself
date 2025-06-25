import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/i_auth_repository.dart';

class UpdatePassword {
  final IAuthRepository repository;

  UpdatePassword(this.repository);

  Future<Either<Failure, void>> call({
    required String currentPassword,
    required String newPassword,
  }) async {
    return await repository.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}