import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/auth_providers.dart';
import '../../../home/presentation/views/home_screen.dart';
import '../../../home/presentation/views/admin_home_screen.dart';
import 'login_screen.dart';

/// Lắng nghe trạng thái đăng nhập và điều hướng:
/// - Chưa đăng nhập -> màn hình đăng nhập (LoginScreen)
/// - Đã đăng nhập:
///   - Admin -> màn hình Admin (AdminHomeScreen)
///   - User -> màn hình User (HomeScreen)
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final profileAsync = ref.watch(userProfileProvider);

    // Chỉ hiển thị màn hình Loading khi chưa có dữ liệu xác thực ban đầu
    if (authState.isLoading && !authState.hasValue) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (authState.hasError) {
      return Scaffold(
        body: Center(child: Text('Lỗi xác thực: ${authState.error}')),
      );
    }

    final user = authState.value;
    if (user == null) {
      return const LoginScreen();
    }

    // Chỉ hiển thị màn hình Loading khi chưa có thông tin profile ban đầu
    if (profileAsync.isLoading && !profileAsync.hasValue) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (profileAsync.hasError) {
      return Scaffold(
        body: Center(child: Text('Lỗi tải quyền: ${profileAsync.error}')),
      );
    }

    final profile = profileAsync.value;
    final role = profile?['role'];
    if (role == 'admin') {
      return const AdminHomeScreen();
    }
    return const HomeScreen();
  }
}
