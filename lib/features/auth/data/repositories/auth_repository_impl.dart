import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  AppUser _toEntity(User user) => AppUser(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        emailVerified: user.emailVerified,
      );

  @override
  Stream<AppUser?> authStateChanges() {
    return _remoteDataSource
        .authStateChanges()
        .map((user) => user == null ? null : _toEntity(user));
  }

  @override
  AppUser? get currentUser {
    final user = _remoteDataSource.currentUser;
    return user == null ? null : _toEntity(user);
  }

  @override
  Future<Either<String, AppUser>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remoteDataSource.signIn(
        email: email,
        password: password,
      );
      return Right(_toEntity(user));
    } on FirebaseAuthException catch (e) {
      return Left(_mapError(e));
    } catch (e) {
      return Left('Đã có lỗi xảy ra: $e');
    }
  }

  @override
  Future<Either<String, AppUser>> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final user = await _remoteDataSource.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      return Right(_toEntity(user));
    } on FirebaseAuthException catch (e) {
      return Left(_mapError(e));
    } catch (e) {
      return Left('Đã có lỗi xảy ra: $e');
    }
  }

  @override
  Future<Either<String, Unit>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const Right(unit);
    } catch (e) {
      return Left('Không thể đăng xuất: $e');
    }
  }

  @override
  Future<Either<String, Unit>> sendPasswordReset({
    required String email,
  }) async {
    try {
      await _remoteDataSource.sendPasswordReset(email: email);
      return const Right(unit);
    } on FirebaseAuthException catch (e) {
      return Left(_mapError(e));
    } catch (e) {
      return Left('Đã có lỗi xảy ra: $e');
    }
  }

  @override
  Future<Either<String, Unit>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return const Right(unit);
    } on FirebaseAuthException catch (e) {
      return Left(_mapError(e));
    } catch (e) {
      return Left('Đã có lỗi xảy ra: $e');
    }
  }

  // Chuyển mã lỗi Firebase sang thông điệp tiếng Việt thân thiện.
  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Email không hợp lệ.';
      case 'user-disabled':
        return 'Tài khoản đã bị vô hiệu hóa.';
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email hoặc mật khẩu không đúng.';
      case 'email-already-in-use':
        return 'Email này đã được đăng ký.';
      case 'weak-password':
        return 'Mật khẩu quá yếu (cần ít nhất 6 ký tự).';
      case 'operation-not-allowed':
        return 'Phương thức đăng nhập chưa được bật.';
      case 'too-many-requests':
        return 'Bạn thao tác quá nhiều lần. Vui lòng thử lại sau.';
      case 'requires-recent-login':
        return 'Vui lòng đăng nhập lại để thực hiện thao tác này.';
      case 'no-current-user':
        return 'Chưa đăng nhập.';
      default:
        return e.message ?? 'Đã có lỗi xác thực xảy ra.';
    }
  }
}
