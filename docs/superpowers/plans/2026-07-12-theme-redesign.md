# Premium Tech Theme & Admin Dashboard Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign the app theme to target a high-end "Mobile & Tech Store" instead of a "Toy Store", and clearly distinguish the Admin pages from the User pages.

**Architecture:** Change main theme color scheme to `Colors.indigo`. Set app bar color of customer-facing screens to `Colors.indigo`. Change CategoryAdminScreen theme to a dark slate dashboard (`Colors.blueGrey.shade900`).

**Tech Stack:** Flutter, Riverpod.

## Global Constraints
- Do not add any new packages.
- Always run the tests to verify correctness: `flutter test`
- Make sure existing test suite passes completely.

---

### Task 1: Update Global Theme Configuration

**Files:**
- Modify: [main.dart](file:///d:/mobile_app/lib/main.dart)

- [ ] **Step 1: Modify MyApp configuration**
  Change title to `"Mobile Tech Store"` and change theme seed color to `Colors.indigo`:
  ```dart
  // Locate class MyApp in main.dart:
  // Change title: 'Toy Store App' -> 'Mobile Tech Store'
  // Change seedColor: Colors.amber -> Colors.indigo
  ```

---

### Task 2: Redesign Screens with Premium Theme Accents

**Files:**
- Modify: [home_screen.dart](file:///d:/mobile_app/lib/features/home/presentation/views/home_screen.dart)
- Modify: [profile_screen.dart](file:///d:/mobile_app/lib/features/auth/presentation/views/profile_screen.dart)
- Modify: [category_admin_screen.dart](file:///d:/mobile_app/lib/features/products/presentation/views/category_admin_screen.dart)

- [ ] **Step 1: Redesign HomeScreen App Bar**
  Modify `lib/features/home/presentation/views/home_screen.dart` to set custom AppBar color:
  ```dart
  // Inside home_screen.dart AppBar:
  // Add backgroundColor: Colors.indigo,
  // Add foregroundColor: Colors.white,
  // Add elevation: 0
  ```

- [ ] **Step 2: Redesign ProfileScreen App Bar**
  Modify `lib/features/auth/presentation/views/profile_screen.dart` to change AppBar:
  ```dart
  // Inside profile_screen.dart AppBar:
  // Change backgroundColor: Colors.amberAccent -> Colors.indigo
  // Change foregroundColor/textColor: Colors.black -> Colors.white
  ```

- [ ] **Step 3: Redesign CategoryAdminScreen to Dark Slate Dashboard**
  Modify `lib/features/products/presentation/views/category_admin_screen.dart` to style it as a dark dashboard:
  ```dart
  // Inside category_admin_screen.dart:
  // Set AppBar backgroundColor: Colors.blueGrey.shade900
  // Set AppBar foregroundColor: Colors.white
  // Set Scaffold backgroundColor: Colors.grey.shade100
  // Set FloatingActionButton backgroundColor: Colors.blueGrey.shade900
  ```

- [ ] **Step 4: Run all tests to verify compilation and passing status**
  Run: `flutter test`
  Expected: PASS.

- [ ] **Step 5: Commit**
  ```bash
  git add lib/main.dart lib/features/home/presentation/views/home_screen.dart lib/features/auth/presentation/views/profile_screen.dart lib/features/products/presentation/views/category_admin_screen.dart
  git commit -m "feat: redesign app to premium tech theme and dark admin dashboard"
  ```
