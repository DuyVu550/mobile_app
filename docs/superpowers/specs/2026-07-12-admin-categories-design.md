# Design Specification: Admin Category Management

This document defines the design and architecture for the Admin Category Management feature.

## 1. Overview
Admins can Manage (Create, Read, Update, Delete, and Search) product categories.
- User roles are stored in Firestore: `/users/{uid}` with a `role` field.
- Signed up users default to `role: 'user'`.
- Admins see a "Quản lý thể loại" button in their Profile Screen.
- Category data is stored in the `/categories` collection on Cloud Firestore.
- The home screen category tabs are fed in realtime from the `/categories` collection.

---

## 2. Firestore Data Model

### User Collection
`users/{uid}`
- `uid`: `string`
- `email`: `string`
- `displayName`: `string`
- `role`: `string` (e.g. `'admin'` or `'user'`)

### Categories Collection
`categories/{categoryId}` (Auto-generated document ID)
- `name`: `string`

---

## 3. Architecture & Data Flow

### 3.1 Sign Up Integration
Modify the Sign Up flow to create the user profile document in Firestore:
- Modify `AuthRepositoryImpl` to write to Firestore at `users/{user.uid}` upon successful creation of the Firebase Auth user.

### 3.2 Providers
- `userProfileProvider`: Watches `users/{uid}` document to determine the logged-in user's role.
- `categoriesProvider`: Modified to read from the `/categories` collection in Firestore, sort alphabetically, and prepend `'Tất cả'`.
- `adminCategoriesProvider`: Returns raw category documents (with IDs) from `/categories` for Admin management list view.

---

## 4. UI / UX Design

### 4.1 Profile Screen entry point
If `userProfileProvider` indicates `role == 'admin'`, we append a list tile or outlined button:
- Label: `Quản lý thể loại`
- Icon: `Icons.category`
- Navigation: Route to `CategoryAdminScreen`.

### 4.2 Category Admin Screen
File: `lib/features/products/presentation/views/category_admin_screen.dart`
- Search bar at the top for local filtering of categories.
- ListView listing each category:
    - Title: Category Name.
    - Actions: Edit Icon, Delete Icon.
- FloatingActionButton: "+" (Add Category).
- Dialogs for Add/Edit/Delete actions.

---

## 5. Verification Plan

### Automated Tests
We will add tests in `test/features/products/presentation/views/category_admin_screen_test.dart` to verify:
1. CategoryAdminScreen lists categories correctly.
2. Clicking edit/delete triggers expected behavior.

### Manual Verification
1. Register a new user. Verify their document in Firestore `/users/{uid}` is created with `role: 'user'`.
2. Manually change `role` to `'admin'` in Firestore for a test user.
3. Open Profile Screen, confirm the "Quản lý thể loại" button is visible.
4. Click the button, create, edit, delete categories.
5. Go back to Home Screen, confirm category tabs update in real-time.
