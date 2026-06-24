import { describe, it, expect } from 'vitest';
import {
  calculateHaversineDistance,
  mpsToKmh,
  isValidCoordinate,
  isAccurateLocation,
  formatDuration,
  getGPSErrorMessage,
  calculateAverageSpeed,
} from '../utils/gpsUtils';
import { GPSErrorType } from '../types';
import type { LocationPoint } from '../types';

describe('GPS Utility Functions', () => {
  describe('calculateHaversineDistance', () => {
    it('should calculate distance between two points correctly', () => {
      // New York to Los Angeles (approximately 3935 km)
      const distance = calculateHaversineDistance(40.7128, -74.006, 34.0522, -118.2437);
      expect(distance).toBeGreaterThan(3900);
      expect(distance).toBeLessThan(4000);
    });

    it('should return 0 for same coordinates', () => {
      const distance = calculateHaversineDistance(40.7128, -74.006, 40.7128, -74.006);
      expect(distance).toBe(0);
    });
  });

  describe('mpsToKmh', () => {
    it('should convert m/s to km/h correctly', () => {
      expect(mpsToKmh(10)).toBe(36);
      expect(mpsToKmh(0)).toBe(0);
      expect(mpsToKmh(27.78)).toBeCloseTo(100, 1);
    });
  });

  describe('isValidCoordinate', () => {
    it('should validate correct coordinates', () => {
      expect(isValidCoordinate(40.7128, -74.006)).toBe(true);
      expect(isValidCoordinate(0, 0)).toBe(true);
      expect(isValidCoordinate(-90, -180)).toBe(true);
      expect(isValidCoordinate(90, 180)).toBe(true);
    });

    it('should reject invalid coordinates', () => {
      expect(isValidCoordinate(91, 0)).toBe(false);
      expect(isValidCoordinate(-91, 0)).toBe(false);
      expect(isValidCoordinate(0, 181)).toBe(false);
      expect(isValidCoordinate(0, -181)).toBe(false);
      expect(isValidCoordinate(NaN, 0)).toBe(false);
      expect(isValidCoordinate(0, NaN)).toBe(false);
    });
  });

  describe('isAccurateLocation', () => {
    it('should validate accurate locations', () => {
      expect(isAccurateLocation(10)).toBe(true);
      expect(isAccurateLocation(49)).toBe(true);
    });

    it('should reject inaccurate locations', () => {
      expect(isAccurateLocation(50)).toBe(false);
      expect(isAccurateLocation(100)).toBe(false);
    });
  });

  describe('formatDuration', () => {
    it('should format duration correctly', () => {
      expect(formatDuration(0)).toBe('00:00');
      expect(formatDuration(59)).toBe('00:59');
      expect(formatDuration(60)).toBe('01:00');
      expect(formatDuration(125)).toBe('02:05');
      expect(formatDuration(3599)).toBe('59:59');
    });
  });

  describe('getGPSErrorMessage', () => {
    it('should return correct error messages', () => {
      expect(getGPSErrorMessage(GPSErrorType.PERMISSION_DENIED)).toContain('permission');
      expect(getGPSErrorMessage(GPSErrorType.POSITION_UNAVAILABLE)).toContain('unavailable');
      expect(getGPSErrorMessage(GPSErrorType.TIMEOUT)).toContain('timed out');
      expect(getGPSErrorMessage(GPSErrorType.UNSUPPORTED)).toContain('not supported');
    });
  });

  describe('calculateAverageSpeed', () => {
    it('should calculate average speed correctly', () => {
      const locations: LocationPoint[] = [
        { latitude: 40.7128, longitude: -74.006, speed: 10, timestamp: 0, accuracy: 10 },
        { latitude: 40.7228, longitude: -74.006, speed: 10, timestamp: 3600000, accuracy: 10 },
      ];
      const avgSpeed = calculateAverageSpeed(locations);
      expect(avgSpeed).toBeGreaterThan(0);
    });

    it('should return 0 for empty array', () => {
      expect(calculateAverageSpeed([])).toBe(0);
    });

    it('should return 0 for single location', () => {
      const locations: LocationPoint[] = [
        { latitude: 40.7128, longitude: -74.006, speed: 10, timestamp: 0, accuracy: 10 },
      ];
      expect(calculateAverageSpeed(locations)).toBe(0);
    });
  });
});
