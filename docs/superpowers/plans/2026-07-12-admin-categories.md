# Admin Category Management Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Allow Admins to manage (add, edit, delete, search, list) product categories in a Category Admin Screen. Synchronize the categories on the Home Screen tabs in real-time.

**Architecture:** User profiles with role are stored at `/users/{uid}`. Auto-generated Category documents are stored at `/categories`. Home screen categories stream from the `/categories` collection.

**Tech Stack:** Flutter, Riverpod, Cloud Firestore.

## Global Constraints
- Do not add any new packages.
- Always run the tests to verify correctness: `flutter test`
- Write clear unit/widget tests for new components.

---

### Task 1: Integrate User Role Profile and Sign Up Flow

**Files:**
- Modify: [auth_remote_datasource.dart](file:///d:/mobile_app/lib/features/auth/data/datasources/auth_remote_datasource.dart)
- Modify: [auth_providers.dart](file:///d:/mobile_app/lib/features/auth/presentation/controllers/auth_providers.dart)
- Test: [auth_action_controller_test.dart](file:///d:/mobile_app/test/features/auth/auth_action_controller_test.dart) (mock updates if any)

- [ ] **Step 1: Write user profile to Firestore on Sign Up**
  Modify `signUp` in `lib/features/auth/data/datasources/auth_remote_datasource.dart` to set a profile document:
  ```dart
  // Import cloud_firestore at the top of the file
  import 'package:cloud_firestore/cloud_firestore.dart';

  // Inside signUp method, after user reload:
  await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
    'uid': user.uid,
    'email': email,
    'displayName': displayName,
    'role': 'user',
  });
  ```

- [ ] **Step 2: Add userProfileProvider**
  Modify `lib/features/auth/presentation/controllers/auth_providers.dart` to add the `userProfileProvider`:
  ```dart
  // Import cloud_firestore at the top of the file
  import 'package:cloud_firestore/cloud_firestore.dart';

  // At the bottom of the file:
  final userProfileProvider = StreamProvider<Map<String, dynamic>?>((ref) {
    final authState = ref.watch(authStateProvider);
    final uid = authState.valueOrNull?.uid;
    if (uid == null) return Stream.value(null);
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.data());
  });
  ```

- [ ] **Step 3: Run existing auth tests**
  Run: `flutter test test/features/auth/`
  Expected: PASS.

- [ ] **Step 4: Commit**
  ```bash
  git add lib/features/auth/data/datasources/auth_remote_datasource.dart lib/features/auth/presentation/controllers/auth_providers.dart
  git commit -m "feat: create user profile document on sign up and add userProfileProvider"
  ```

---

### Task 2: Update HomeScreen Category Sync

**Files:**
- Modify: [product_list_notifier.dart](file:///d:/mobile_app/lib/features/products/presentation/controllers/product_list_notifier.dart)

- [ ] **Step 1: Fetch categories from Firestore**
  Modify `categoriesProvider` in `lib/features/products/presentation/controllers/product_list_notifier.dart` to watch Firestore `/categories`:
  ```dart
  // Locate line 78: final categoriesProvider = Provider...
  // Replace categoriesProvider with StreamProvider:
  final categoriesProvider = StreamProvider<List<String>>((ref) {
    return ref
        .watch(firestoreProvider)
        .collection('categories')
        .snapshots()
        .map((snapshot) {
      final names = snapshot.docs
          .map((doc) => (doc.data()['name'] ?? '').toString())
          .where((name) => name.isNotEmpty)
          .toList();
      names.sort();
      return ['Tất cả', ...names];
    });
  });
  ```

- [ ] **Step 2: Update HomeScreen category watch**
  Modify `lib/features/home/presentation/views/home_screen.dart` to handle `AsyncValue` from `categoriesProvider`:
  ```dart
  // Change: final categories = ref.watch(categoriesProvider);
  // To:
  final categoriesAsync = ref.watch(categoriesProvider);
  final categories = categoriesAsync.valueOrNull ?? const ['Tất cả'];
  ```

- [ ] **Step 3: Update existing product tests**
  Update `test/features/products/presentation/controllers/product_list_notifier_test.dart` and `test/features/home/presentation/views/home_screen_test.dart` to override `categoriesProvider` with a stream.
  ```dart
  categoriesProvider.overrideWith((ref) => Stream.value(['Tất cả', 'Điện thoại', 'Laptop']))
  ```

- [ ] **Step 4: Verify tests pass**
  Run: `flutter test`
  Expected: PASS.

- [ ] **Step 5: Commit**
  ```bash
  git add lib/features/products/presentation/controllers/product_list_notifier.dart lib/features/home/presentation/views/home_screen.dart test/
  git commit -m "feat: fetch categories in real-time from Firestore on HomeScreen"
  ```

---

### Task 3: Implement Category Admin Screen & Navigation

**Files:**
- Create: [category_admin_screen.dart](file:///d:/mobile_app/lib/features/products/presentation/views/category_admin_screen.dart)
- Create: [category_admin_screen_test.dart](file:///d:/mobile_app/test/features/products/presentation/views/category_admin_screen_test.dart)
- Modify: [profile_screen.dart](file:///d:/mobile_app/lib/features/auth/presentation/views/profile_screen.dart)

- [ ] **Step 1: Implement CategoryAdminScreen**
  Create `lib/features/products/presentation/views/category_admin_screen.dart` with a List, Search bar, Add, Edit, and Delete dialogs.

- [ ] **Step 2: Add Admin button in ProfileScreen**
  Modify `lib/features/auth/presentation/views/profile_screen.dart` to read `userProfileProvider` and conditionally show the "Quản lý thể loại" button:
  ```dart
  final profileAsync = ref.watch(userProfileProvider);
  final role = profileAsync.valueOrNull?.role; // Or map role

  // Insert before sign out button:
  if (role == 'admin') ...[
    const SizedBox(height: 12),
    OutlinedButton.icon(
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const CategoryAdminScreen(),
        ),
      ),
      icon: const Icon(Icons.category),
      label: const Text('Quản lý thể loại'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),
  ]
  ```

- [ ] **Step 3: Write tests for CategoryAdminScreen**
  Create `test/features/products/presentation/views/category_admin_screen_test.dart` to verify list rendering, searching, and dialog actions.

- [ ] **Step 4: Verify all tests pass**
  Run: `flutter test`
  Expected: PASS.

- [ ] **Step 5: Commit**
  ```bash
  git add lib/features/products/presentation/views/category_admin_screen.dart lib/features/auth/presentation/views/profile_screen.dart test/
  git commit -m "feat: add CategoryAdminScreen and link from ProfileScreen"
  ```
