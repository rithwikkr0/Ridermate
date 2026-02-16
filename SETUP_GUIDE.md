# RiderMate Memory/Journal System - Setup Guide

## Quick Start

This guide will help you set up and run the Memory/Journal System in the RiderMate app.

## Prerequisites

- Flutter SDK (3.10.0 or higher)
- Dart SDK (included with Flutter)
- Android Studio / Xcode (for mobile development)
- Firebase account (free tier is sufficient)
- Google Cloud account (for Maps API)

## Step 1: Install Dependencies

```bash
cd ridermate_app
flutter pub get
```

## Step 2: Firebase Setup

### 2.1 Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Follow the setup wizard

### 2.2 Add Android App
1. In Firebase Console, click "Add app" → Android
2. Register app with package name from `android/app/build.gradle`
3. Download `google-services.json`
4. Place it in `android/app/google-services.json`

### 2.3 Add iOS App
1. In Firebase Console, click "Add app" → iOS
2. Register app with bundle ID from `ios/Runner.xcodeproj`
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/GoogleService-Info.plist`

### 2.4 Enable Firebase Services

In Firebase Console:

1. **Authentication**
   - Go to Authentication → Sign-in method
   - Enable Email/Password or other providers

2. **Firestore Database**
   - Go to Firestore Database
   - Click "Create database"
   - Start in test mode (update rules later)

3. **Storage**
   - Go to Storage
   - Click "Get started"
   - Start in test mode (update rules later)

### 2.5 Update Firebase Rules

Copy the security rules from `lib/firebase_config.dart` to:
- Firestore Database → Rules
- Storage → Rules

## Step 3: Google Maps Setup

### 3.1 Get API Key
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable these APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
4. Create credentials → API Key

### 3.2 Configure Android
1. Open `android/app/src/main/AndroidManifest.xml`
2. Replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` with your actual API key

### 3.3 Configure iOS
1. Open `ios/Runner/AppDelegate.swift`
2. Add the following code:

```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## Step 4: Update Firebase Initialization

In `lib/main.dart`, uncomment the Firebase initialization:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // ← Uncomment this line
  runApp(RiderMateApp());
}
```

## Step 5: Build and Run

### Android
```bash
flutter run
# or for release build
flutter build apk --release
```

### iOS
```bash
flutter run
# or for release build
flutter build ios --release
```

## Step 6: Testing the Memory System

### Test Memory Creation
1. Open the app
2. Navigate to "Memories" tab
3. Tap "Add Memory"
4. Grant camera and location permissions when prompted
5. Capture or select a photo
6. Add caption and tags
7. Select visibility level
8. Tap "Create Memory"

### Test Memory Viewing
1. Tap "Gallery" to see all your memories
2. Tap "Map" to see memories on a map
3. Tap "Feed" to see friends' memories (requires friend data)
4. Tap on any memory card to view details

### Test Memory Editing
1. Open a memory in detail view
2. Tap the menu icon (⋮)
3. Select "Edit"
4. Modify caption or visibility
5. Tap "Save"

### Test Memory Deletion
1. Open a memory in detail view
2. Tap the menu icon (⋮)
3. Select "Delete"
4. Confirm deletion

## Troubleshooting

### "Firebase not initialized" Error
- Make sure you've uncommented the Firebase initialization in `main.dart`
- Verify `google-services.json` and `GoogleService-Info.plist` are in correct locations
- Run `flutter clean` and `flutter pub get`

### "Location permission denied" Error
- Check that permissions are declared in `AndroidManifest.xml` and `Info.plist`
- Grant permissions when prompted on the device
- For Android 12+, ensure both FINE and COARSE location are requested

### "Image picker not working" Error
- Verify camera and photo library permissions are declared
- On iOS, check all NSUsageDescription strings are in `Info.plist`
- On Android, check READ_MEDIA_IMAGES permission for Android 13+

### "Map not displaying" Error
- Verify Google Maps API key is correct
- Ensure Maps SDK is enabled in Google Cloud Console
- Check that API key restrictions allow your app's package name/bundle ID

### Build Errors
- Run `flutter doctor` to check for issues
- Update Flutter: `flutter upgrade`
- Clean and rebuild: `flutter clean && flutter pub get`

## Development Workflow

1. Make code changes
2. Hot reload: Press `r` in terminal or use IDE hot reload
3. Hot restart: Press `R` for full restart
4. Check for errors: `flutter analyze`
5. Format code: `flutter format .`

## Production Checklist

Before deploying to production:

- [ ] Update Firebase security rules (no test mode)
- [ ] Enable Firebase Authentication
- [ ] Set up proper user management
- [ ] Configure API key restrictions in Google Cloud
- [ ] Test on both Android and iOS devices
- [ ] Test with poor/no network conditions
- [ ] Test with different screen sizes
- [ ] Implement analytics (Firebase Analytics)
- [ ] Set up crash reporting (Firebase Crashlytics)
- [ ] Review and accept terms for all services

## Support Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Google Maps Flutter Plugin](https://pub.dev/packages/google_maps_flutter)
- [RiderMate Memory System README](../MEMORY_SYSTEM_README.md)

## Next Steps

After basic setup works:

1. Implement user authentication
2. Add friend management system
3. Integrate with existing ride tracking
4. Add memory analytics
5. Implement push notifications
6. Add social sharing features

## License

This code is part of the RiderMate project. See main repository for license information.
