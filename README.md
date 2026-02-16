# RiderMate
RiderMate - Cycling &amp; Ride Tracking App with Complete Authentication System

## 🎯 Features

### ✅ Recently Added: Authentication & User Profile System
- **Email/Password Authentication** - Secure sign-up and login
- **Google Sign-In** - OAuth integration for easy access
- **Anonymous Mode** - Guest access option
- **Password Management** - Reset via email, strength validation
- **User Profiles** - Complete profile management with photo upload
- **Privacy Controls** - Public, Friends-Only, and Private modes
- **Comprehensive Settings** - Account, privacy, notifications, preferences
- **Firebase Integration** - Cloud Firestore, Storage, and Authentication

### 🚴 Core Features
- Live ride tracking with GPS
- Speed monitoring and alerts
- Distance and duration tracking
- Ride history and statistics
- Points and achievements system
- Friend tracking on map
- Location-based memories
- Safety features (SOS alert)

## 📱 Quick Start

### Prerequisites
- Flutter SDK 3.10.1 or higher
- Firebase account
- Android Studio / Xcode (for mobile builds)

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/rithwikkr0/Ridermate.git
   cd Ridermate/ridermate_app
   ```

2. **Configure Firebase**
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase
   flutterfire configure
   ```
   See [FIREBASE_SETUP.md](ridermate_app/FIREBASE_SETUP.md) for detailed instructions.

3. **Install Dependencies**
   ```bash
   flutter pub get
   ```

4. **Run the App**
   ```bash
   flutter run
   ```

## 📖 Documentation

Comprehensive documentation is available in the `ridermate_app/` directory:

- **[QUICK_START.md](ridermate_app/QUICK_START.md)** - 5-minute setup guide
- **[FIREBASE_SETUP.md](ridermate_app/FIREBASE_SETUP.md)** - Complete Firebase configuration
- **[AUTH_README.md](ridermate_app/AUTH_README.md)** - Authentication system documentation
- **[ARCHITECTURE.md](ridermate_app/ARCHITECTURE.md)** - System architecture and diagrams
- **[VALIDATION.md](ridermate_app/VALIDATION.md)** - Testing and validation guide
- **[IMPLEMENTATION_SUMMARY.md](ridermate_app/IMPLEMENTATION_SUMMARY.md)** - Implementation details

## 🏗️ Project Structure

```
ridermate_app/
├── lib/
│   ├── models/              # Data models
│   │   ├── user_model.dart
│   │   ├── user_settings.dart
│   │   └── privacy_settings.dart
│   ├── services/            # Business logic
│   │   ├── authentication_service.dart
│   │   ├── user_profile_service.dart
│   │   ├── privacy_service.dart
│   │   └── auth_provider.dart
│   ├── screens/             # UI pages
│   │   ├── login_page.dart
│   │   ├── signup_page.dart
│   │   ├── user_profile_page.dart
│   │   ├── edit_profile_page.dart
│   │   └── settings_page.dart
│   ├── guards/              # Route protection
│   │   └── auth_guard.dart
│   ├── utils/               # Utilities
│   │   └── validation_utils.dart
│   └── main.dart            # Entry point
├── firestore.rules          # Database security
├── storage.rules            # Storage security
└── Documentation files...
```

## 🔐 Security

- **Firebase Security Rules** - Comprehensive rules for Firestore and Storage
- **Input Validation** - Email, password, phone number validation
- **Password Requirements** - Minimum 8 characters with uppercase, lowercase, and number
- **Privacy Controls** - User-configurable privacy settings
- **Data Protection** - Users can only access their own data

## 🧪 Testing

Run the test suite:
```bash
flutter test
```

For manual testing instructions, see [VALIDATION.md](ridermate_app/VALIDATION.md).

## 🛠️ Tech Stack

- **Framework:** Flutter 3.10.1+
- **Language:** Dart
- **Backend:** Firebase (Auth, Firestore, Storage)
- **State Management:** Provider
- **Authentication:** Firebase Auth + Google Sign-In

## 📦 Dependencies

```yaml
firebase_core: ^3.8.0
firebase_auth: ^5.3.3
cloud_firestore: ^5.5.0
firebase_storage: ^12.3.6
google_sign_in: ^6.2.2
provider: ^6.1.2
image_picker: ^1.1.2
shared_preferences: ^2.3.4
intl: ^0.20.0
```

## 🚀 Deployment

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web
```

## 📝 License

This project is private and not licensed for public use.

## 👥 Contributing

This is a private project. For contributions, please contact the repository owner.

## 🤝 Support

For issues or questions:
1. Check the documentation files
2. Review Firebase Console for backend issues
3. Check Flutter logs: `flutter logs`

## 📊 Features Checklist

### Authentication ✅
- [x] Email/Password sign-up and login
- [x] Google Sign-In
- [x] Anonymous login
- [x] Password reset
- [x] Email verification
- [x] Session persistence

### User Profile ✅
- [x] Profile creation and editing
- [x] Profile photo upload
- [x] Privacy settings
- [x] User statistics
- [x] Account deletion

### Settings ✅
- [x] Account settings
- [x] Privacy controls
- [x] Notification preferences
- [x] App preferences
- [x] Theme selection

### Ride Tracking 🚧
- [x] Basic ride screen
- [ ] GPS integration
- [ ] Real-time tracking
- [ ] Route mapping

### Social Features 🚧
- [x] Friends list UI
- [ ] Friend requests
- [ ] Location sharing
- [ ] Memory sharing

---

**Last Updated:** February 16, 2026  
**Version:** 1.0.0  
**Status:** Authentication System Complete ✅

