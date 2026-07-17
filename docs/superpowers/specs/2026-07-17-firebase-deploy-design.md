# Spec: Firebase Deployment for Flutter Web

This spec outlines the process of configuring and deploying the Flutter Web application to Firebase Hosting, while ensuring all local modifications are pushed to Git first.

## Scope & Goal
Deploy the Flutter Web application to the existing Firebase project `trippo-73fd7` alongside Firestore rules and indexes. The deployment should follow a two-step Git push workflow to maintain a clean git history.

## Steps

### Step 1: Push Current Local Changes
- Identify and commit existing changes in `lib/features/products/presentation/views/product_admin_screen.dart`.
- Commit message: `fix: resolve minor parameter warning in product admin screen`.
- Push to the remote branch `main`.

### Step 2: Configure Firebase Hosting
- Modify `firebase.json` to configure Firebase Hosting pointing to the `build/web` directory:
  ```json
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
  ```

### Step 3: Build and Deploy
- Run the Flutter Web release build:
  ```bash
  flutter build web --release
  ```
- Deploy to Firebase:
  ```bash
  npx -y firebase-tools@latest deploy
  ```

### Step 4: Push Firebase Config Changes
- Commit changes made to `firebase.json`.
- Commit message: `chore: configure firebase hosting for flutter web`.
- Push to the remote branch `main`.
