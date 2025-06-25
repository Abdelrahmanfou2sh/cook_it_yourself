import 'package:cook/features/auth/domain/usecases/get_current_user.dart';
import 'package:cook/features/auth/domain/usecases/is_signed_in.dart';
import 'package:cook/features/auth/domain/usecases/reset_password.dart';
import 'package:cook/features/auth/domain/usecases/sign_in.dart';
import 'package:cook/features/auth/domain/usecases/sign_out.dart';
import 'package:cook/features/auth/domain/usecases/sign_up.dart';
import 'package:cook/features/auth/domain/usecases/update_password.dart';
import 'package:cook/features/auth/domain/usecases/update_profile.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignUp _signUp;
  final SignIn _signIn;
  final SignOut _signOut;
  final GetCurrentUser _getCurrentUser;
  final UpdateProfile _updateProfile;
  final UpdatePassword _updatePassword;
  final ResetPassword _resetPassword;
  final IsSignedIn _isSignedIn;

  AuthCubit({
    required SignUp signUp,
    required SignIn signIn,
    required SignOut signOut,
    required GetCurrentUser getCurrentUser,
    required UpdateProfile updateProfile,
    required UpdatePassword updatePassword,
    required ResetPassword resetPassword,
    required IsSignedIn isSignedIn,
  })
      : _signUp = signUp,
        _signIn = signIn,
        _signOut = signOut,
        _getCurrentUser = getCurrentUser,
        _updateProfile = updateProfile,
        _updatePassword = updatePassword,
        _resetPassword = resetPassword,
        _isSignedIn = isSignedIn,
        super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    final result = await _isSignedIn();
    result.fold(
      (failure) => emit(const AuthError('Failed to check auth status')),
      (isSignedIn) async {
        if (isSignedIn) {
          final userResult = await _getCurrentUser();
          userResult.fold(
            (failure) => emit(const AuthError('Failed to get user data')),
            (user) => emit(Authenticated(user)),
          );
        } else {
          emit(Unauthenticated());
        }
      },
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    emit(AuthLoading());
    final result = await _signUp(
      email: email,
      password: password,
      username: username,
    );
    result.fold(
      (failure) => emit(const AuthError('Sign up failed')),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    final result = await _signIn(
      email: email,
      password: password,
    );
    result.fold(
      (failure) => emit(const AuthError('Sign in failed')),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> signOut() async {
    emit(AuthLoading());
    final result = await _signOut();
    result.fold(
      (failure) => emit(const AuthError('Sign out failed')),
      (_) => emit(Unauthenticated()),
    );
  }

  Future<void> updateProfile({
    String? username,
    String? photoUrl,
  }) async {
    emit(AuthLoading());
    final result = await _updateProfile(
      username: username,
      photoUrl: photoUrl,
    );
    result.fold(
      (failure) => emit(const AuthError('Failed to update profile')),
      (user) => emit(ProfileUpdateSuccess()),
    );
  }

  Future<void> getCurrentUser() async {
    emit(AuthLoading());
    final result = await _getCurrentUser();
    result.fold(
      (failure) => emit(const AuthError('Failed to get user data')),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    emit(AuthLoading());
    final result = await _updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    result.fold(
      (failure) => emit(const AuthError('Failed to update password')),
      (_) => emit(PasswordUpdateSuccess()),
    );
  }

  Future<void> resetPassword({required String email}) async {
    emit(AuthLoading());
    final result = await _resetPassword(email: email);
    result.fold(
      (failure) => emit(const AuthError('Failed to send reset password email')),
      (_) => emit(PasswordResetEmailSent()),
    );
  }
}