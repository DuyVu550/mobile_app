import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toy_app/features/home/presentation/views/admin_home_screen.dart';
import 'package:toy_app/features/auth/presentation/controllers/auth_providers.dart';
import 'package:toy_app/features/auth/domain/entities/app_user.dart';
import 'package:toy_app/core/providers/firebase_providers.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

class FakeAppUser extends AppUser {
  const FakeAppUser()
      : super(
          uid: 'admin123',
          email: 'admin@test.com',
          displayName: 'Admin User',
        );
}

void main() {
  testWidgets('AdminHomeScreen renders sidebar and switches tabs', (tester) async {
    final firestore = FakeFirebaseFirestore();
    
    // Seed some categories to avoid streams blocking
    await firestore.collection('categories').add({'name': 'Điện thoại'});

    // Let wide screen render
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firestoreProvider.overrideWithValue(firestore),
          authStateProvider.overrideWith((ref) => Stream.value(const FakeAppUser())),
          userProfileProvider.overrideWith((ref) => Stream.value({
            'role': 'admin',
            'displayName': 'Admin User',
          })),
        ],
        child: const MaterialApp(
          home: AdminHomeScreen(),
        ),
      ),
    );
    
    await tester.pumpAndSettle();

    // Verify Sidebar is persistent on wide screen
    expect(find.text('ADMINISTRATOR'), findsOneWidget);
    expect(find.text('Tổng quan'), findsOneWidget);
    expect(find.text('Quản lý thể loại'), findsOneWidget);
    expect(find.text('Quản lý sản phẩm'), findsOneWidget);
    expect(find.text('Quản lý thương hiệu'), findsOneWidget);
    expect(find.text('Hồ sơ cá nhân'), findsOneWidget);

    // Initial tab is Overview (Tổng quan)
    expect(find.text('Chào mừng quay trở lại, Admin!'), findsOneWidget);

    // Click 'Quản lý thể loại' in sidebar
    await tester.tap(find.text('Quản lý thể loại'));
    await tester.pumpAndSettle();

    // Now CategoryAdminScreen should be visible (appbar title QUẢN LÝ THỂ LOẠI)
    expect(find.text('QUẢN LÝ THỂ LOẠI'), findsWidgets);

    // Click 'Quản lý sản phẩm' in sidebar
    await tester.tap(find.text('Quản lý sản phẩm'));
    await tester.pumpAndSettle();
    expect(find.text('QUẢN LÝ SẢN PHẨM'), findsWidgets);

    // Click 'Quản lý thương hiệu' in sidebar
    await tester.tap(find.text('Quản lý thương hiệu'));
    await tester.pumpAndSettle();
    expect(find.text('QUẢN LÝ THƯƠNG HIỆU'), findsWidgets);

    // Click 'Hồ sơ cá nhân' in sidebar
    await tester.tap(find.text('Hồ sơ cá nhân'));
    await tester.pumpAndSettle();

    // Reset physical size for other tests
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
