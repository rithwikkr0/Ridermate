export interface Location {
  latitude: number;
  longitude: number;
  timestamp: Date;
  speed?: number;
  altitude?: number;
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
  startTime: Date;
  endTime?: Date;
  status: 'active' | 'paused' | 'completed';
  route: Location[];
  stats: RideStats;
  pausedDuration?: number; // in seconds
  pauseTimestamps?: { pausedAt: Date; resumedAt?: Date }[];
  aiAnalysis?: {
    safetyScore: number;
    insights: string[];
    suggestions: string[];
    analyzedAt: Date;
  };
  createdAt: Date;
  updatedAt: Date;
}

export interface StartRideData {
  userId: string;
  startLocation: {
    latitude: number;
    longitude: number;
  };
}

export interface EndRideData {
  rideId: string;
  endLocation: {
    latitude: number;
    longitude: number;
  };
}

export interface UpdateRideLocationData {
  rideId: string;
  location: {
    latitude: number;
    longitude: number;
    speed?: number;
    altitude?: number;
  };
}
