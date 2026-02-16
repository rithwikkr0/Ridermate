# RiderMate
RiderMate cycling & ride tracking app

## 🆕 New Feature: Memory/Journal System

RiderMate now includes a comprehensive Memory/Journal System that allows cyclists to capture and share their riding experiences with photos, locations, and social features.

### Quick Links
- **[Memory System Documentation](MEMORY_SYSTEM_README.md)** - Complete feature overview
- **[Setup Guide](SETUP_GUIDE.md)** - Step-by-step installation instructions  
- **[Implementation Summary](IMPLEMENTATION_SUMMARY.md)** - Technical details

### Key Features
- 📸 **Photo Memories**: Capture moments with camera or gallery
- 📍 **Location Tagging**: Auto GPS tagging with map view
- 🔒 **Privacy Controls**: Public, Friends, or Private visibility
- ❤️ **Social Features**: Likes, views, and friends feed
- 🗺️ **Interactive Maps**: See all memories on Google Maps
- 📱 **Cross-Platform**: iOS and Android support

### Getting Started

1. **Install Dependencies**
   ```bash
   cd ridermate_app
   flutter pub get
   ```

2. **Configure Firebase** (See [Setup Guide](SETUP_GUIDE.md))
   - Create Firebase project
   - Add `google-services.json` (Android)
   - Add `GoogleService-Info.plist` (iOS)
   - Enable Firestore and Storage

3. **Configure Google Maps** (See [Setup Guide](SETUP_GUIDE.md))
   - Get API key
   - Add to `AndroidManifest.xml` and iOS config

4. **Run the App**
   ```bash
   flutter run
   ```

### Project Structure
```
ridermate_app/
├── lib/
│   ├── models/          # Data models
│   ├── services/        # Business logic services
│   ├── screens/         # UI screens
│   ├── widgets/         # Reusable widgets
│   └── utils/           # Utility functions
├── android/             # Android platform code
├── ios/                 # iOS platform code
└── pubspec.yaml         # Dependencies
```

### Technologies Used
- **Flutter** - Cross-platform mobile framework
- **Firebase** - Backend services (Firestore, Storage, Auth)
- **Google Maps** - Interactive maps
- **Provider** - State management
- **Image Compression** - Optimized photo uploads

### Documentation
- [Memory System Features](MEMORY_SYSTEM_README.md)
- [Setup Instructions](SETUP_GUIDE.md)  
- [Implementation Details](IMPLEMENTATION_SUMMARY.md)

### Support
For issues or questions, please refer to the documentation or create an issue in the repository.

### License
See repository for license information.
