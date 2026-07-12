# Design Specification: Admin Left Navigation Drawer Menu

This document defines the architecture and layout for the Admin Left Navigation Drawer (left menu) on the `HomeScreen`.

## 1. Overview
Instead of accessing Admin features via a button on the User Profile screen, all Admin features will be consolidated into a premium **Left Navigation Drawer** (Left Menu) accessible directly from the `HomeScreen` for authenticated Admin users.
- Non-admin (customer) users will see the standard clean `HomeScreen` without any left drawer or hamburger menu icon.
- Admin users will see a hamburger menu icon on the top-left of the `HomeScreen` AppBar.
- Tapping the icon opens a drawer on the left side featuring the Admin Dashboard Navigation.

---

## 2. Drawer Design & Layout
The drawer will be styled as a professional dashboard menu using a dark slate background to clearly differentiate it from customer views.

### Drawer Header:
- Background: `Colors.blueGrey.shade900`
- Content:
  - Admin Avatar (circular icon).
  - Admin Display Name.
  - Email Address.
  - "ADMINISTRATOR" badge (amber/white).

### Drawer Menu Items:
- **Quản lý thể loại** (Category Management): Routes to `CategoryAdminScreen`.
- **Hồ sơ cá nhân** (Personal Profile): Routes to `ProfileScreen`.
- **Đăng xuất** (Sign Out): Triggers confirmation dialog and logs out.

---

## 3. Implementation Plan Details

### 3.1 HomeScreen Integration
We will update `home_screen.dart` to watch `userProfileProvider`.
- If the current user has `role == 'admin'`, set `drawer` property of the `Scaffold` to our new `AdminDrawer` widget.
- If not, keep `drawer: null`.

---

## 4. Verification Plan

### Automated Tests
Verify that the `HomeScreen` tests compile and pass. Add widget tests verifying that the drawer hamburger icon is visible when the user is an Admin, and absent when they are a normal user.

### Manual Verification
1. Log in as a normal user. Verify the `HomeScreen` has no hamburger icon.
2. Log in as an Admin user. Verify the hamburger icon is visible.
3. Tap the icon, confirm the Left Drawer opens with a premium dark slate dashboard look.
4. Click "Quản lý thể loại", verify it navigates to the admin category management page.
