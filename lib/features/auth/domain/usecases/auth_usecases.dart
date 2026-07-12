import 'package:fpdart/fpdart.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository _repository;
  const SignInUseCase(this._repository);

  Future<Either<String, AppUser>> execute({
    required String email,
    required String password,
  }) {
    return _repository.signIn(email: email, password: password);
  }
}

class SignUpUseCase {
  final AuthRepository _repository;
  const SignUpUseCase(this._repository);

  Future<Either<String, AppUser>> execute({
    required String email,
    required String password,
    required String displayName,
  }) {
    return _repository.signUp(
      email: email,
      password: password,
      displayName: displayName,
    );
  }
}

class SignOutUseCase {
  final AuthRepository _repository;
  const SignOutUseCase(this._repository);

  Future<Either<String, Unit>> execute() => _repository.signOut();
}

class SendPasswordResetUseCase {
  final AuthRepository _repository;
  const SendPasswordResetUseCase(this._repository);

  Future<Either<String, Unit>> execute({required String email}) {
    return _repository.sendPasswordReset(email: email);
  }
}

class ChangePasswordUseCase {
  final AuthRepository _repository;
  const ChangePasswordUseCase(this._repository);

  Future<Either<String, Unit>> execute({
    required String currentPassword,
    required String newPassword,
  }) {
    return _repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}

class UpdateProfileUseCase {
  final AuthRepository _repository;
  const UpdateProfileUseCase(this._repository);

  Future<Either<String, AppUser>> execute({
    required String displayName,
    required String photoUrl,
  }) {
    return _repository.updateProfile(
      displayName: displayName,
      photoUrl: photoUrl,
    );
  }
}
