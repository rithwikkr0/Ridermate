import React, { useState, useEffect } from 'react';
import { MapContainer, TileLayer, Marker, Polyline, useMap } from 'react-leaflet';
import { Link } from 'react-router-dom';
import { rideAPI } from '../services/api';
import 'leaflet/dist/leaflet.css';

const RideTracking: React.FC = () => {
  const [isTracking, setIsTracking] = useState(false);
  const [currentRideId, setCurrentRideId] = useState<string | null>(null);
  const [route, setRoute] = useState<[number, number][]>([]);
  const [stats, setStats] = useState({
    distance: 0,
    duration: 0,
    speed: 0,
    maxSpeed: 0,
  });
  const [center, setCenter] = useState<[number, number]>([51.505, -0.09]);

  useEffect(() => {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          const { latitude, longitude } = position.coords;
          setCenter([latitude, longitude]);
        },
        (error) => {
          console.error('Error getting location:', error);
        }
      );
    }
  }, []);

  const startRide = async () => {
    try {
      const response = await rideAPI.startRide({
        startLocation: {
          latitude: center[0],
          longitude: center[1],
          timestamp: new Date(),
          speed: 0,
          accuracy: 0,
        },
      });
      setCurrentRideId(response.data.rideId);
      setIsTracking(true);
      setRoute([center]);
    } catch (error) {
      console.error('Error starting ride:', error);
      alert('Failed to start ride');
    }
  };

  const endRide = async () => {
    if (!currentRideId) return;

    try {
      await rideAPI.endRide(currentRideId);
      setIsTracking(false);
      setCurrentRideId(null);
      alert('Ride ended successfully!');
    } catch (error) {
      console.error('Error ending ride:', error);
      alert('Failed to end ride');
    }
  };

  return (
    <div style={{ minHeight: '100vh', backgroundColor: 'var(--bg-secondary)' }}>
      <header style={{ backgroundColor: 'var(--bg-color)', borderBottom: '1px solid var(--border-color)', padding: '1rem' }}>
        <div className="container" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <Link to="/" style={{ textDecoration: 'none', color: 'var(--primary-color)', fontSize: '1.5rem' }}>
            ← Back to Dashboard
          </Link>
          <h1>🚴 Ride Tracking</h1>
        </div>
      </header>

      <main className="container" style={{ paddingTop: '2rem', paddingBottom: '2rem' }}>
        {/* Stats Cards */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '1rem', marginBottom: '2rem' }}>
          <div className="card">
            <h3 style={{ fontSize: '0.875rem', color: 'var(--text-secondary)' }}>Distance</h3>
            <p style={{ fontSize: '1.5rem', fontWeight: 'bold' }}>{stats.distance.toFixed(2)} km</p>
          </div>
          <div className="card">
            <h3 style={{ fontSize: '0.875rem', color: 'var(--text-secondary)' }}>Duration</h3>
            <p style={{ fontSize: '1.5rem', fontWeight: 'bold' }}>{Math.floor(stats.duration / 60)} min</p>
          </div>
          <div className="card">
            <h3 style={{ fontSize: '0.875rem', color: 'var(--text-secondary)' }}>Speed</h3>
            <p style={{ fontSize: '1.5rem', fontWeight: 'bold' }}>{stats.speed.toFixed(1)} km/h</p>
          </div>
          <div className="card">
            <h3 style={{ fontSize: '0.875rem', color: 'var(--text-secondary)' }}>Max Speed</h3>
            <p style={{ fontSize: '1.5rem', fontWeight: 'bold' }}>{stats.maxSpeed.toFixed(1)} km/h</p>
          </div>
        </div>

        {/* Map */}
        <div className="card" style={{ marginBottom: '2rem', padding: 0, overflow: 'hidden', height: '400px' }}>
          <MapContainer center={center} zoom={13} style={{ height: '100%', width: '100%' }}>
            <TileLayer
              url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
              attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
            />
            {route.length > 0 && (
              <>
                <Marker position={center} />
                <Polyline positions={route} color="blue" />
              </>
            )}
          </MapContainer>
        </div>

        {/* Controls */}
        <div className="card">
          <div style={{ display: 'flex', gap: '1rem', justifyContent: 'center' }}>
            {!isTracking ? (
              <button onClick={startRide} className="btn btn-primary" style={{ fontSize: '1.25rem', padding: '1rem 2rem' }}>
                Start Ride
              </button>
            ) : (
              <>
                <button className="btn btn-secondary" style={{ fontSize: '1.25rem', padding: '1rem 2rem' }}>
                  Pause
                </button>
                <button onClick={endRide} className="btn btn-danger" style={{ fontSize: '1.25rem', padding: '1rem 2rem' }}>
                  End Ride
                </button>
              </>
            )}
          </div>
        </div>
      </main>
    </div>
  );
};

export default RideTracking;
