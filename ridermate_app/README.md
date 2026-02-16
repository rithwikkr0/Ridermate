# RiderMate App

A Flutter-based cycling & ride tracking app with AI-powered companion features.

## Quick Start

### Prerequisites
- Flutter SDK 3.10.1+
- Dart SDK
- OpenAI API key (optional - demo mode available without it)

### Setup

1. **Install dependencies**
   ```bash
   flutter pub get
   ```

2. **Configure environment (optional for AI features)**
   ```bash
   cp .env.example .env
   # Edit .env and add your OpenAI API key
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## Features

### AI-Powered Features
- 🤖 **AI Chat Companion**: Get personalized cycling advice
- 📊 **Ride Analysis**: AI-powered safety scoring and feedback
- 📈 **Weekly Summaries**: Intelligent performance tracking
- 🎯 **Safety Scoring**: Advanced safety metrics (0-100)

### Core Features
- 🚴 Real-time ride tracking
- 📍 Location memories
- 👥 Friends tracking
- 🏆 Points & rewards
- 📱 Referral system

## Project Structure

```
lib/
├── main.dart              # App entry & UI
├── models/                # Data models
├── services/              # Business logic & AI
└── widgets/               # Reusable components
```

## Testing

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/widget_test.dart
```

## Building

```bash
# Build for Android
flutter build apk

# Build for iOS
flutter build ios

# Build for Web
flutter build web
```

## Environment Variables

Create a `.env` file with:
```
OPENAI_API_KEY=your_key_here
OPENAI_MODEL=gpt-3.5-turbo
```

**Note**: The app works in demo mode without an API key, using built-in mock responses.

## Documentation

See the [main README](../README.md) for detailed feature documentation.

## License

MIT License - See LICENSE file for details.
