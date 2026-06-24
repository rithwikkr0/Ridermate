import React, { useEffect, useState } from 'react';
import { useGPSTracking } from '../hooks/useGPSTracking';
import { useRideTracking } from '../hooks/useRideTracking';
import { MapComponent } from '../components/MapComponent';
import { RideState } from '../types';
import { formatDuration } from '../utils/gpsUtils';
import './RideTrackingPage.css';

const OVERSPEED_THRESHOLD = 60; // km/h

/**
 * Main page component for GPS ride tracking
 * Integrates GPS tracking, ride metrics, and map visualization
 */
export const RideTrackingPage: React.FC = () => {
  const {
    currentLocation,
    locationHistory,
    accuracy,
    error: gpsError,
    isTracking: isGPSTracking,
    startTracking,
    stopTracking,
  } = useGPSTracking({
    enableHighAccuracy: true,
    timeout: 10000,
    maximumAge: 1000,
  });

  const {
    rideState,
    metrics,
    startRide,
    pauseRide,
    resumeRide,
    endRide,
    updateLocation,
  } = useRideTracking({
    overspeedThreshold: OVERSPEED_THRESHOLD,
  });

  const [startLocation, setStartLocation] = useState<typeof currentLocation>(null);
  const [showOverspeedWarning, setShowOverspeedWarning] = useState(false);

  // Update ride location when GPS location changes
  useEffect(() => {
    if (currentLocation && rideState === RideState.TRACKING) {
      updateLocation(currentLocation);
    }
  }, [currentLocation, rideState, updateLocation]);

  // Show overspeed warning
  useEffect(() => {
    if (metrics.currentSpeed > OVERSPEED_THRESHOLD && rideState === RideState.TRACKING) {
      setShowOverspeedWarning(true);
      const timer = setTimeout(() => setShowOverspeedWarning(false), 3000);
      return () => clearTimeout(timer);
    } else {
      setShowOverspeedWarning(false);
    }
  }, [metrics.currentSpeed, rideState]);

  const handleStartRide = () => {
    if (!currentLocation) {
      // Request GPS first
      startTracking();
      return;
    }

    setStartLocation(currentLocation);
    startRide(currentLocation);
  };

  const handlePauseRide = () => {
    pauseRide();
  };

  const handleResumeRide = () => {
    resumeRide();
  };

  const handleEndRide = () => {
    const session = endRide();
    stopTracking();
    
    // In a real app, you would save this to backend
    console.log('Ride completed:', session);
    
    alert(
      `Ride completed!\n\n` +
      `Distance: ${metrics.distance.toFixed(2)} km\n` +
      `Duration: ${formatDuration(metrics.duration)}\n` +
      `Avg Speed: ${metrics.avgSpeed.toFixed(1)} km/h\n` +
      `Max Speed: ${metrics.maxSpeed.toFixed(1)} km/h\n` +
      `Overspeeds: ${metrics.overspeeds}`
    );

    // Reset for next ride
    setStartLocation(null);
  };

  // Auto-start GPS tracking when component mounts
  useEffect(() => {
    startTracking();
    // Only run on mount
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const accuracyClass = accuracy < 20 ? 'good' : accuracy < 50 ? 'medium' : 'poor';

  return (
    <div className="ride-tracking-page">
      <div className="header">
        <h1>🚴 RiderMate GPS Tracking</h1>
        {currentLocation && (
          <div className={`accuracy-indicator ${accuracyClass}`}>
            GPS Accuracy: ±{accuracy.toFixed(0)}m
          </div>
        )}
      </div>

      {/* GPS Error Display */}
      {gpsError && (
        <div className="error-banner">
          <span className="error-icon">⚠️</span>
          <span>{gpsError.message}</span>
        </div>
      )}

      {/* Overspeed Warning */}
      {showOverspeedWarning && (
        <div className="overspeed-warning">
          <span className="warning-icon">🚨</span>
          <span>SLOW DOWN! Speed limit: {OVERSPEED_THRESHOLD} km/h</span>
        </div>
      )}

      {/* Status Indicator */}
      <div className="status-bar">
        <div className={`status-indicator ${rideState}`}>
          {rideState === RideState.IDLE && '⏸️ Ready'}
          {rideState === RideState.TRACKING && '🟢 Tracking'}
          {rideState === RideState.PAUSED && '⏸️ Paused'}
          {rideState === RideState.COMPLETED && '✅ Completed'}
        </div>
      </div>

      {/* Main Content Area */}
      <div className="content">
        {/* Map Container */}
        <div className="map-container">
          <MapComponent
            currentLocation={rideState === RideState.TRACKING ? currentLocation : null}
            locationHistory={locationHistory}
            startLocation={startLocation}
            centerOnCurrent={rideState === RideState.TRACKING}
          />
        </div>

        {/* Metrics Display */}
        <div className="metrics-panel">
          <div className="metrics-grid">
            <div className="metric-card primary">
              <div className="metric-label">Current Speed</div>
              <div className="metric-value">
                {metrics.currentSpeed.toFixed(1)}
                <span className="metric-unit">km/h</span>
              </div>
            </div>

            <div className="metric-card">
              <div className="metric-label">Distance</div>
              <div className="metric-value">
                {metrics.distance.toFixed(2)}
                <span className="metric-unit">km</span>
              </div>
            </div>

            <div className="metric-card">
              <div className="metric-label">Time</div>
              <div className="metric-value">
                {formatDuration(metrics.duration)}
              </div>
            </div>

            <div className="metric-card">
              <div className="metric-label">Avg Speed</div>
              <div className="metric-value">
                {metrics.avgSpeed.toFixed(1)}
                <span className="metric-unit">km/h</span>
              </div>
            </div>

            <div className="metric-card">
              <div className="metric-label">Max Speed</div>
              <div className="metric-value">
                {metrics.maxSpeed.toFixed(1)}
                <span className="metric-unit">km/h</span>
              </div>
            </div>

            <div className="metric-card">
              <div className="metric-label">Overspeeds</div>
              <div className="metric-value highlight">
                {metrics.overspeeds}
              </div>
            </div>
          </div>
        </div>

        {/* Control Buttons */}
        <div className="controls">
          {rideState === RideState.IDLE && (
            <button
              className="btn btn-start"
              onClick={handleStartRide}
              disabled={!currentLocation && isGPSTracking}
            >
              {!currentLocation && isGPSTracking ? '📡 Acquiring GPS...' : '🚀 Start Ride'}
            </button>
          )}

          {rideState === RideState.TRACKING && (
            <>
              <button className="btn btn-pause" onClick={handlePauseRide}>
                ⏸️ Pause
              </button>
              <button className="btn btn-end" onClick={handleEndRide}>
                🛑 End Ride
              </button>
            </>
          )}

          {rideState === RideState.PAUSED && (
            <>
              <button className="btn btn-resume" onClick={handleResumeRide}>
                ▶️ Resume
              </button>
              <button className="btn btn-end" onClick={handleEndRide}>
                🛑 End Ride
              </button>
            </>
          )}
        </div>
      </div>

      {/* GPS Info Footer */}
      {currentLocation && (
        <div className="footer-info">
          <div>
            📍 Lat: {currentLocation.latitude.toFixed(6)}, Lon: {currentLocation.longitude.toFixed(6)}
          </div>
          <div>
            Locations tracked: {locationHistory.length}
          </div>
        </div>
      )}
    </div>
  );
};
