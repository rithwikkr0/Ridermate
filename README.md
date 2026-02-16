# Ridermate
RiderMate cycling &amp; ride tracking app

## Features

### Ride Tracking
- Live ride tracking with GPS
- Real-time speed monitoring
- Distance and duration tracking
- Safety score calculation
- Overspeed detection and warnings

### Ride History & Analytics
- **Comprehensive Ride History**: View all past rides with detailed metrics
- **Advanced Filtering**: Filter rides by date range, distance, safety score, time of day, and terrain
- **Sorting Options**: Sort by date, distance, safety score, or speed
- **Detailed Ride View**: See full ride information including:
  - Route map with GPS coordinates
  - Complete metrics breakdown
  - AI-powered ride analysis
  - Safety score with visualization
  - Weather conditions
  - Associated memories and friends

### Analytics & Statistics
- **Performance Analytics**: Track your progress over time
- **Multiple Time Periods**: View data for 7 days, 30 days, 90 days, 1 year, or all-time
- **Visual Charts**:
  - Distance per week (line chart)
  - Rides per week (bar chart)
  - Safety score trend (line chart)
  - Day of week distribution (heatmap)
  - Time of day distribution (pie chart)
  - Terrain distribution (pie chart)
- **Performance Trends**: See if you're improving or declining in various metrics
- **Comparison vs Previous Period**: Track improvement percentage

### Overall Statistics
- Total rides and distance
- Total time spent riding
- Average speed and safety score
- Best and worst records
- Most common riding patterns

### Data Management
- **Export Options**: Export ride data to CSV or JSON format
- **Ride Comparison**: Compare two rides side-by-side
- **Shareable Stats**: Generate text summaries of your riding statistics

### Social Features
- Friends tracking and location sharing
- Ride memories with photos and notes
- Privacy controls (public, friends, private)

### Safety Features
- Real-time speed limit warnings
- SOS emergency alerts
- Safety score calculation
- AI-powered safety analysis

## Technology Stack
- **Framework**: Flutter/Dart
- **Charts**: fl_chart for data visualization
- **Storage**: SharedPreferences for local data persistence
- **Date Handling**: intl package
- **Data Export**: csv package

## Project Structure
```
lib/
├── models/          # Data models
│   ├── ride.dart
│   ├── ride_stats.dart
│   ├── analytics_data.dart
│   └── ride_filter.dart
├── services/        # Business logic
│   ├── ride_history_service.dart
│   ├── analytics_service.dart
│   └── data_export_service.dart
├── widgets/         # Reusable UI components
│   ├── ride_history_list.dart
│   ├── ride_detail.dart
│   ├── ride_stats.dart
│   ├── ride_filter_widget.dart
│   └── ride_comparison.dart
├── pages/           # Full screen pages
│   └── ride_analytics_page.dart
└── main.dart        # App entry point
```

## Getting Started

### Prerequisites
- Flutter SDK 3.10.1 or higher
- Dart SDK 3.10.1 or higher

### Installation
1. Clone the repository
2. Navigate to the `ridermate_app` directory
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the app

### Building
- Android: `flutter build apk --release`
- iOS: `flutter build ios --release`

## License
Private project - not for public distribution
