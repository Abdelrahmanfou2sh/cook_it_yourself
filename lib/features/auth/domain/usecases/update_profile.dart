import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/i_auth_repository.dart';

class UpdateProfile {
  final IAuthRepository repository;

  UpdateProfile(this.repository);

  Future<Either<Failure, void>> call({
    String? username,
    String? photoUrl,
  }) async {
    return await repository.updateProfile(
      username: username,
      photoUrl: photoUrl,
    );
  }
}