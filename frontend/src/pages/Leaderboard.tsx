import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { gamificationAPI } from '../services/api';

const Leaderboard: React.FC = () => {
  const [leaderboard, setLeaderboard] = useState<any[]>([]);
  const [type, setType] = useState('points');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadLeaderboard();
  }, [type]);

  const loadLeaderboard = async () => {
    setLoading(true);
    try {
      const response = await gamificationAPI.getLeaderboard(type, 10);
      setLeaderboard(response.data.leaderboard);
    } catch (error) {
      console.error('Error loading leaderboard:', error);
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
          <h1>🏆 Leaderboard</h1>
        </div>
      </header>

      <main className="container" style={{ paddingTop: '2rem', paddingBottom: '2rem' }}>
        <div className="card">
          {/* Filter Tabs */}
          <div style={{ display: 'flex', gap: '1rem', marginBottom: '2rem', borderBottom: '1px solid var(--border-color)' }}>
            <button
              onClick={() => setType('points')}
              style={{
                padding: '0.75rem 1.5rem',
                border: 'none',
                background: 'none',
                borderBottom: type === 'points' ? '2px solid var(--primary-color)' : 'none',
                color: type === 'points' ? 'var(--primary-color)' : 'var(--text-secondary)',
                cursor: 'pointer',
                fontWeight: type === 'points' ? 'bold' : 'normal',
              }}
            >
              Points
            </button>
            <button
              onClick={() => setType('distance')}
              style={{
                padding: '0.75rem 1.5rem',
                border: 'none',
                background: 'none',
                borderBottom: type === 'distance' ? '2px solid var(--primary-color)' : 'none',
                color: type === 'distance' ? 'var(--primary-color)' : 'var(--text-secondary)',
                cursor: 'pointer',
                fontWeight: type === 'distance' ? 'bold' : 'normal',
              }}
            >
              Distance
            </button>
            <button
              onClick={() => setType('rides')}
              style={{
                padding: '0.75rem 1.5rem',
                border: 'none',
                background: 'none',
                borderBottom: type === 'rides' ? '2px solid var(--primary-color)' : 'none',
                color: type === 'rides' ? 'var(--primary-color)' : 'var(--text-secondary)',
                cursor: 'pointer',
                fontWeight: type === 'rides' ? 'bold' : 'normal',
              }}
            >
              Rides
            </button>
          </div>

          {/* Leaderboard List */}
          {loading ? (
            <div className="loading"><div className="spinner"></div></div>
          ) : leaderboard.length === 0 ? (
            <p style={{ textAlign: 'center', color: 'var(--text-secondary)' }}>No data available</p>
          ) : (
            <div style={{ display: 'grid', gap: '1rem' }}>
              {leaderboard.map((entry) => (
                <div
                  key={entry.id}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    padding: '1rem',
                    backgroundColor: entry.rank <= 3 ? 'rgba(59, 130, 246, 0.1)' : 'var(--bg-secondary)',
                    borderRadius: '0.5rem',
                    border: entry.rank <= 3 ? '1px solid var(--primary-color)' : 'none',
                  }}
                >
                  <div style={{ fontSize: '1.5rem', fontWeight: 'bold', width: '3rem', textAlign: 'center' }}>
                    {entry.rank === 1 ? '🥇' : entry.rank === 2 ? '🥈' : entry.rank === 3 ? '🥉' : entry.rank}
                  </div>
                  <div style={{ flex: 1, marginLeft: '1rem' }}>
                    <p style={{ fontWeight: 'bold' }}>{entry.displayName || 'Anonymous'}</p>
                    <p style={{ fontSize: '0.875rem', color: 'var(--text-secondary)' }}>
                      {type === 'points' && `${entry.stats?.points || 0} points`}
                      {type === 'distance' && `${(entry.stats?.totalDistance || 0).toFixed(2)} km`}
                      {type === 'rides' && `${entry.stats?.totalRides || 0} rides`}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </main>
    </div>
  );
};

export default Leaderboard;
