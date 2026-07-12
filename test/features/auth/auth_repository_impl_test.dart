import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toy_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:toy_app/features/auth/data/repositories/auth_repository_impl.dart';

/// Fake datasource ném FirebaseAuthException với code chỉ định
/// để kiểm tra AuthRepositoryImpl map sang thông điệp tiếng Việt.
class ThrowingAuthDataSource implements AuthRemoteDataSource {
  final String code;
  ThrowingAuthDataSource(this.code);

  FirebaseAuthException _error() => FirebaseAuthException(code: code);

  @override
  Stream<User?> authStateChanges() => const Stream.empty();

  @override
  User? get currentUser => null;

  @override
  Future<User> signIn({required String email, required String password}) async =>
      throw _error();

  @override
  Future<User> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async =>
      throw _error();

  @override
  Future<void> signOut() async => throw _error();

  @override
  Future<void> sendPasswordReset({required String email}) async =>
      throw _error();

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async =>
      throw _error();

  @override
  Future<User> updateProfile({
    required String displayName,
    required String photoUrl,
  }) async =>
      throw _error();
}

void main() {
  // Kiểm tra từng mã lỗi Firebase được map đúng sang thông điệp tiếng Việt.
  // Dùng signIn làm cửa ngõ vì nó bắt FirebaseAuthException.
  final cases = <String, String>{
    'invalid-email': 'Email không hợp lệ.',
    'user-disabled': 'Tài khoản đã bị vô hiệu hóa.',
    'user-not-found': 'Không tìm thấy tài khoản với email này.',
    'wrong-password': 'Email hoặc mật khẩu không đúng.',
    'invalid-credential': 'Email hoặc mật khẩu không đúng.',
    'email-already-in-use': 'Email này đã được đăng ký.',
    'weak-password': 'Mật khẩu quá yếu (cần ít nhất 6 ký tự).',
    'operation-not-allowed': 'Phương thức đăng nhập chưa được bật.',
    'too-many-requests': 'Bạn thao tác quá nhiều lần. Vui lòng thử lại sau.',
    'requires-recent-login':
        'Vui lòng đăng nhập lại để thực hiện thao tác này.',
  };

  group('AuthRepositoryImpl - map lỗi FirebaseAuthException', () {
    cases.forEach((code, expectedMessage) {
      test('code "$code" -> "$expectedMessage"', () async {
        final repo = AuthRepositoryImpl(ThrowingAuthDataSource(code));
        final result = await repo.signIn(email: 'a@b.com', password: '123456');
        expect(result.isLeft(), isTrue);
        result.match(
          (error) => expect(error, expectedMessage),
          (_) => fail('Kỳ vọng Left nhưng nhận Right'),
        );
      });
    });

    test('mã lỗi lạ -> dùng message mặc định của exception', () async {
      final repo = AuthRepositoryImpl(ThrowingAuthDataSource('some-weird-code'));
      final result = await repo.signIn(email: 'a@b.com', password: '123456');
      expect(result.isLeft(), isTrue);
    });
  });

  group('AuthRepositoryImpl - các thao tác khác trả Left khi lỗi', () {
    test('sendPasswordReset user-not-found', () async {
      final repo = AuthRepositoryImpl(ThrowingAuthDataSource('user-not-found'));
      final result = await repo.sendPasswordReset(email: 'ghost@b.com');
      result.match(
        (error) => expect(error, 'Không tìm thấy tài khoản với email này.'),
        (_) => fail('Kỳ vọng Left'),
      );
    });

    test('changePassword requires-recent-login', () async {
      final repo =
          AuthRepositoryImpl(ThrowingAuthDataSource('requires-recent-login'));
      final result = await repo.changePassword(
        currentPassword: 'old',
        newPassword: 'new123',
      );
      result.match(
        (error) => expect(
            error, 'Vui lòng đăng nhập lại để thực hiện thao tác này.'),
        (_) => fail('Kỳ vọng Left'),
      );
    });
  });
}
