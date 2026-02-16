import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { analyticsAPI } from '../services/api';

const Analytics: React.FC = () => {
  const [analytics, setAnalytics] = useState<any>(null);
  const [period, setPeriod] = useState(30);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadAnalytics();
  }, [period]);

  const loadAnalytics = async () => {
    setLoading(true);
    try {
      const response = await analyticsAPI.getRideAnalytics(period);
      setAnalytics(response.data.analytics);
    } catch (error) {
      console.error('Error loading analytics:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ minHeight: '100vh', backgroundColor: 'var(--bg-secondary)' }}>
      <header style={{ backgroundColor: 'var(--bg-color)', borderBottom: '1px solid var(--border-color)', padding: '1rem' }}>
        <div className="container" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <Link to="/" style={{ textDecoration: 'none', color: 'var(--primary-color)', fontSize: '1.5rem' }}>
            ← Back
          </Link>
          <h1>📊 Analytics</h1>
        </div>
      </header>

      <main className="container" style={{ paddingTop: '2rem', paddingBottom: '2rem' }}>
        {/* Period Selector */}
        <div className="card" style={{ marginBottom: '2rem' }}>
          <h3 style={{ marginBottom: '1rem' }}>Time Period</h3>
          <div style={{ display: 'flex', gap: '1rem' }}>
            <button
              onClick={() => setPeriod(7)}
              className={`btn ${period === 7 ? 'btn-primary' : 'btn-secondary'}`}
            >
              7 Days
            </button>
            <button
              onClick={() => setPeriod(30)}
              className={`btn ${period === 30 ? 'btn-primary' : 'btn-secondary'}`}
            >
              30 Days
            </button>
            <button
              onClick={() => setPeriod(90)}
              className={`btn ${period === 90 ? 'btn-primary' : 'btn-secondary'}`}
            >
              90 Days
            </button>
          </div>
        </div>

        {loading ? (
          <div className="loading"><div className="spinner"></div></div>
        ) : analytics ? (
          <>
            {/* Summary Stats */}
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '1.5rem', marginBottom: '2rem' }}>
              <div className="card">
                <h3 style={{ fontSize: '0.875rem', color: 'var(--text-secondary)', marginBottom: '0.5rem' }}>Total Rides</h3>
                <p style={{ fontSize: '2rem', fontWeight: 'bold', color: 'var(--primary-color)' }}>
                  {analytics.totalRides || 0}
                </p>
              </div>
              <div className="card">
                <h3 style={{ fontSize: '0.875rem', color: 'var(--text-secondary)', marginBottom: '0.5rem' }}>Total Distance</h3>
                <p style={{ fontSize: '2rem', fontWeight: 'bold', color: 'var(--secondary-color)' }}>
                  {(analytics.totalDistance || 0).toFixed(2)} km
                </p>
              </div>
              <div className="card">
                <h3 style={{ fontSize: '0.875rem', color: 'var(--text-secondary)', marginBottom: '0.5rem' }}>Avg Speed</h3>
                <p style={{ fontSize: '2rem', fontWeight: 'bold', color: 'var(--warning-color)' }}>
                  {(analytics.averageSpeed || 0).toFixed(1)} km/h
                </p>
              </div>
              <div className="card">
                <h3 style={{ fontSize: '0.875rem', color: 'var(--text-secondary)', marginBottom: '0.5rem' }}>Safety Score</h3>
                <p style={{ fontSize: '2rem', fontWeight: 'bold', color: analytics.averageSafetyScore >= 80 ? 'var(--secondary-color)' : 'var(--danger-color)' }}>
                  {(analytics.averageSafetyScore || 0).toFixed(0)}%
                </p>
              </div>
            </div>

            {/* Performance Insights */}
            <div className="card" style={{ marginBottom: '2rem' }}>
              <h2 style={{ marginBottom: '1rem' }}>Performance Insights</h2>
              <div style={{ display: 'grid', gap: '1rem' }}>
                <div style={{ padding: '1rem', backgroundColor: 'var(--bg-secondary)', borderRadius: '0.5rem' }}>
                  <h4>🚀 Top Speed</h4>
                  <p style={{ fontSize: '1.25rem', fontWeight: 'bold' }}>{(analytics.maxSpeed || 0).toFixed(1)} km/h</p>
                </div>
                <div style={{ padding: '1rem', backgroundColor: 'var(--bg-secondary)', borderRadius: '0.5rem' }}>
                  <h4>⏱️ Total Duration</h4>
                  <p style={{ fontSize: '1.25rem', fontWeight: 'bold' }}>
                    {Math.floor((analytics.totalDuration || 0) / 3600)}h {Math.floor(((analytics.totalDuration || 0) % 3600) / 60)}m
                  </p>
                </div>
              </div>
            </div>

            {/* Tips */}
            <div className="card">
              <h2 style={{ marginBottom: '1rem' }}>💡 Tips</h2>
              <ul style={{ paddingLeft: '1.5rem', color: 'var(--text-secondary)' }}>
                <li style={{ marginBottom: '0.5rem' }}>Keep riding regularly to maintain your streak!</li>
                <li style={{ marginBottom: '0.5rem' }}>Try to increase your average speed gradually</li>
                <li style={{ marginBottom: '0.5rem' }}>Maintain a safety score above 80% for better rewards</li>
              </ul>
            </div>
          </>
        ) : (
          <div className="card">
            <p style={{ textAlign: 'center', color: 'var(--text-secondary)' }}>No analytics data available</p>
          </div>
        )}
      </main>
    </div>
  );
};

export default Analytics;
