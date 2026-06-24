// Point activity types and their base values
const POINT_VALUES = {
  COMPLETE_RIDE: 10,
  SAFE_RIDE: 15,
  LONG_DISTANCE: 20,
  CONSISTENT_RIDING: 25,
  AI_COACHING: 5,
  FRIEND_REFERRAL: 50,
  STREAK_BONUS: 30,
};

// Badge types and criteria
const BADGE_TYPES = {
  SAFE_RIDER: {
    id: 'safe_rider',
    name: 'Safe Rider',
    description: '10 rides with 0 overspeeds',
    icon: '🛡️',
    criteria: { rides_with_zero_overspeeds: 10 },
  },
  LONG_DISTANCE: {
    id: 'long_distance',
    name: 'Long Distance',
    description: '500+ total km',
    icon: '🏆',
    criteria: { total_distance_km: 500 },
  },
  WEEKLY_WARRIOR: {
    id: 'weekly_warrior',
    name: 'Weekly Warrior',
    description: '7 consecutive days with rides',
    icon: '⚡',
    criteria: { consecutive_days: 7 },
  },
  AI_PRO: {
    id: 'ai_pro',
    name: 'AI Pro',
    description: '50+ AI chat interactions',
    icon: '🤖',
    criteria: { ai_interactions: 50 },
  },
  SOCIAL_BUTTERFLY: {
    id: 'social_butterfly',
    name: 'Social Butterfly',
    description: '10+ friends',
    icon: '🦋',
    criteria: { friends_count: 10 },
  },
  MEMORY_KEEPER: {
    id: 'memory_keeper',
    name: 'Memory Keeper',
    description: '20+ memories uploaded',
    icon: '📸',
    criteria: { memories_count: 20 },
  },
  SPEED_MASTER: {
    id: 'speed_master',
    name: 'Speed Master',
    description: 'Average speed >40 km/h across 10 rides',
    icon: '🚀',
    criteria: { avg_speed_kmh: 40, min_rides: 10 },
  },
  CONSISTENCY_KING: {
    id: 'consistency_king',
    name: 'Consistency King',
    description: '30-day riding streak',
    icon: '👑',
    criteria: { streak_days: 30 },
  },
  NIGHT_RIDER: {
    id: 'night_rider',
    name: 'Night Rider',
    description: '10 rides after sunset',
    icon: '🌙',
    criteria: { night_rides: 10 },
  },
  EARLY_BIRD: {
    id: 'early_bird',
    name: 'Early Bird',
    description: '10 rides before 6 AM',
    icon: '🌅',
    criteria: { early_rides: 10 },
  },
};

// Achievement types
const ACHIEVEMENT_TYPES = {
  MILESTONE: 'milestone',
  SKILL: 'skill',
  SOCIAL: 'social',
  TIME_BASED: 'time_based',
};

// Milestone achievements
const ACHIEVEMENTS = {
  RIDES_10: {
    id: 'rides_10',
    name: '10 Rides',
    type: ACHIEVEMENT_TYPES.MILESTONE,
    description: 'Complete 10 rides',
    icon: '🎯',
    milestone: 10,
  },
  RIDES_50: {
    id: 'rides_50',
    name: '50 Rides',
    type: ACHIEVEMENT_TYPES.MILESTONE,
    description: 'Complete 50 rides',
    icon: '🎯',
    milestone: 50,
  },
  RIDES_100: {
    id: 'rides_100',
    name: '100 Rides',
    type: ACHIEVEMENT_TYPES.MILESTONE,
    description: 'Complete 100 rides',
    icon: '🎯',
    milestone: 100,
  },
  DISTANCE_100KM: {
    id: 'distance_100km',
    name: '100 KM',
    type: ACHIEVEMENT_TYPES.MILESTONE,
    description: 'Ride 100 km total',
    icon: '🛣️',
    milestone: 100,
  },
  DISTANCE_500KM: {
    id: 'distance_500km',
    name: '500 KM',
    type: ACHIEVEMENT_TYPES.MILESTONE,
    description: 'Ride 500 km total',
    icon: '🛣️',
    milestone: 500,
  },
  DISTANCE_1000KM: {
    id: 'distance_1000km',
    name: '1000 KM',
    type: ACHIEVEMENT_TYPES.MILESTONE,
    description: 'Ride 1000 km total',
    icon: '🛣️',
    milestone: 1000,
  },
  DISTANCE_5000KM: {
    id: 'distance_5000km',
    name: '5000 KM',
    type: ACHIEVEMENT_TYPES.MILESTONE,
    description: 'Ride 5000 km total',
    icon: '🛣️',
    milestone: 5000,
  },
  PERFECT_RIDE: {
    id: 'perfect_ride',
    name: 'Perfect Ride',
    type: ACHIEVEMENT_TYPES.SKILL,
    description: 'Complete a ride with 0 overspeeds',
    icon: '⭐',
  },
  BEST_SAFETY_SCORE: {
    id: 'best_safety_score',
    name: 'Safety Champion',
    type: ACHIEVEMENT_TYPES.SKILL,
    description: 'Achieve safety score of 95+',
    icon: '🏅',
  },
  FIRST_FRIEND: {
    id: 'first_friend',
    name: 'First Friend',
    type: ACHIEVEMENT_TYPES.SOCIAL,
    description: 'Add your first friend',
    icon: '👋',
  },
  CREATED_RIDE_ROOM: {
    id: 'created_ride_room',
    name: 'Room Creator',
    type: ACHIEVEMENT_TYPES.SOCIAL,
    description: 'Create your first ride room',
    icon: '🚪',
  },
  STREAK_7: {
    id: 'streak_7',
    name: '7-Day Streak',
    type: ACHIEVEMENT_TYPES.TIME_BASED,
    description: 'Ride for 7 consecutive days',
    icon: '🔥',
  },
  STREAK_30: {
    id: 'streak_30',
    name: '30-Day Streak',
    type: ACHIEVEMENT_TYPES.TIME_BASED,
    description: 'Ride for 30 consecutive days',
    icon: '🔥',
  },
  STREAK_100: {
    id: 'streak_100',
    name: '100-Day Streak',
    type: ACHIEVEMENT_TYPES.TIME_BASED,
    description: 'Ride for 100 consecutive days',
    icon: '🔥',
  },
  ONE_YEAR_MEMBER: {
    id: 'one_year_member',
    name: '1-Year Member',
    type: ACHIEVEMENT_TYPES.TIME_BASED,
    description: 'Active for 1 year',
    icon: '🎂',
  },
};

// Leaderboard periods
const LEADERBOARD_PERIODS = {
  WEEKLY: 'weekly',
  MONTHLY: 'monthly',
  ALL_TIME: 'all_time',
};

module.exports = {
  POINT_VALUES,
  BADGE_TYPES,
  ACHIEVEMENT_TYPES,
  ACHIEVEMENTS,
  LEADERBOARD_PERIODS,
};
