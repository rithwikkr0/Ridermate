import { useState, useEffect, useCallback, useRef } from 'react';
import { RideState } from '../types';
import type { RideMetrics, LocationPoint, RideSession } from '../types';
import { calculateHaversineDistance, mpsToKmh } from '../utils/gpsUtils';

interface UseRideTrackingOptions {
  overspeedThreshold?: number; // Speed threshold in km/h
}

interface UseRideTrackingResult {
  rideState: RideState;
  metrics: RideMetrics;
  startRide: (initialLocation: LocationPoint) => void;
  pauseRide: () => void;
  resumeRide: () => void;
  endRide: () => RideSession;
  updateLocation: (location: LocationPoint) => void;
}

const OVERSPEED_THRESHOLD_KMH = 60; // Default overspeed threshold

/**
 * Custom hook for ride tracking and metrics calculation
 * Handles start, pause, resume, end operations
 * Calculates distance, duration, speeds, and overspeed detection
 */
export function useRideTracking(
  options: UseRideTrackingOptions = {}
): UseRideTrackingResult {
  const { overspeedThreshold = OVERSPEED_THRESHOLD_KMH } = options;

  const [rideState, setRideState] = useState<RideState>(RideState.IDLE);
  const [metrics, setMetrics] = useState<RideMetrics>({
    distance: 0,
    duration: 0,
    currentSpeed: 0,
    avgSpeed: 0,
    maxSpeed: 0,
    overspeeds: 0,
  });

  const sessionRef = useRef<RideSession>({
    startTime: 0,
    pausedDuration: 0,
    locations: [],
    metrics: {
      distance: 0,
      duration: 0,
      currentSpeed: 0,
      avgSpeed: 0,
      maxSpeed: 0,
      overspeeds: 0,
    },
    state: RideState.IDLE,
  });

  const pauseStartTimeRef = useRef<number>(0);
  const durationIntervalRef = useRef<number | null>(null);

  // Update duration every second when tracking
  useEffect(() => {
    if (rideState === RideState.TRACKING) {
      durationIntervalRef.current = window.setInterval(() => {
        const now = Date.now();
        const duration = Math.floor(
          (now - sessionRef.current.startTime - sessionRef.current.pausedDuration) / 1000
        );
        
        setMetrics((prev) => ({
          ...prev,
          duration,
        }));
        
        sessionRef.current.metrics.duration = duration;
      }, 1000);
    } else {
      if (durationIntervalRef.current) {
        clearInterval(durationIntervalRef.current);
        durationIntervalRef.current = null;
      }
    }

    return () => {
      if (durationIntervalRef.current) {
        clearInterval(durationIntervalRef.current);
      }
    };
  }, [rideState]);

  const startRide = useCallback((initialLocation: LocationPoint) => {
    const now = Date.now();
    
    sessionRef.current = {
      startTime: now,
      pausedDuration: 0,
      locations: [initialLocation],
      metrics: {
        distance: 0,
        duration: 0,
        currentSpeed: 0,
        avgSpeed: 0,
        maxSpeed: 0,
        overspeeds: 0,
      },
      state: RideState.TRACKING,
    };

    setRideState(RideState.TRACKING);
    setMetrics({
      distance: 0,
      duration: 0,
      currentSpeed: 0,
      avgSpeed: 0,
      maxSpeed: 0,
      overspeeds: 0,
    });
  }, []);

  const pauseRide = useCallback(() => {
    if (rideState === RideState.TRACKING) {
      pauseStartTimeRef.current = Date.now();
      setRideState(RideState.PAUSED);
      sessionRef.current.state = RideState.PAUSED;
    }
  }, [rideState]);

  const resumeRide = useCallback(() => {
    if (rideState === RideState.PAUSED) {
      const pauseDuration = Date.now() - pauseStartTimeRef.current;
      sessionRef.current.pausedDuration += pauseDuration;
      setRideState(RideState.TRACKING);
      sessionRef.current.state = RideState.TRACKING;
    }
  }, [rideState]);

  const endRide = useCallback((): RideSession => {
    const now = Date.now();
    const finalDuration = Math.floor(
      (now - sessionRef.current.startTime - sessionRef.current.pausedDuration) / 1000
    );

    sessionRef.current.endTime = now;
    sessionRef.current.metrics.duration = finalDuration;
    sessionRef.current.state = RideState.COMPLETED;

    setRideState(RideState.COMPLETED);
    setMetrics((prev) => ({
      ...prev,
      duration: finalDuration,
    }));

    const completedSession = { ...sessionRef.current };

    // Reset for next ride
    sessionRef.current = {
      startTime: 0,
      pausedDuration: 0,
      locations: [],
      metrics: {
        distance: 0,
        duration: 0,
        currentSpeed: 0,
        avgSpeed: 0,
        maxSpeed: 0,
        overspeeds: 0,
      },
      state: RideState.IDLE,
    };

    return completedSession;
  }, []);

  const updateLocation = useCallback(
    (location: LocationPoint) => {
      if (rideState !== RideState.TRACKING) {
        return;
      }

      const locations = sessionRef.current.locations;
      const lastLocation = locations[locations.length - 1];

      // Add new location
      sessionRef.current.locations.push(location);

      // Calculate distance increment
      let distanceIncrement = 0;
      if (lastLocation) {
        distanceIncrement = calculateHaversineDistance(
          lastLocation.latitude,
          lastLocation.longitude,
          location.latitude,
          location.longitude
        );
      }

      const newDistance = sessionRef.current.metrics.distance + distanceIncrement;

      // Calculate current speed (from GPS or from distance)
      let currentSpeed = 0;
      if (location.speed !== null && location.speed >= 0) {
        currentSpeed = mpsToKmh(location.speed);
      } else if (lastLocation && distanceIncrement > 0) {
        const timeDiffHours = (location.timestamp - lastLocation.timestamp) / 1000 / 3600;
        currentSpeed = timeDiffHours > 0 ? distanceIncrement / timeDiffHours : 0;
      }

      // Update max speed
      const newMaxSpeed = Math.max(sessionRef.current.metrics.maxSpeed, currentSpeed);

      // Check for overspeed
      let overspeeds = sessionRef.current.metrics.overspeeds;
      if (currentSpeed > overspeedThreshold) {
        overspeeds++;
      }

      // Calculate average speed
      const durationHours = sessionRef.current.metrics.duration / 3600;
      const avgSpeed = durationHours > 0 ? newDistance / durationHours : 0;

      // Update metrics
      const newMetrics: RideMetrics = {
        distance: newDistance,
        duration: sessionRef.current.metrics.duration,
        currentSpeed,
        avgSpeed,
        maxSpeed: newMaxSpeed,
        overspeeds,
      };

      sessionRef.current.metrics = newMetrics;
      setMetrics(newMetrics);
    },
    [rideState, overspeedThreshold]
  );

  return {
    rideState,
    metrics,
    startRide,
    pauseRide,
    resumeRide,
    endRide,
    updateLocation,
  };
}
