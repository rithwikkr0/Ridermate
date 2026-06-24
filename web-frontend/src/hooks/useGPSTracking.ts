import { useState, useEffect, useCallback, useRef } from 'react';
import type { LocationPoint, GPSError } from '../types';
import { GPSErrorType } from '../types';
import { isValidCoordinate, convertGeolocationError } from '../utils/gpsUtils';

interface UseGPSTrackingOptions {
  enableHighAccuracy?: boolean;
  timeout?: number;
  maximumAge?: number;
}

interface UseGPSTrackingResult {
  currentLocation: LocationPoint | null;
  locationHistory: LocationPoint[];
  accuracy: number;
  error: GPSError | null;
  isTracking: boolean;
  startTracking: () => void;
  stopTracking: () => void;
}

/**
 * Custom hook for GPS tracking using navigator.geolocation.watchPosition
 * Tracks location, speed, timestamp, and accuracy
 */
export function useGPSTracking(
  options: UseGPSTrackingOptions = {}
): UseGPSTrackingResult {
  const [currentLocation, setCurrentLocation] = useState<LocationPoint | null>(null);
  const [locationHistory, setLocationHistory] = useState<LocationPoint[]>([]);
  const [accuracy, setAccuracy] = useState<number>(0);
  const [error, setError] = useState<GPSError | null>(null);
  const [isTracking, setIsTracking] = useState<boolean>(false);

  const watchIdRef = useRef<number | null>(null);

  const {
    enableHighAccuracy = true,
    timeout = 10000,
    maximumAge = 0,
  } = options;

  const stopTracking = useCallback(() => {
    if (watchIdRef.current !== null) {
      navigator.geolocation.clearWatch(watchIdRef.current);
      watchIdRef.current = null;
    }
    setIsTracking(false);
  }, []);

  const startTracking = useCallback(() => {
    // Check if geolocation is supported
    if (!navigator.geolocation) {
      setError({
        type: GPSErrorType.UNSUPPORTED,
        message: 'Geolocation is not supported by your browser.',
      });
      return;
    }

    setError(null);
    setIsTracking(true);

    const successCallback = (position: GeolocationPosition) => {
      const { latitude, longitude, accuracy: posAccuracy, speed } = position.coords;

      // Validate coordinates
      if (!isValidCoordinate(latitude, longitude)) {
        setError({
          type: GPSErrorType.POSITION_UNAVAILABLE,
          message: 'Invalid GPS coordinates received.',
        });
        return;
      }

      const locationPoint: LocationPoint = {
        latitude,
        longitude,
        speed,
        timestamp: position.timestamp,
        accuracy: posAccuracy,
      };

      setCurrentLocation(locationPoint);
      setAccuracy(posAccuracy);
      setLocationHistory((prev) => [...prev, locationPoint]);
      setError(null);
    };

    const errorCallback = (err: GeolocationPositionError) => {
      const gpsError = convertGeolocationError(err);
      setError(gpsError);
      setIsTracking(false);
    };

    // Start watching position
    watchIdRef.current = navigator.geolocation.watchPosition(
      successCallback,
      errorCallback,
      {
        enableHighAccuracy,
        timeout,
        maximumAge,
      }
    );
  }, [enableHighAccuracy, timeout, maximumAge]);

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      stopTracking();
    };
  }, [stopTracking]);

  return {
    currentLocation,
    locationHistory,
    accuracy,
    error,
    isTracking,
    startTracking,
    stopTracking,
  };
}
