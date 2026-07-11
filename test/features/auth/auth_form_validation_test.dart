import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toy_app/features/auth/presentation/views/login_screen.dart';
import 'package:toy_app/features/auth/presentation/views/register_screen.dart';
import 'package:toy_app/features/auth/presentation/views/forgot_password_screen.dart';
import 'package:toy_app/features/auth/presentation/views/change_password_screen.dart';

void main() {
  Widget wrap(Widget child) => ProviderScope(
        child: MaterialApp(home: child),
      );

  group('LoginScreen - validate', () {
    testWidgets('submit rỗng -> báo lỗi email và mật khẩu', (tester) async {
      await tester.pumpWidget(wrap(const LoginScreen()));
      await tester.tap(find.widgetWithText(FilledButton, 'Đăng nhập'));
      await tester.pump();

      expect(find.text('Vui lòng nhập email'), findsOneWidget);
      expect(find.text('Vui lòng nhập mật khẩu'), findsOneWidget);
    });

    testWidgets('email sai định dạng -> báo lỗi', (tester) async {
      await tester.pumpWidget(wrap(const LoginScreen()));
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'), 'not-an-email');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Mật khẩu'), '123456');
      await tester.tap(find.widgetWithText(FilledButton, 'Đăng nhập'));
      await tester.pump();

      expect(find.text('Email không hợp lệ'), findsOneWidget);
    });
  });

  group('RegisterScreen - validate', () {
    testWidgets('submit rỗng -> báo lỗi tên, email, mật khẩu', (tester) async {
      await tester.pumpWidget(wrap(const RegisterScreen()));
      await tester.tap(find.widgetWithText(FilledButton, 'Đăng ký'));
      await tester.pump();

      expect(find.text('Vui lòng nhập tên'), findsOneWidget);
      expect(find.text('Vui lòng nhập email'), findsOneWidget);
      expect(find.text('Mật khẩu cần ít nhất 6 ký tự'), findsOneWidget);
    });

    testWidgets('mật khẩu < 6 ký tự -> báo lỗi', (tester) async {
      await tester.pumpWidget(wrap(const RegisterScreen()));
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Tên hiển thị'), 'User');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'), 'a@b.com');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Mật khẩu'), '123');
      await tester.tap(find.widgetWithText(FilledButton, 'Đăng ký'));
      await tester.pump();

      expect(find.text('Mật khẩu cần ít nhất 6 ký tự'), findsOneWidget);
    });

    testWidgets('mật khẩu xác nhận không khớp -> báo lỗi', (tester) async {
      await tester.pumpWidget(wrap(const RegisterScreen()));
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Tên hiển thị'), 'User');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'), 'a@b.com');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Mật khẩu'), '123456');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Xác nhận mật khẩu'), '654321');
      await tester.tap(find.widgetWithText(FilledButton, 'Đăng ký'));
      await tester.pump();

      expect(find.text('Mật khẩu xác nhận không khớp'), findsOneWidget);
    });
  });

  group('ForgotPasswordScreen - validate', () {
    testWidgets('email rỗng -> báo lỗi', (tester) async {
      await tester.pumpWidget(wrap(const ForgotPasswordScreen()));
      await tester.tap(find.widgetWithText(FilledButton, 'Gửi liên kết đặt lại'));
      await tester.pump();

      expect(find.text('Vui lòng nhập email'), findsOneWidget);
    });
  });

  group('ChangePasswordScreen - validate', () {
    testWidgets('submit rỗng -> báo lỗi mật khẩu hiện tại và mới',
        (tester) async {
      await tester.pumpWidget(wrap(const ChangePasswordScreen()));
      await tester.tap(find.widgetWithText(FilledButton, 'Cập nhật mật khẩu'));
      await tester.pump();

      expect(find.text('Vui lòng nhập mật khẩu hiện tại'), findsOneWidget);
      expect(find.text('Mật khẩu mới cần ít nhất 6 ký tự'), findsOneWidget);
    });

    testWidgets('mật khẩu mới không khớp -> báo lỗi', (tester) async {
      await tester.pumpWidget(wrap(const ChangePasswordScreen()));
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Mật khẩu hiện tại'), 'old123');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Mật khẩu mới'), 'new123');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Xác nhận mật khẩu mới'),
          'different');
      await tester.tap(find.widgetWithText(FilledButton, 'Cập nhật mật khẩu'));
      await tester.pump();

      expect(find.text('Mật khẩu xác nhận không khớp'), findsOneWidget);
    });
  });
}
