# Spec: GitHub Actions Deployment for Flutter Web (mobile_app)

This spec outlines the process of configuring automatic build and deployment of the Flutter Web application to Firebase Hosting on git push to the main branch.

## Scope & Goal
Set up a CI/CD pipeline using GitHub Actions to compile the Flutter Web target and deploy it to the Firebase project `trippo-73fd7`.

## Proposed Workflows

### 1. Deploy on Merge/Push
- File: `.github/workflows/firebase-hosting-merge.yml`
- Triggers: On push to branch `main`.
- Actions:
  - Check out code.
  - Setup Flutter (stable channel).
  - Prepare `env.json` by copying `env.json.example`.
  - Build Flutter web target (`flutter build web`).
  - Deploy to Firebase Hosting using `FIREBASE_SERVICE_ACCOUNT_TRIPPO_73FD7`.

### 2. Deploy on Pull Request
- File: `.github/workflows/firebase-hosting-pull-request.yml`
- Triggers: On pull request to branch `main`.
- Actions:
  - Same compile steps as above.
  - Deploy preview channel to Firebase Hosting.

## GitHub Secret Configuration
Ensure the repository has the secret `FIREBASE_SERVICE_ACCOUNT_TRIPPO_73FD7` set with the Firebase Service Account JSON key.
