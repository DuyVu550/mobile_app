import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:toy_app/features/auth/domain/entities/app_user.dart';
import 'package:toy_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:toy_app/features/auth/presentation/controllers/auth_providers.dart';
import 'package:toy_app/features/auth/presentation/controllers/auth_action_controller.dart';

/// Fake repository điều khiển được kết quả trả về cho từng thao tác.
class FakeAuthRepository implements AuthRepository {
  Either<String, AppUser> signInResult =
      const Right(AppUser(uid: 'u1', email: 'a@b.com'));
  Either<String, AppUser> signUpResult =
      const Right(AppUser(uid: 'u1', email: 'a@b.com'));
  Either<String, Unit> signOutResult = const Right(unit);
  Either<String, Unit> resetResult = const Right(unit);
  Either<String, Unit> changePasswordResult = const Right(unit);

  @override
  Stream<AppUser?> authStateChanges() => const Stream.empty();

  @override
  AppUser? get currentUser => null;

  @override
  Future<Either<String, AppUser>> signIn({
    required String email,
    required String password,
  }) async =>
      signInResult;

  @override
  Future<Either<String, AppUser>> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async =>
      signUpResult;

  @override
  Future<Either<String, Unit>> signOut() async => signOutResult;

  @override
  Future<Either<String, Unit>> sendPasswordReset({
    required String email,
  }) async =>
      resetResult;

  @override
  Future<Either<String, Unit>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async =>
      changePasswordResult;
}

void main() {
  late FakeAuthRepository fakeRepo;
  late ProviderContainer container;

  setUp(() {
    fakeRepo = FakeAuthRepository();
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );
    // Giữ notifier sống trong suốt test (AutoDispose).
    container.listen(authActionControllerProvider, (_, _) {});
  });

  tearDown(() => container.dispose());

  AuthActionController controller() =>
      container.read(authActionControllerProvider.notifier);

  AuthActionState state() => container.read(authActionControllerProvider);

  group('AuthActionController - signIn', () {
    test('thành công -> trả true, state idle, không có lỗi', () async {
      final ok = await controller().signIn(email: 'a@b.com', password: '123456');
      expect(ok, isTrue);
      expect(state().isLoading, isFalse);
      expect(state().errorMessage, isNull);
    });

    test('thất bại -> trả false, state chứa thông điệp lỗi', () async {
      fakeRepo.signInResult = const Left('Email hoặc mật khẩu không đúng.');
      final ok = await controller().signIn(email: 'a@b.com', password: 'wrong');
      expect(ok, isFalse);
      expect(state().isLoading, isFalse);
      expect(state().errorMessage, 'Email hoặc mật khẩu không đúng.');
    });
  });

  group('AuthActionController - signUp', () {
    test('thành công -> trả true', () async {
      final ok = await controller().signUp(
        email: 'new@b.com',
        password: '123456',
        displayName: 'New User',
      );
      expect(ok, isTrue);
      expect(state().errorMessage, isNull);
    });

    test('email đã tồn tại -> trả false + lỗi', () async {
      fakeRepo.signUpResult = const Left('Email này đã được đăng ký.');
      final ok = await controller().signUp(
        email: 'dup@b.com',
        password: '123456',
        displayName: 'Dup',
      );
      expect(ok, isFalse);
      expect(state().errorMessage, 'Email này đã được đăng ký.');
    });
  });

  group('AuthActionController - sendPasswordReset', () {
    test('thành công -> trả true', () async {
      final ok = await controller().sendPasswordReset(email: 'a@b.com');
      expect(ok, isTrue);
      expect(state().errorMessage, isNull);
    });

    test('không tìm thấy tài khoản -> trả false + lỗi', () async {
      fakeRepo.resetResult =
          const Left('Không tìm thấy tài khoản với email này.');
      final ok = await controller().sendPasswordReset(email: 'ghost@b.com');
      expect(ok, isFalse);
      expect(state().errorMessage, 'Không tìm thấy tài khoản với email này.');
    });
  });

  group('AuthActionController - changePassword', () {
    test('thành công -> trả true', () async {
      final ok = await controller().changePassword(
        currentPassword: 'old123',
        newPassword: 'new123',
      );
      expect(ok, isTrue);
      expect(state().errorMessage, isNull);
    });

    test('mật khẩu hiện tại sai -> trả false + lỗi', () async {
      fakeRepo.changePasswordResult =
          const Left('Email hoặc mật khẩu không đúng.');
      final ok = await controller().changePassword(
        currentPassword: 'wrong',
        newPassword: 'new123',
      );
      expect(ok, isFalse);
      expect(state().errorMessage, 'Email hoặc mật khẩu không đúng.');
    });

    test('phiên hết hạn (requires-recent-login) -> trả false + lỗi', () async {
      fakeRepo.changePasswordResult =
          const Left('Vui lòng đăng nhập lại để thực hiện thao tác này.');
      final ok = await controller().changePassword(
        currentPassword: 'old123',
        newPassword: 'new123',
      );
      expect(ok, isFalse);
      expect(state().errorMessage,
          'Vui lòng đăng nhập lại để thực hiện thao tác này.');
    });
  });

  group('AuthActionController - signOut', () {
    test('thành công -> trả true', () async {
      final ok = await controller().signOut();
      expect(ok, isTrue);
      expect(state().errorMessage, isNull);
    });

    test('thất bại -> trả false + lỗi', () async {
      fakeRepo.signOutResult = const Left('Không thể đăng xuất: lỗi mạng');
      final ok = await controller().signOut();
      expect(ok, isFalse);
      expect(state().errorMessage, 'Không thể đăng xuất: lỗi mạng');
    });
  });
}
