import 'package:fpdart/fpdart.dart';
import '../entities/app_user.dart';

abstract interface class AuthRepository {
  /// Stream phát ra user hiện tại (null khi đã đăng xuất).
  Stream<AppUser?> authStateChanges();

  /// User đang đăng nhập, null nếu chưa.
  AppUser? get currentUser;

  Future<Either<String, AppUser>> signIn({
    required String email,
    required String password,
  });

  Future<Either<String, AppUser>> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  Future<Either<String, Unit>> signOut();

  Future<Either<String, Unit>> sendPasswordReset({required String email});

  Future<Either<String, Unit>> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
