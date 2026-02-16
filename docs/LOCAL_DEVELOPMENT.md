# Local Development Setup Guide

## Prerequisites

### Install Flutter
1. Download Flutter SDK from https://flutter.dev/docs/get-started/install
2. Extract to a location (e.g., `C:\src\flutter` on Windows or `~/development/flutter` on macOS/Linux)
3. Add Flutter to your PATH
4. Run `flutter doctor` to verify installation

### Install Git
Download and install from https://git-scm.com/downloads

### Install an IDE
Choose one:
- **Visual Studio Code** (recommended) with Flutter extension
- **Android Studio** with Flutter plugin
- **IntelliJ IDEA** with Flutter plugin

## Setup Steps

### 1. Clone the Repository
```bash
git clone https://github.com/rithwikkr0/Ridermate.git
cd Ridermate
```

### 2. Configure Environment
```bash
# Copy environment template
cp .env.example .env.development

# Edit .env.development with your configuration
nano .env.development  # or use your preferred editor
```

### 3. Install Dependencies
```bash
cd ridermate_app
flutter pub get
```

### 4. Run the Application

#### Web
```bash
flutter run -d chrome
# or
flutter run -d web-server --web-port=8080
```

#### Android
```bash
# Connect an Android device or start an emulator
flutter run -d android
```

#### iOS (macOS only)
```bash
flutter run -d ios
```

#### All Platforms
```bash
flutter run
# Then select the device from the list
```

## Docker Development Environment

### Using Docker Compose
```bash
# Start development environment
docker-compose --profile dev up

# The app will be available at http://localhost:8080
```

### Manual Docker Build
```bash
# Build the Docker image
docker build -t ridermate-dev .

# Run with volume mount for hot reload
docker run -p 8080:8080 \
  -v $(pwd)/ridermate_app:/app \
  ridermate-dev
```

## Development Workflow

### Code Changes
1. Make changes to files in `ridermate_app/lib/`
2. Hot reload in running app (press `r` in terminal)
3. Hot restart if needed (press `R` in terminal)

### Adding Dependencies
```bash
# Add to pubspec.yaml, then run:
flutter pub get
```

### Running Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

### Code Formatting
```bash
# Format all Dart files
dart format .

# Check formatting
dart format --output=none --set-exit-if-changed .
```

### Code Analysis
```bash
# Analyze code
flutter analyze

# Fix common issues
dart fix --apply
```

## IDE Configuration

### Visual Studio Code

#### Recommended Extensions
- Flutter
- Dart
- Dart Data Class Generator
- Flutter Widget Snippets
- Error Lens
- GitLens

#### Launch Configuration (.vscode/launch.json)
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter (Development)",
      "request": "launch",
      "type": "dart",
      "args": [
        "--dart-define=ENVIRONMENT=development"
      ]
    },
    {
      "name": "Flutter (Web)",
      "request": "launch",
      "type": "dart",
      "args": [
        "-d",
        "chrome",
        "--web-port=8080"
      ]
    }
  ]
}
```

### Android Studio

1. Open the project
2. Wait for Gradle sync
3. Select device from dropdown
4. Click Run button

## Troubleshooting

### Flutter Doctor Issues
```bash
# Run flutter doctor to see issues
flutter doctor -v

# Accept Android licenses
flutter doctor --android-licenses
```

### Dependency Issues
```bash
# Clean and reinstall
flutter clean
flutter pub get
```

### Build Issues
```bash
# For Android
cd android
./gradlew clean
cd ..
flutter build apk

# For iOS
cd ios
pod install
cd ..
flutter build ios
```

### Hot Reload Not Working
1. Save the file
2. Press `r` in terminal
3. If that doesn't work, press `R` for full restart
4. If still not working, stop and restart `flutter run`

## Environment Variables

Create `.env.development` with:
```env
APP_ENV=development
ENABLE_DEBUG_MODE=true
API_BASE_URL=http://localhost:3000/api
MOCK_LOCATION_DATA=true
```

## Database Setup (if using Firebase)

1. Create a Firebase project at https://console.firebase.google.com
2. Add your app to the project
3. Download configuration files:
   - `google-services.json` for Android → `android/app/`
   - `GoogleService-Info.plist` for iOS → `ios/Runner/`
4. Update `.env.development` with Firebase credentials

## API Development (if backend exists)

If you're developing with a local backend:
```bash
# Update API_BASE_URL in .env.development
API_BASE_URL=http://localhost:3000/api

# Or use ngrok for mobile testing
ngrok http 3000
# Update API_BASE_URL with ngrok URL
```

## Tips for Productive Development

1. **Use Hot Reload**: Save time by using hot reload instead of full rebuilds
2. **Widget Inspector**: Use Flutter DevTools for debugging UI
3. **Performance Overlay**: Enable with `flutter run --profile`
4. **Logging**: Use `debugPrint()` instead of `print()`
5. **Breakpoints**: Use IDE debugger with breakpoints
6. **Git Hooks**: Set up pre-commit hooks for formatting and linting

## Common Commands

```bash
# Create new widget
flutter create --template=package my_widget

# Update Flutter
flutter upgrade

# Clear cache
flutter clean

# Build for release
flutter build apk --release
flutter build ios --release
flutter build web --release

# Generate icons
flutter pub run flutter_launcher_icons:main

# Generate splash screens
flutter pub run flutter_native_splash:create
```

## Next Steps

- Review [CI/CD Documentation](CI_CD.md)
- Check [Deployment Guide](DEPLOYMENT.md)
- Read [Troubleshooting Guide](TROUBLESHOOTING.md)
