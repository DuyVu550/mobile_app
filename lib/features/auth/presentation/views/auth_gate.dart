import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/auth_providers.dart';
import '../../../toy_list/presentation/views/toy_list_screen.dart';
import 'login_screen.dart';

/// Lắng nghe trạng thái đăng nhập và điều hướng:
/// - Có user  -> màn hình chính (ToyListScreen)
/// - Chưa có  -> màn hình đăng nhập
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) =>
          user == null ? const LoginScreen() : const ToyListScreen(),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(child: Text('Lỗi xác thực: $error')),
      ),
    );
  }
}
