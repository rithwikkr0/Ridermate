# Quick Start Guide - RiderMate Authentication System

## Overview
This guide will help you quickly set up and test the newly implemented authentication system.

## Prerequisites
```bash
# Install Flutter (if not already installed)
# Visit: https://docs.flutter.dev/get-started/install

# Install Firebase CLI
npm install -g firebase-tools

# Install FlutterFire CLI
dart pub global activate flutterfire_cli
```

## 5-Minute Setup

### Step 1: Firebase Project Setup (2 minutes)
1. Go to https://console.firebase.google.com/
2. Click "Add project" or select existing project
3. Enable the following:
   - **Authentication** → Sign-in method → Email/Password (Enable)
   - **Authentication** → Sign-in method → Google (Enable)
   - **Firestore Database** → Create database (Start in production mode)
   - **Storage** → Get started

### Step 2: Configure FlutterFire (1 minute)
```bash
cd /home/runner/work/Ridermate/Ridermate/ridermate_app

# Login to Firebase
firebase login

# Configure FlutterFire
flutterfire configure
# Select your Firebase project when prompted
# This creates firebase_options.dart automatically
```

### Step 3: Deploy Security Rules (1 minute)
```bash
# Initialize Firebase (if not done)
firebase init

# When prompted, select:
# - Firestore
# - Storage

# Use existing files:
# - firestore.rules (already created)
# - storage.rules (already created)

# Deploy rules
firebase deploy --only firestore:rules
firebase deploy --only storage:rules
```

### Step 4: Install Dependencies & Run (1 minute)
```bash
# Install Flutter packages
flutter pub get

# Run the app
flutter run
# Or for web:
# flutter run -d chrome
# Or for specific device:
# flutter devices  # List devices
# flutter run -d <device_id>
```

## Testing the System

### 1. Sign Up Test (30 seconds)
1. App opens → Shows LoginPage
2. Click "Sign Up"
3. Enter:
   - Name: Test User
   - Email: test@example.com
   - Password: Test1234
   - Confirm Password: Test1234
4. Check "Terms and Conditions"
5. Click "Sign Up"
6. ✅ Should show email verification notice
7. ✅ Check Firebase Console → Authentication → Users

### 2. Login Test (30 seconds)
1. Enter same credentials
2. Click "Sign In"
3. ✅ Should redirect to HomeScreen
4. ✅ Profile icon appears in top-right

### 3. Profile Test (30 seconds)
1. Click profile icon
2. ✅ See your name, email, stats
3. Click "Edit Profile"
4. Change name to "Updated Name"
5. Click "Save"
6. ✅ Changes saved

### 4. Settings Test (30 seconds)
1. Click Settings icon
2. Change theme to "light"
3. Toggle email notifications
4. ✅ Settings saved

### 5. Google Sign-In Test (30 seconds)
1. Logout
2. Click "Sign in with Google"
3. Select Google account
4. ✅ Should sign in and create profile

## File Structure Quick Reference

```
ridermate_app/
├── lib/
│   ├── models/              # Data models
│   ├── services/            # Business logic
│   ├── screens/             # UI pages
│   ├── guards/              # Route protection
│   ├── utils/               # Utilities
│   └── main.dart            # Entry point
├── firestore.rules          # Database security
├── storage.rules            # Storage security
├── FIREBASE_SETUP.md        # Detailed setup guide
├── AUTH_README.md           # System documentation
└── VALIDATION.md            # Testing guide
```

## Common Commands

```bash
# Check dependencies
flutter doctor

# Install packages
flutter pub get

# Run app
flutter run

# Build for production
flutter build apk          # Android
flutter build ios          # iOS
flutter build web          # Web

# Analyze code
flutter analyze

# Check for updates
flutter pub outdated
```

## Troubleshooting

### "Firebase not initialized"
→ Run `flutterfire configure`

### "Google Sign-In not working"
→ Check platform-specific setup in FIREBASE_SETUP.md

### "Permission denied in Firestore"
→ Deploy security rules: `firebase deploy --only firestore:rules`

### "Image upload fails"
→ Deploy storage rules: `firebase deploy --only storage:rules`

### "Dependencies not found"
→ Run `flutter pub get`

## Quick Feature Overview

### ✅ Authentication
- Email/Password
- Google Sign-In  
- Anonymous
- Password Reset
- Email Verification

### ✅ Profile Management
- View profile
- Edit profile
- Upload photo
- Update privacy

### ✅ Settings
- Account (password, email)
- Privacy (visibility, sharing)
- Notifications
- Preferences (theme, language, units)
- Delete account

## Important Files

1. **main.dart** - App entry, Firebase initialization
2. **auth_provider.dart** - State management
3. **authentication_service.dart** - Auth operations
4. **user_profile_service.dart** - Database operations
5. **login_page.dart** - Login UI
6. **signup_page.dart** - Registration UI
7. **user_profile_page.dart** - Profile display
8. **settings_page.dart** - Settings UI

## Security Rules Deployment

```bash
# View current rules
firebase firestore:rules get
firebase storage:rules get

# Deploy rules
firebase deploy --only firestore:rules
firebase deploy --only storage:rules

# Validate rules (optional)
firebase firestore:rules validate
```

## Firebase Console Quick Links

- Authentication: `console.firebase.google.com/project/YOUR_PROJECT/authentication`
- Firestore: `console.firebase.google.com/project/YOUR_PROJECT/firestore`
- Storage: `console.firebase.google.com/project/YOUR_PROJECT/storage`
- Settings: `console.firebase.google.com/project/YOUR_PROJECT/settings`

## Support & Documentation

- **Detailed Setup**: See FIREBASE_SETUP.md
- **System Docs**: See AUTH_README.md
- **Testing Guide**: See VALIDATION.md
- **Flutter Docs**: https://docs.flutter.dev
- **Firebase Docs**: https://firebase.google.com/docs

## Success Checklist

- [ ] Firebase project created
- [ ] FlutterFire configured
- [ ] Security rules deployed
- [ ] Dependencies installed
- [ ] App runs successfully
- [ ] Can sign up
- [ ] Can log in
- [ ] Can view profile
- [ ] Can edit profile
- [ ] Can access settings

---

**Need Help?** Check the detailed guides in:
- `FIREBASE_SETUP.md` - Complete setup instructions
- `AUTH_README.md` - System documentation
- `VALIDATION.md` - Comprehensive testing guide
