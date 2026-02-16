import React, { useEffect } from 'react';
import { MapContainer, TileLayer, Marker, Polyline, useMap } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import type { LocationPoint } from '../types';

// Fix for default marker icons in React-Leaflet
import markerIcon2x from 'leaflet/dist/images/marker-icon-2x.png';
import markerIcon from 'leaflet/dist/images/marker-icon.png';
import markerShadow from 'leaflet/dist/images/marker-shadow.png';

// eslint-disable-next-line @typescript-eslint/no-explicit-any
delete (L.Icon.Default.prototype as any)._getIconUrl;
L.Icon.Default.mergeOptions({
  iconUrl: markerIcon,
  iconRetinaUrl: markerIcon2x,
  shadowUrl: markerShadow,
});

interface MapComponentProps {
  currentLocation: LocationPoint | null;
  locationHistory: LocationPoint[];
  startLocation?: LocationPoint | null;
  centerOnCurrent?: boolean;
}

// Component to handle map centering
function MapCenterControl({ center }: { center: [number, number] }) {
  const map = useMap();

  useEffect(() => {
    map.setView(center, map.getZoom());
  }, [center, map]);

  return null;
}

// Custom marker icons
const startIcon = new L.Icon({
  iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-green.png',
  shadowUrl: markerShadow,
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
  shadowSize: [41, 41],
});

const currentIcon = new L.Icon({
  iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-blue.png',
  shadowUrl: markerShadow,
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
  shadowSize: [41, 41],
});

const endIcon = new L.Icon({
  iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-red.png',
  shadowUrl: markerShadow,
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
  shadowSize: [41, 41],
});

/**
 * Leaflet Map Component for displaying GPS tracking
 * Shows current location, route polyline, and start/end markers
 */
export const MapComponent: React.FC<MapComponentProps> = ({
  currentLocation,
  locationHistory,
  startLocation,
  centerOnCurrent = true,
}) => {
  const defaultCenter: [number, number] = [37.7749, -122.4194]; // San Francisco default
  const defaultZoom = 13;

  // Determine map center
  const mapCenter: [number, number] = currentLocation
    ? [currentLocation.latitude, currentLocation.longitude]
    : startLocation
    ? [startLocation.latitude, startLocation.longitude]
    : defaultCenter;

  // Convert location history to polyline coordinates
  const polylinePositions: [number, number][] = locationHistory.map((loc) => [
    loc.latitude,
    loc.longitude,
  ]);

  // Determine end location (last location in history if ride is complete)
  const endLocation = locationHistory.length > 1 ? locationHistory[locationHistory.length - 1] : null;
  const isRideActive = currentLocation !== null;

  return (
    <div style={{ width: '100%', height: '100%', position: 'relative' }}>
      <MapContainer
        center={mapCenter}
        zoom={defaultZoom}
        style={{ width: '100%', height: '100%' }}
        zoomControl={true}
      >
        {/* OpenStreetMap tiles */}
        <TileLayer
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
          url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        />

        {/* Center map on current location if enabled */}
        {centerOnCurrent && currentLocation && (
          <MapCenterControl center={[currentLocation.latitude, currentLocation.longitude]} />
        )}

        {/* Start location marker */}
        {startLocation && (
          <Marker
            position={[startLocation.latitude, startLocation.longitude]}
            icon={startIcon}
            title="Start"
          />
        )}

        {/* Current location marker */}
        {isRideActive && currentLocation && (
          <Marker
            position={[currentLocation.latitude, currentLocation.longitude]}
            icon={currentIcon}
            title="Current Location"
          />
        )}

        {/* End location marker (only when ride is not active) */}
        {!isRideActive && endLocation && (
          <Marker
            position={[endLocation.latitude, endLocation.longitude]}
            icon={endIcon}
            title="End"
          />
        )}

        {/* Route polyline */}
        {polylinePositions.length > 1 && (
          <Polyline
            positions={polylinePositions}
            pathOptions={{
              color: '#0066FF',
              weight: 4,
              opacity: 0.7,
            }}
          />
        )}
      </MapContainer>

      {/* Map legend */}
      <div
        style={{
          position: 'absolute',
          bottom: '20px',
          right: '10px',
          background: 'white',
          padding: '10px',
          borderRadius: '8px',
          boxShadow: '0 2px 8px rgba(0,0,0,0.2)',
          fontSize: '12px',
          zIndex: 1000,
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', marginBottom: '5px' }}>
          <div
            style={{
              width: '12px',
              height: '12px',
              backgroundColor: '#4CAF50',
              borderRadius: '50%',
              marginRight: '8px',
            }}
          ></div>
          <span>Start</span>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', marginBottom: '5px' }}>
          <div
            style={{
              width: '12px',
              height: '12px',
              backgroundColor: '#0066FF',
              borderRadius: '50%',
              marginRight: '8px',
            }}
          ></div>
          <span>Current</span>
        </div>
        {!isRideActive && endLocation && (
          <div style={{ display: 'flex', alignItems: 'center' }}>
            <div
              style={{
                width: '12px',
                height: '12px',
                backgroundColor: '#FF0000',
                borderRadius: '50%',
                marginRight: '8px',
              }}
            ></div>
            <span>End</span>
          </div>
        )}
      </div>
    </div>
  );
};
