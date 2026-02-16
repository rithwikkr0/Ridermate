// Location and GPS types
export interface LocationPoint {
  latitude: number;
  longitude: number;
  speed: number | null; // Speed in m/s from GPS
  timestamp: number;
  accuracy: number; // Accuracy in meters
}

// Ride metrics
export interface RideMetrics {
  distance: number; // Total distance in km
  duration: number; // Duration in seconds
  currentSpeed: number; // Current speed in km/h
  avgSpeed: number; // Average speed in km/h
  maxSpeed: number; // Maximum speed in km/h
  overspeeds: number; // Count of overspeed instances
}

// Ride state
export const RideState = {
  IDLE: 'idle',
  TRACKING: 'tracking',
  PAUSED: 'paused',
  COMPLETED: 'completed',
} as const;

export type RideState = typeof RideState[keyof typeof RideState];

// GPS error types
export const GPSErrorType = {
  PERMISSION_DENIED: 'permission_denied',
  POSITION_UNAVAILABLE: 'position_unavailable',
  TIMEOUT: 'timeout',
  UNSUPPORTED: 'unsupported',
  UNKNOWN: 'unknown',
} as const;

export type GPSErrorType = typeof GPSErrorType[keyof typeof GPSErrorType];

export interface GPSError {
  type: GPSErrorType;
  message: string;
}

// Ride session data
export interface RideSession {
  startTime: number;
  endTime?: number;
  pausedDuration: number; // Total time paused in seconds
  locations: LocationPoint[];
  metrics: RideMetrics;
  state: RideState;
}

