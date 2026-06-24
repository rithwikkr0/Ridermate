# RiderMate Backend - Gamification System

Backend API for RiderMate's Leaderboard and Gamification features.

## Features

- **Leaderboard System**: Global, friends, safety, and distance leaderboards
- **Points System**: Award points for activities with daily/weekly caps
- **Badges System**: Unlock badges based on user achievements
- **Achievements System**: Track milestones and award achievements
- **Streak Tracking**: Monitor user riding streaks

## Setup

1. Install dependencies:
```bash
npm install
```

2. Configure Firebase:
   - Copy `.env.example` to `.env`
   - Add your Firebase credentials

3. Start the server:
```bash
npm start
```

For development with auto-reload:
```bash
npm run dev
```

## API Endpoints

### Leaderboard
- `GET /api/leaderboard/global?period=weekly` - Get global leaderboard
- `GET /api/leaderboard/friends/:userId` - Get friends leaderboard
- `GET /api/leaderboard/safety` - Get safety leaderboard
- `GET /api/leaderboard/distance` - Get distance leaderboard
- `GET /api/users/:userId/rank` - Get user rank
- `POST /api/leaderboard/update` - Update leaderboard (admin)

### Points
- `GET /api/points/:userId` - Get user points
- `GET /api/points/:userId/history` - Get points history
- `POST /api/points/award` - Award points to user

### Badges
- `GET /api/badges/all` - Get all available badges
- `GET /api/badges/:userId` - Get user badges
- `GET /api/badges/:userId/progress` - Get badge progress
- `POST /api/badges/:userId/unlock` - Unlock badge

### Achievements
- `GET /api/achievements/all` - Get all achievements
- `GET /api/achievements/:userId` - Get user achievements
- `GET /api/achievements/:userId/progress` - Get achievement progress
- `POST /api/achievements/:userId/unlock` - Unlock achievement

## Database Collections

- `leaderboard/` - Leaderboard data by period
- `points/` - User points and history
- `badges/` - Badge definitions and unlock data
- `user_badges/` - User-specific badge data
- `achievements/` - Achievement definitions
- `user_achievements/` - User-specific achievement data
- `streaks/` - User streak tracking
- `users/` - User profile data

## Background Jobs

- Daily points reset (midnight)
- Weekly points reset (Monday midnight)
- Weekly leaderboard update (hourly)
- All-time leaderboard update (every 6 hours)

## Point System

### Activities and Points
- Complete a ride: +10 points
- Safe riding (0 overspeeds): +15 points
- Long distance ride (>50km): +20 points
- Consistent riding (3+ rides/week): +25 points
- AI coaching completion: +5 points
- Friend referral: +50 points
- Streak bonus (7-day streak): +30 points

### Multipliers
- Weekend: 1.5x
- Holiday: 2.0x

### Caps
- Daily: 500 points
- Weekly: 2000 points
