# 🚴 RiderMate — Cycling & Ride Tracking App

<p align="center">
  <img src="ridermate_app/assets/logo/icon.png" alt="RiderMate Logo" width="120"/>
</p>

<p align="center">
  <strong>Track rides. Earn points. Stay safe. Share memories.</strong><br/>
  A cross-platform Flutter app for cyclists who want more than just a stopwatch.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter" />
  <img src="https://img.shields.io/badge/Dart-3.10+-0175C2?logo=dart" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-blueviolet" />
  <img src="https://img.shields.io/badge/CI-GitHub%20Actions-2088FF?logo=github-actions" />
  <img src="https://img.shields.io/badge/License-MIT-green" />
</p>

---

## 📋 Table of Contents

1. [Project Overview](#-project-overview)
2. [Features](#-features)
3. [Architecture](#-architecture)
4. [Tech Stack](#-tech-stack)
5. [Installation](#-installation)
6. [Usage](#-usage)
7. [Configuration](#-configuration)
8. [Folder Structure](#-folder-structure)
9. [Screens & UI](#-screens--ui)
10. [Future Improvements](#-future-improvements)
11. [Contributing](#-contributing)
12. [License](#-license)

---

## 🌟 Project Overview

**RiderMate** is a Flutter-based mobile (and web/desktop) application designed for cycling enthusiasts. It provides real-time ride tracking with simulated GPS data, a gamified points system, social features for connecting with friends, an SOS emergency alert system, and a "Memories" feature to geo-tag special moments during a ride.

The app is built entirely in Dart/Flutter with a dark, high-contrast UI theme, targeting Android as its primary platform (with CI that auto-builds a release APK). It is structured as an early-stage prototype — all data is currently in-memory/simulated, with clear placeholders for backend and map integration.

---

## ✨ Features

### 🏠 Home Screen (4 Tabs)

| Tab | Description |
|-----|-------------|
| **Today** | Shows today's distance, a large "Start Ride" CTA, quick stats (avg speed, max speed, calories), and a referral code panel |
| **History** | Lists past rides with distance, duration, and points earned |
| **Friends** | Live map placeholder + scrollable friends list with real-time status indicators |
| **Memories** | Geo-tagged location memories with privacy controls (Public 🌍 / Friends 👥 / Private 🔒) and a like counter |

### 🚀 Active Ride Screen

- **Live HUD** — Real-time speed, distance, and elapsed time overlay on a map canvas
- **Simulated GPS** — Speed fluctuates using a sine wave + random noise (ready for real GPS integration)
- **Speed Warning Banner** — Flashes a red alert when current speed exceeds the configured limit (default 60 km/h)
- **Memory Capture** — Mid-ride dialog to drop a text note + photo stub at the current location
- **SOS Button** — Prominent red emergency button that simulates sending an alert with GPS coordinates to contacts
- **Music Button** — Stub for in-ride music controls
- **End Ride** — Stops the timer, saves the ride, awards points, and navigates back

### 🏅 Gamification
- Distance-based points: `distance km × 10 = pts`
- Referral system with bonus points per referred friend
- Running total displayed prominently in the app header

---

## 🏗 Architecture

RiderMate currently follows a **single-file monolithic** Flutter architecture (all code in `main.dart`). For the current prototype scale, this is intentional and functional. The conceptual layers are:

```
┌────────────────────────────────────────────────────┐
│                   Presentation Layer                │
│   HomeScreen (StatefulWidget, 4-tab navigator)      │
│   RideScreen (StatefulWidget, live HUD overlay)     │
├────────────────────────────────────────────────────┤
│                   State Management                  │
│   Local setState() — ephemeral in-memory state      │
│   Timer (dart:async) — 1-second ride loop           │
├────────────────────────────────────────────────────┤
│                   Data Models                       │
│   RideHistory  (name, distance, duration, date)     │
│   Memory       (name, lat, lon, note, privacy, likes│
├────────────────────────────────────────────────────┤
│               Platform / Native Layer               │
│   Android  ·  iOS  ·  Web  ·  Windows  ·  Linux    │
│              (Flutter multi-platform targets)       │
└────────────────────────────────────────────────────┘
```

> **Design note:** For production, a clean separation into `models/`, `screens/`, `widgets/`, `services/`, and `providers/` is strongly recommended. See [Future Improvements](#-future-improvements).

---

## 🛠 Tech Stack

| Layer | Technology |
|-------|-----------|
| **UI Framework** | Flutter 3.x (Material 3) |
| **Language** | Dart 3.10+ |
| **State Management** | `setState` (local, ephemeral) |
| **Async / Timer** | `dart:async` — `Timer.periodic` |
| **Math / Simulation** | `dart:math` — `sin`, `Random` |
| **CI/CD** | GitHub Actions — builds release APK on every push |
| **Linting** | `flutter_lints ^6.0.0` |
| **Icons** | Flutter Material Icons + Cupertino Icons |
| **Target Platforms** | Android (primary), iOS, Web, Windows, macOS, Linux |

---

## 📦 Installation

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) **3.x or later** (tested with `3.38.3`)
- Dart SDK `^3.10.1` (bundled with Flutter)
- Android Studio / Xcode (for emulator/device testing)
- A connected Android device or emulator for the APK build

### Steps

```bash
# 1. Clone the repository
git clone https://github.com/rithwikkr0/Ridermate.git
cd Ridermate/ridermate_app

# 2. Fetch dependencies
flutter pub get

# 3. Run on a connected device or emulator
flutter run

# 4. (Optional) Build a release APK
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Web

```bash
flutter run -d chrome
```

### Desktop (Linux/Windows/macOS)

```bash
flutter run -d linux     # or windows / macos
```

---

## 🖥 Usage

1. **Launch the app** — you land on the **Today** tab.
2. Tap **🚀 START RIDE** to enter the active Ride Screen.
3. Watch live speed, distance, and elapsed time update every second.
4. Use the bottom bar during a ride:
   - 📷 **Memory** — drop a geo-tagged note
   - 🎵 **Music** — (placeholder)
   - 🆘 **SOS** — sends simulated emergency alert
   - 👥 **Friends** — (placeholder live view)
   - ⏹ **End Ride** — saves and awards points
5. Return to **History** tab to see past rides.
6. Check **Memories** tab to browse saved geo-tagged moments.
7. Share your referral code from the **Today** tab to earn bonus points.

---

## ⚙️ Configuration

Currently all configuration is hard-coded in `main.dart`. Key values to customize:

| Variable | Location | Default | Description |
|----------|----------|---------|-------------|
| `speedLimit` | `_RideScreenState` | `60.0` | Speed (km/h) above which warning triggers |
| `points` | `_HomeScreenState` | `1250` | Initial points balance |
| `todayDistance` | `_HomeScreenState` | `23.5` | Seed distance shown on Today tab |
| Referral code | `_buildTodayTab()` | `RIDER2025XYZ` | Static referral code string |
| Theme colors | `RiderMateApp.build()` | `#0066FF`, `#FF6B35` | Primary blue & accent orange |

> **For production:** Move these into a `Config` class, environment variables, or a remote config service (e.g. Firebase Remote Config).

---

## 📁 Folder Structure

```
Ridermate/
├── .github/
│   └── workflows/
│       └── build.yml              # CI: builds release APK on every push
│
└── ridermate_app/                 # Flutter project root
    ├── assets/
    │   └── logo/
    │       └── icon.png           # App icon
    │
    ├── lib/
    │   └── main.dart              # ⚠️ Entire app — all screens, models, widgets
    │
    ├── test/
    │   └── widget_test.dart       # Default Flutter widget smoke test (needs update)
    │
    ├── android/                   # Android platform project
    ├── ios/                       # iOS platform project
    ├── web/                       # Web platform project
    ├── linux/                     # Linux desktop project
    ├── windows/                   # Windows desktop project
    ├── macos/                     # macOS desktop project
    │
    ├── pubspec.yaml               # Dependencies & Flutter config
    ├── pubspec.lock               # Locked dependency versions
    ├── analysis_options.yaml      # Linting rules
    └── README.md                  # Default Flutter README (placeholder)
```

---

## 📸 Screens & UI

> **Note:** Add real screenshots here by running the app and capturing the device display.

| Screen | Description |
|--------|-------------|
| `Home → Today` | Dark-theme dashboard with distance card, START RIDE button, stats row, referral panel |
| `Home → History` | Scrollable list of past ride cards with distance, duration, and earned points |
| `Home → Friends` | Map placeholder + avatar list with live indicators |
| `Home → Memories` | Privacy-tagged memory cards with coordinates and like counts |
| `Ride Screen` | Full-screen map canvas + HUD overlay + bottom action bar |
| `Ride → SOS Dialog` | Red emergency dialog with simulated location coordinates |
| `Ride → Memory Dialog` | Text input + photo stub for mid-ride geo-tagging |

---

## 🔮 Future Improvements

### High Priority
- [ ] **Real GPS integration** — Replace simulated speed/distance with `geolocator` package for actual GPS tracking
- [ ] **Google Maps / Mapbox** — Render a real map tile layer in `RideScreen` instead of the placeholder text
- [ ] **Backend & Auth** — Add Firebase Auth + Firestore (or Supabase) to persist rides, memories, and user profiles
- [ ] **State Management** — Migrate to `Riverpod`, `Bloc`, or `Provider` to remove scattered `setState` calls

### Medium Priority
- [ ] **Split `main.dart`** — Refactor into proper folder structure: `screens/`, `widgets/`, `models/`, `services/`
- [ ] **Fix widget test** — `widget_test.dart` references `MyApp` which doesn't exist; update to test `RiderMateApp`
- [ ] **Publish assets** — Register `assets/logo/icon.png` in `pubspec.yaml` so it loads at runtime
- [ ] **Real SOS** — Integrate SMS/push-notification service (Twilio, FCM) for actual emergency alerts
- [ ] **Music integration** — Connect the music button to `just_audio` or a system media intent

### Quality of Life
- [ ] **Dark/Light theme toggle**
- [ ] **Localization / i18n** support
- [ ] **Ride route polyline** — Draw the GPS path on the map after a ride
- [ ] **Leaderboard** — Compare points with friends
- [ ] **Elevation tracking** — Add altitude data from GPS
- [ ] **Bluetooth sensor support** — Heart rate monitors, cadence sensors (via `flutter_blue_plus`)

---

## 🤝 Contributing

Contributions are welcome! Here's how to get started:

1. **Fork** the repository on GitHub
2. **Clone** your fork: `git clone https://github.com/<your-username>/Ridermate.git`
3. **Create a branch**: `git checkout -b feature/your-feature-name`
4. **Make your changes** — keep commits atomic and well-described
5. **Run lints**: `flutter analyze`
6. **Run tests**: `flutter test`
7. **Push** your branch and open a **Pull Request** against `main`

### Code Style
- Follow the [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Keep widgets small and composable — extract reusable pieces into `lib/widgets/`
- Prefer named constructors and `const` widgets where possible

### Reporting Issues
Open a GitHub Issue with:
- Steps to reproduce
- Expected vs actual behaviour
- Flutter version (`flutter --version`)
- Device / OS details

---

## 📄 License

This project is licensed under the **MIT License**.

```
MIT License

Copyright (c) 2025 rithwikkr0

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
```

---

<p align="center">
  Built with ❤️ using Flutter · <a href="https://github.com/rithwikkr0/Ridermate">github.com/rithwikkr0/Ridermate</a>
</p>
