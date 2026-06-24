# RiderMate Gamification System

Complete gamification system with leaderboards, points, badges, achievements, and streak tracking.

## Features Implemented

### Backend (Node.js/Express + Firebase)
- **Services**:
  - LeaderboardService - Rankings and user positions
  - PointsService - Points awarding and tracking
  - BadgeService - Badge unlock logic
  - AchievementService - Achievement tracking
  - StreakService - Riding streak management

- **API Endpoints**:
  - `/api/leaderboard/global` - Global leaderboard
  - `/api/leaderboard/friends/:userId` - Friends leaderboard
  - `/api/leaderboard/safety` - Safety leaderboard
  - `/api/leaderboard/distance` - Distance leaderboard
  - `/api/users/:userId/rank` - User rank
  - `/api/points/:userId` - User points
  - `/api/points/:userId/history` - Points history
  - `/api/badges/all` - All badges
  - `/api/badges/:userId` - User badges
  - `/api/achievements/all` - All achievements
  - `/api/achievements/:userId` - User achievements

### Frontend (Flutter)
- **Screens**:
  - GamificationDashboard - Main gamification hub
  - LeaderboardPage - Full leaderboard with filters

- **Widgets**:
  - UserRankCard - User's current rank display
  - BadgesComponent - Badge collection viewer
  - AchievementsComponent - Achievement tracker
  - PointsHistoryComponent - Points transaction history
  - GamificationOverviewComponent - Quick stats overview
  - StreakComponent - Streak tracker with calendar

## Setup Instructions

### Backend Setup

1. Navigate to backend directory:
```bash
cd backend
```

2. Install dependencies:
```bash
npm install
```

3. Configure environment variables:
```bash
cp .env.example .env
# Edit .env with your Firebase credentials
```

4. Start the server:
```bash
npm start
```

For development:
```bash
npm run dev
```

### Flutter App Setup

1. Navigate to Flutter app directory:
```bash
cd ridermate_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Update API URL in `lib/services/gamification_api_service.dart`:
```dart
static const String baseUrl = 'http://your-backend-url:3000/api';
```

4. Run the app:
```bash
flutter run
```

## Database Schema

### Collections

#### leaderboard/
- `{period}` (document per period: weekly, monthly, all_time)
  - `period`: string
  - `entries[]`: array of leaderboard entries
  - `updatedAt`: timestamp

#### points/
- `{userId}` (document per user)
  - `userId`: string
  - `totalPoints`: number
  - `dailyPoints`: number
  - `weeklyPoints`: number
  - `pointHistory[]`: array of transactions

#### badges/
- `{badgeId}` (document per badge)
  - `id`: string
  - `name`: string
  - `description`: string
  - `icon`: string (emoji)
  - `criteria`: object
  - `unlockedBy[]`: array of user IDs

#### user_badges/
- `{userId}` (document per user)
  - `userId`: string
  - `badges[]`: array of unlocked badges

#### achievements/
- `{achievementId}` (document per achievement)
  - `id`: string
  - `name`: string
  - `description`: string
  - `type`: string
  - `icon`: string
  - `milestone`: number (optional)

#### user_achievements/
- `{userId}` (document per user)
  - `userId`: string
  - `achievements[]`: array of unlocked achievements

#### streaks/
- `{userId}` (document per user)
  - `userId`: string
  - `currentStreak`: number
  - `bestStreak`: number
  - `lastRideDate`: timestamp

#### users/
- `{userId}` (document per user)
  - `username`: string
  - `safetyScore`: number
  - `totalDistance`: number
  - `friends[]`: array of friend user IDs

## Points System

### Activity Points
- Complete a ride: **+10 points**
- Safe riding (0 overspeeds): **+15 points**
- Long distance ride (>50km): **+20 points**
- Consistent riding (3+ rides/week): **+25 points**
- AI coaching completion: **+5 points**
- Friend referral: **+50 points**
- Streak bonus (7-day streak): **+30 points**

### Multipliers
- Weekend rides: **1.5x**
- Holiday rides: **2.0x**

### Caps
- Daily cap: **500 points**
- Weekly cap: **2000 points**

## Badges

### Available Badges
1. **Safe Rider** 🛡️ - 10 rides with 0 overspeeds
2. **Long Distance** 🏆 - 500+ total km
3. **Weekly Warrior** ⚡ - 7 consecutive days with rides
4. **AI Pro** 🤖 - 50+ AI chat interactions
5. **Social Butterfly** 🦋 - 10+ friends
6. **Memory Keeper** 📸 - 20+ memories uploaded
7. **Speed Master** 🚀 - Average speed >40 km/h across 10 rides
8. **Consistency King** 👑 - 30-day riding streak
9. **Night Rider** 🌙 - 10 rides after sunset
10. **Early Bird** 🌅 - 10 rides before 6 AM

## Achievements

### Milestone Achievements
- 10/50/100 rides
- 100/500/1000/5000 km total distance

### Skill Achievements
- Perfect ride (0 overspeeds)
- Best safety score (95+)

### Social Achievements
- First friend added
- Created ride room
- Attended group ride

### Time-Based Achievements
- 7/30/100-day streak
- 1-year member

## Background Jobs

Automated tasks run via cron:
- **Daily at midnight**: Reset daily points
- **Monday at midnight**: Reset weekly points
- **Hourly**: Update weekly leaderboard
- **Every 6 hours**: Update all-time leaderboard

## API Usage Examples

### Get Global Leaderboard
```bash
curl http://localhost:3000/api/leaderboard/global?period=weekly
```

### Award Points
```bash
curl -X POST http://localhost:3000/api/points/award \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "user123",
    "activityType": "COMPLETE_RIDE",
    "reason": "Completed morning ride"
  }'
```

### Get User Badges
```bash
curl http://localhost:3000/api/badges/user123
```

## Flutter Integration

### Navigate to Gamification Dashboard
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => GamificationDashboard(userId: 'user123'),
  ),
);
```

### Navigate to Leaderboard
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => LeaderboardPage(userId: 'user123'),
  ),
);
```

## Testing

### Backend Testing
```bash
cd backend
npm test
```

### Flutter Testing
```bash
cd ridermate_app
flutter test
```

## Future Enhancements

- [ ] Real-time WebSocket updates for live leaderboard
- [ ] Push notifications for badge/achievement unlocks
- [ ] Social sharing of achievements
- [ ] Leaderboard filtering by location/region
- [ ] Custom badge creation
- [ ] Seasonal challenges and events
- [ ] Team/group leaderboards

## License

MIT License
