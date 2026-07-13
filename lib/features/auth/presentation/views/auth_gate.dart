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

    return authState.when(
      data: (user) {
        if (user == null) {
          return const LoginScreen();
        }
        return profileAsync.when(
          data: (profile) {
            final role = profile?['role'];
            if (role == 'admin') {
              return const AdminHomeScreen();
            }
            return const HomeScreen();
          },
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Scaffold(
            body: Center(child: Text('Lỗi tải quyền: $error')),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(child: Text('Lỗi xác thực: $error')),
      ),
    );
  }
}
