import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_providers.dart';

/// Trạng thái xử lý một hành động auth (submit form).
class AuthActionState {
  final bool isLoading;
  final String? errorMessage;

  const AuthActionState({this.isLoading = false, this.errorMessage});

  const AuthActionState.idle() : this();
  const AuthActionState.loading() : this(isLoading: true);
  const AuthActionState.failure(String message)
      : this(errorMessage: message);
}

/// Controller dùng chung cho các form: login, register, forgot, change password.
/// Trả về true nếu thao tác thành công để View điều hướng/hiển thị thông báo.
class AuthActionController extends AutoDisposeNotifier<AuthActionState> {
  @override
  AuthActionState build() => const AuthActionState.idle();

  Future<bool> signIn({required String email, required String password}) {
    return _run(() => ref
        .read(signInUseCaseProvider)
        .execute(email: email, password: password));
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) {
    return _run(() => ref.read(signUpUseCaseProvider).execute(
          email: email,
          password: password,
          displayName: displayName,
        ));
  }

  Future<bool> sendPasswordReset({required String email}) {
    return _run(() =>
        ref.read(sendPasswordResetUseCaseProvider).execute(email: email));
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _run(() => ref.read(changePasswordUseCaseProvider).execute(
          currentPassword: currentPassword,
          newPassword: newPassword,
        ));
  }

  Future<bool> updateProfile({
    required String displayName,
    required String photoUrl,
  }) {
    return _run(() => ref.read(updateProfileUseCaseProvider).execute(
          displayName: displayName,
          photoUrl: photoUrl,
        ));
  }

  Future<bool> signOut() {
    return _run(() => ref.read(signOutUseCaseProvider).execute());
  }

  /// Chạy một usecase trả Either, cập nhật loading/error, trả về true nếu Right.
  Future<bool> _run(Future<dynamic> Function() action) async {
    state = const AuthActionState.loading();
    final result = await action();
    // result là Either<String, T>; fold để lấy trạng thái.
    return result.fold(
      (error) {
        state = AuthActionState.failure(error as String);
        return false;
      },
      (_) {
        state = const AuthActionState.idle();
        return true;
      },
    );
  }
}

final authActionControllerProvider =
    AutoDisposeNotifierProvider<AuthActionController, AuthActionState>(() {
  return AuthActionController();
});
