# Design Specification: Premium Tech Theme & Admin Dashboard Redesign

This document defines the redesign of the app theme to target a high-end "Mobile & Tech Store" instead of a "Toy Store", and clearly distinguishes the Admin pages from the User pages.

## 1. Overview
The current app has a toy-store feel because it uses:
- The app title "Toy Store App" in `main.dart`.
- Yellow/amber theme color accents (`Colors.amber`).
- Similar AppBar colors (`Colors.amberAccent`) for both User Profile and Admin screens, making them look identical.

We will redesign the app theme to use:
- **Premium Tech Color Palette**: Deep Indigo (`Colors.indigo`) and Slate (`Colors.blueGrey`) as the primary branding colors.
- **Admin Dashboard Theme**: Dark theme styling (`Colors.blueGrey.shade900` / Dark Slate) for all Admin screens to signify a secure backend dashboard, separate from the customer-facing interface.

---

## 2. Theme Configuration (`main.dart`)
- Title: `"Mobile Tech Store"`
- Primary Color: `Colors.indigo`
- Theme adjustments:
  ```dart
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      primary: Colors.indigo,
    ),
    useMaterial3: true,
  ),
  ```

---

## 3. Screen Variations

### 3.1 HomeScreen & ProfileScreen (Customer Facing)
- Clean, bright UI with Indigo accents.
- AppBar: Indigo or AmberAccent replaced with matching Indigo/White styling.

### 3.2 CategoryAdminScreen (Admin Dashboard)
- AppBar background: `Colors.blueGrey.shade900` (Dark Slate).
- AppBar title: `"ADMIN - QUẢN LÝ THỂ LOẠI"`.
- FloatingActionButton background: `Colors.blueGrey.shade800`.
- Cards: Sleek border borders with slate-colored accents.

---

## 4. Verification Plan

### Automated Tests
Run `flutter test` to ensure that all widget tests compile and pass with the updated colors and text.

### Manual Verification
1. Launch the app.
2. Confirm the home page has a clean tech-themed navigation and app bar.
3. Log in as an Admin, navigate to Profile, and click "Quản lý thể loại".
4. Confirm the Category Admin screen is styled as a dark dashboard, distinct from the rest of the application.
