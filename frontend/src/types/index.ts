// User profile types
export interface User {
  id: string;
  email: string;
  displayName: string;
  photoURL?: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface UserProfile extends User {
  bio?: string;
  location?: string;
  favoriteRoutes?: string[];
  totalRides: number;
  totalDistance: number;
  totalDuration: number;
  friends: string[];
}

// Ride data types
export interface RideLocation {
  latitude: number;
  longitude: number;
  timestamp: Date;
  altitude?: number;
  speed?: number;
}

export interface RideStats {
  distance: number; // in meters
  duration: number; // in seconds
  averageSpeed: number; // in m/s
  maxSpeed: number; // in m/s
  elevationGain: number; // in meters
  calories?: number;
}

export interface Ride {
  id: string;
  userId: string;
  title: string;
  description?: string;
  startTime: Date;
  endTime: Date;
  locations: RideLocation[];
  stats: RideStats;
  photos?: string[];
  isPublic: boolean;
  createdAt: Date;
  updatedAt: Date;
}

// Memory/Journal types
export interface Memory {
  id: string;
  userId: string;
  rideId?: string;
  title: string;
  content: string;
  photos: string[];
  tags: string[];
  mood?: 'great' | 'good' | 'okay' | 'challenging';
  weather?: string;
  location?: string;
  createdAt: Date;
  updatedAt: Date;
}

// Friend relationships types
export interface FriendRequest {
  id: string;
  fromUserId: string;
  toUserId: string;
  status: 'pending' | 'accepted' | 'rejected';
  createdAt: Date;
  updatedAt: Date;
}

export interface Friend {
  id: string;
  userId: string;
  friendId: string;
  displayName: string;
  photoURL?: string;
  totalRides: number;
  addedAt: Date;
}

// Leaderboard types
export interface LeaderboardEntry {
  rank: number;
  userId: string;
  displayName: string;
  photoURL?: string;
  value: number;
  label: string;
}

export interface Leaderboard {
  id: string;
  type: 'distance' | 'duration' | 'rides' | 'elevation';
  period: 'week' | 'month' | 'year' | 'all-time';
  entries: LeaderboardEntry[];
  updatedAt: Date;
}

// API Response types
export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}

// Form types
export interface LoginForm {
  email: string;
  password: string;
}

export interface RegisterForm extends LoginForm {
  displayName: string;
  confirmPassword: string;
}

export interface RideForm {
  title: string;
  description?: string;
  isPublic: boolean;
}

export interface MemoryForm {
  title: string;
  content: string;
  tags: string[];
  mood?: Memory['mood'];
  weather?: string;
  location?: string;
}
