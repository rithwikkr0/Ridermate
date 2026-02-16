# Firebase Configuration Instructions

This file contains instructions for setting up Firebase for the RiderMate app.

## Prerequisites
1. Create a Firebase project at https://console.firebase.google.com/
2. Install Firebase CLI: `npm install -g firebase-tools`
3. Install FlutterFire CLI: `dart pub global activate flutterfire_cli`

## Setup Steps

### 1. Initialize Firebase in your project
```bash
cd ridermate_app
firebase login
firebase init
```

Select the following when prompted:
- Firestore
- Storage
- Authentication

### 2. Configure FlutterFire
```bash
flutterfire configure
```

This will:
- Create firebase_options.dart in lib/
- Configure Firebase for all platforms (iOS, Android, Web, etc.)

### 3. Enable Authentication Methods
1. Go to Firebase Console > Authentication > Sign-in method
2. Enable the following providers:
   - Email/Password
   - Google Sign-In
   - Anonymous (optional)

### 4. Configure Google Sign-In (Android)
1. Download google-services.json from Firebase Console
2. Place it in: ridermate_app/android/app/
3. Update android/build.gradle:
```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.3.15'
}
```
4. Update android/app/build.gradle:
```gradle
apply plugin: 'com.google.gms.google-services'
```

### 5. Configure Google Sign-In (iOS)
1. Download GoogleService-Info.plist from Firebase Console
2. Place it in: ridermate_app/ios/Runner/
3. Update ios/Runner/Info.plist with reversed client ID

### 6. Deploy Security Rules
```bash
# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Storage rules
firebase deploy --only storage:rules
```

### 7. Create Firestore Indexes (if needed)
Some complex queries may require indexes. Firebase will prompt you with a link to create them when needed.

## Collections Structure

### users/
- userId (document ID)
- email, name, profilePhoto, bio, phoneNumber
- privacyMode, totalDistance, totalRides, totalPoints, safetyScore
- createdAt, updatedAt, lastLoginAt

### user_settings/
- userId (document ID)
- notifications, theme, language, units
- emailNotifications, pushNotifications
- updatedAt

### user_privacy/
- userId (document ID)
- profileVisibility, locationSharing
- friendRequestSettings, blockList
- updatedAt

## Environment Variables
Create a .env file in ridermate_app/ with:
```
FIREBASE_API_KEY=your_api_key
FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_STORAGE_BUCKET=your_project.appspot.com
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_APP_ID=your_app_id
```

## Testing
1. Run the app: `flutter run`
2. Try signing up with email/password
3. Try Google Sign-In
4. Verify data appears in Firebase Console

## Security Notes
- Email verification is required for full access
- Passwords must be minimum 8 characters with uppercase, lowercase, and number
- Rate limiting is enforced by Firebase Authentication
- All sensitive data is protected by security rules
- User can only read/write their own data
