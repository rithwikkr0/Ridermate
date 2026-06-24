/**
 * TypeScript Type Definitions for RiderMate Gamification System
 * These types can be used for TypeScript projects or as reference
 */

// Leaderboard Types
export interface LeaderboardEntry {
  userId: string;
  username: string;
  rank: number;
  points: number;
  safetyScore: number;
  totalDistance: number;
  avatarUrl?: string;
  rankChange?: number;
}

export type LeaderboardPeriod = 'weekly' | 'monthly' | 'all_time';

export interface LeaderboardResponse {
  success: boolean;
  period: LeaderboardPeriod;
  leaderboard: LeaderboardEntry[];
}

// Points Types
export interface PointsTransaction {
  points: number;
  reason: string;
  activityType: string;
  multiplier: number;
  timestamp: string;
}

export interface UserPoints {
  userId: string;
  totalPoints: number;
  dailyPoints: number;
  weeklyPoints: number;
  pointHistory: PointsTransaction[];
  createdAt?: string;
  updatedAt?: string;
}

export type ActivityType =
  | 'COMPLETE_RIDE'
  | 'SAFE_RIDE'
  | 'LONG_DISTANCE'
  | 'CONSISTENT_RIDING'
  | 'AI_COACHING'
  | 'FRIEND_REFERRAL'
  | 'STREAK_BONUS';

// Badge Types
export interface BadgeCriteria {
  rides_with_zero_overspeeds?: number;
  total_distance_km?: number;
  consecutive_days?: number;
  ai_interactions?: number;
  friends_count?: number;
  memories_count?: number;
  avg_speed_kmh?: number;
  min_rides?: number;
  streak_days?: number;
  night_rides?: number;
  early_rides?: number;
}

export interface Badge {
  badgeId: string;
  id?: string;
  name: string;
  description: string;
  icon: string;
  criteria: BadgeCriteria;
  unlocked?: boolean;
  unlockedAt?: string;
  progress?: number;
  unlockedBy?: string[];
  createdAt?: string;
}

export interface UserBadge {
  badgeId: string;
  name: string;
  icon: string;
  unlockedAt: string;
}

export interface UserBadges {
  userId: string;
  badges: UserBadge[];
  createdAt?: string;
  updatedAt?: string;
}

// Achievement Types
export type AchievementType = 'milestone' | 'skill' | 'social' | 'time_based';

export interface Achievement {
  achievementId: string;
  id?: string;
  name: string;
  description: string;
  type: AchievementType;
  icon: string;
  milestone?: number;
  unlocked?: boolean;
  unlockedAt?: string;
  progress?: number;
  unlockedBy?: string[];
  createdAt?: string;
}

export interface UserAchievement {
  achievementId: string;
  name: string;
  type: AchievementType;
  icon: string;
  unlockedAt: string;
}

export interface UserAchievements {
  userId: string;
  achievements: UserAchievement[];
  createdAt?: string;
  updatedAt?: string;
}

// Streak Types
export interface Streak {
  userId: string;
  currentStreak: number;
  bestStreak: number;
  lastRideDate: string | null;
  createdAt?: string;
  updatedAt?: string;
}

// User Stats (for checking badge/achievement criteria)
export interface UserStats {
  totalRides?: number;
  totalDistanceKm?: number;
  ridesWithZeroOverspeeds?: number;
  currentStreak?: number;
  aiInteractions?: number;
  friendsCount?: number;
  memoriesCount?: number;
  avgSpeedKmh?: number;
  nightRides?: number;
  earlyRides?: number;
  safetyScore?: number;
  hasPerfectRide?: boolean;
  hasCreatedRideRoom?: boolean;
  accountCreatedAt?: string;
}

// API Response Types
export interface ApiResponse<T = any> {
  success: boolean;
  message?: string;
  error?: string;
  data?: T;
}

export interface RankResponse {
  success: boolean;
  rank: number | null;
  points: number;
  totalUsers: number;
  rankChange?: number;
}

export interface AwardPointsRequest {
  userId: string;
  activityType: ActivityType;
  reason: string;
}

export interface AwardPointsResponse {
  success: boolean;
  points: number;
  message: string;
}

export interface UnlockBadgeRequest {
  badgeId: string;
  userStats: UserStats;
}

export interface UnlockBadgeResponse {
  success: boolean;
  badge?: UserBadge;
  message: string;
}

export interface UnlockAchievementRequest {
  achievementId: string;
  userStats: UserStats;
}

export interface UnlockAchievementResponse {
  success: boolean;
  achievement?: UserAchievement;
  message: string;
}
