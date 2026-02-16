import { GPSErrorType } from '../types';
import type { LocationPoint, GPSError } from '../types';

/**
 * Calculate distance between two GPS coordinates using Haversine formula
 * @param lat1 Latitude of first point
 * @param lon1 Longitude of first point
 * @param lat2 Latitude of second point
 * @param lon2 Longitude of second point
 * @returns Distance in kilometers
 */
export function calculateHaversineDistance(
  lat1: number,
  lon1: number,
  lat2: number,
  lon2: number
): number {
  const R = 6371; // Earth's radius in km
  const dLat = toRadians(lat2 - lat1);
  const dLon = toRadians(lon2 - lon1);

  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRadians(lat1)) *
      Math.cos(toRadians(lat2)) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);

  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  const distance = R * c;

  return distance;
}

/**
 * Convert degrees to radians
 */
function toRadians(degrees: number): number {
  return degrees * (Math.PI / 180);
}

/**
 * Convert speed from m/s to km/h
 * @param speedMps Speed in meters per second
 * @returns Speed in kilometers per hour
 */
export function mpsToKmh(speedMps: number): number {
  return speedMps * 3.6;
}

/**
 * Validate GPS coordinates
 * @param latitude Latitude value
 * @param longitude Longitude value
 * @returns true if coordinates are valid
 */
export function isValidCoordinate(latitude: number, longitude: number): boolean {
  return (
    latitude >= -90 &&
    latitude <= 90 &&
    longitude >= -180 &&
    longitude <= 180 &&
    !isNaN(latitude) &&
    !isNaN(longitude)
  );
}

/**
 * Validate location point accuracy
 * @param accuracy Accuracy in meters
 * @returns true if accuracy is acceptable (< 50m)
 */
export function isAccurateLocation(accuracy: number): boolean {
  return accuracy < 50; // Consider locations with accuracy better than 50m
}

/**
 * Format duration in seconds to MM:SS format
 * @param seconds Duration in seconds
 * @returns Formatted time string
 */
export function formatDuration(seconds: number): string {
  const mins = Math.floor(seconds / 60);
  const secs = seconds % 60;
  return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
}

/**
 * Get user-friendly error message for GPS errors
 * @param errorType GPS error type
 * @returns User-friendly error message
 */
export function getGPSErrorMessage(errorType: GPSErrorType): string {
  switch (errorType) {
    case GPSErrorType.PERMISSION_DENIED:
      return 'Location permission denied. Please enable location access in your browser settings.';
    case GPSErrorType.POSITION_UNAVAILABLE:
      return 'Location information is unavailable. Please check your GPS settings.';
    case GPSErrorType.TIMEOUT:
      return 'Location request timed out. Please try again.';
    case GPSErrorType.UNSUPPORTED:
      return 'Geolocation is not supported by your browser.';
    default:
      return 'An unknown error occurred while accessing location.';
  }
}

/**
 * Convert GeolocationPositionError to GPSError
 * @param error GeolocationPositionError from browser
 * @returns GPSError object
 */
export function convertGeolocationError(error: GeolocationPositionError): GPSError {
  let type: GPSErrorType;

  switch (error.code) {
    case error.PERMISSION_DENIED:
      type = GPSErrorType.PERMISSION_DENIED;
      break;
    case error.POSITION_UNAVAILABLE:
      type = GPSErrorType.POSITION_UNAVAILABLE;
      break;
    case error.TIMEOUT:
      type = GPSErrorType.TIMEOUT;
      break;
    default:
      type = GPSErrorType.UNKNOWN;
  }

  return {
    type,
    message: getGPSErrorMessage(type),
  };
}

/**
 * Calculate average speed from location history
 * @param locations Array of location points
 * @returns Average speed in km/h
 */
export function calculateAverageSpeed(locations: LocationPoint[]): number {
  if (locations.length === 0) return 0;

  let totalDistance = 0;
  for (let i = 1; i < locations.length; i++) {
    totalDistance += calculateHaversineDistance(
      locations[i - 1].latitude,
      locations[i - 1].longitude,
      locations[i].latitude,
      locations[i].longitude
    );
  }

  if (locations.length < 2) return 0;

  const totalTimeHours =
    (locations[locations.length - 1].timestamp - locations[0].timestamp) / 1000 / 3600;

  return totalTimeHours > 0 ? totalDistance / totalTimeHours : 0;
}
