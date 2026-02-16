export interface User {
  id: string;
  email: string;
  displayName: string;
  photoURL?: string;
  createdAt: Date;
  updatedAt: Date;
  privacySettings?: PrivacySettings;
  stats?: UserStats;
}

export interface PrivacySettings {
  shareLocation: boolean;
  shareRides: boolean;
  showInLeaderboard: boolean;
}

export interface UserStats {
  totalRides: number;
  totalDistance: number;
  totalDuration: number;
  points: number;
  level: number;
  streak: number;
  badges: string[];
}

export interface Ride {
  id: string;
  userId: string;
  startTime: Date;
  endTime?: Date;
  distance: number;
  duration: number;
  averageSpeed: number;
  maxSpeed: number;
  route: GPSPoint[];
  overspeeds: OverspeedEvent[];
  safetyScore: number;
  status: 'active' | 'completed' | 'paused';
  createdAt: Date;
}

export interface GPSPoint {
  latitude: number;
  longitude: number;
  timestamp: Date;
  speed: number;
  accuracy: number;
}

export interface OverspeedEvent {
  timestamp: Date;
  speed: number;
  location: {
    latitude: number;
    longitude: number;
  };
}

export interface Memory {
  id: string;
  userId: string;
  rideId?: string;
  photoURL: string;
  caption?: string;
  location?: {
    latitude: number;
    longitude: number;
  };
  createdAt: Date;
}

export interface Friend {
  id: string;
  userId: string;
  friendId: string;
  status: 'pending' | 'accepted' | 'rejected';
  createdAt: Date;
}

export interface RideRoom {
  id: string;
  name: string;
  creatorId: string;
  participants: string[];
  isActive: boolean;
  createdAt: Date;
}

export interface Achievement {
  id: string;
  name: string;
  description: string;
  icon: string;
  points: number;
  requirement: string;
}

export interface UserAchievement {
  userId: string;
  achievementId: string;
  unlockedAt: Date;
}

export interface AIMessage {
  id: string;
  userId: string;
  role: 'user' | 'assistant';
  content: string;
  timestamp: Date;
}

export interface WeeklySummary {
  userId: string;
  weekStart: Date;
  weekEnd: Date;
  totalRides: number;
  totalDistance: number;
  totalDuration: number;
  averageSpeed: number;
  safetyScore: number;
  insights: string;
  generatedAt: Date;
}
