# RiderMate
RiderMate cycling & ride tracking app with AI-powered companion

## Features

### Core Features
- 🚴 **Real-time Ride Tracking**: Track your speed, distance, and duration in real-time
- 📊 **Ride History**: View all your past rides with detailed statistics
- 👥 **Friends & Social**: Connect with friends and see their location on the map
- 📍 **Location Memories**: Save and share memorable spots from your rides
- 🏆 **Points & Rewards**: Earn points based on distance and performance
- 👨‍👩‍👧‍👦 **Referral System**: Invite friends and earn bonus points

### AI Companion Features (NEW! 🤖)

#### 1. **AI Ride Analysis**
After completing a ride, receive comprehensive AI-powered analysis including:
- **Safety Score (0-100)**: Calculated based on:
  - Speed consistency
  - Overspeed events
  - Ride stability/smoothness
- **Performance Feedback**: Detailed analysis of your ride performance
- **Strengths & Improvements**: What you did well and where to improve
- **Actionable Suggestions**: Specific tips to enhance your cycling

#### 2. **AI Chat Companion**
Talk to your personal cycling AI assistant:
- Ask "How was my ride?" for instant feedback
- Get personalized safety tips for city traffic
- Receive coaching advice based on your ride history
- Context-aware responses using your ride data
- Persistent message history

#### 3. **Weekly Analysis**
Get AI-generated weekly summaries featuring:
- Total distance and ride count
- Average safety score trends
- Week-over-week performance comparison
- Points earned
- Consistency metrics
- Encouraging feedback and improvement areas

#### 4. **Enhanced Ride History**
View your ride history with AI insights:
- Safety score for each ride
- Quick AI insights and recommendations
- Overspeed warnings
- Trend visualization
- Comparative analysis across rides

## Setup

### Prerequisites
- Flutter SDK (3.10.1 or higher)
- Dart SDK
- OpenAI API key (for AI features)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/rithwikkr0/Ridermate.git
   cd Ridermate/ridermate_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure OpenAI API** (for AI features)
   - Copy `.env.example` to `.env`
   - Add your OpenAI API key:
     ```
     OPENAI_API_KEY=your_api_key_here
     OPENAI_MODEL=gpt-3.5-turbo
     ```

4. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                          # Main app entry point
├── models/                            # Data models
│   ├── ai_analysis.dart              # AI analysis result model
│   ├── chat_message.dart             # Chat message model
│   ├── ride_metrics.dart             # Ride metrics model
│   └── weekly_analysis.dart          # Weekly summary model
├── services/                          # Business logic services
│   ├── ai_analysis_service.dart      # AI analysis & safety scoring
│   ├── chat_service.dart             # Chat management
│   └── openai_service.dart           # OpenAI API integration
└── widgets/                           # Reusable UI components
    ├── ai_analysis_display.dart      # Ride analysis display
    ├── ai_chat_widget.dart           # Chat interface
    ├── ride_history_with_ai.dart     # Enhanced ride history
    └── weekly_analysis_card.dart     # Weekly summary card
```

## AI Features in Detail

### Safety Score Calculation
The AI safety score is calculated using multiple factors:

1. **Speed Consistency (30 points)**: 
   - Measures variance in speed throughout the ride
   - Lower variance = higher score

2. **Overspeed Events (40 points)**:
   - Tracks instances of exceeding speed limits
   - Fewer overspeeds = higher score

3. **Speed Ratio (30 points)**:
   - Compares max speed to average speed
   - Stable ratio indicates controlled riding

### OpenAI Integration
- **Secure API calls**: All API requests go through secure backend service
- **Timeout handling**: 30-second timeout with fallback responses
- **Error handling**: Graceful degradation when API is unavailable
- **Mock responses**: Built-in demo responses for testing without API key
- **Context-aware prompts**: Personalized based on ride history

### Performance Optimization
- **Response caching**: AI responses stored in SharedPreferences
- **Lazy loading**: Chat interface loads messages on-demand
- **Minimal re-renders**: Optimized state management
- **Efficient data structures**: Lightweight models for fast processing

## Usage

### Starting a Ride
1. Tap "🚀 START RIDE" from the Today tab
2. Track your ride in real-time
3. Tap the stop button when finished
4. View AI-powered analysis of your ride

### Using AI Chat
1. Navigate to "AI Chat" tab
2. Ask questions like:
   - "How was my ride?"
   - "How can I improve my safety?"
   - "Give me tips for city traffic"
3. Receive personalized, context-aware responses

### Viewing Weekly Analysis
- Check the "Today" tab for your weekly summary card
- View total distance, rides, and safety trends
- See week-over-week performance changes

## Dependencies

### Core
- `flutter`: Flutter framework
- `cupertino_icons`: iOS-style icons

### AI Features
- `http`: HTTP client for API calls
- `flutter_dotenv`: Environment variable management
- `shared_preferences`: Local data persistence
- `intl`: Internationalization and date formatting

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License.

## Contact

For questions or support, please open an issue on GitHub.

---

Built with ❤️ using Flutter and OpenAI
