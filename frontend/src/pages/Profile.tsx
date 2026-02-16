import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth';
import { userAPI } from '../services/api';

const Profile: React.FC = () => {
  const { user, logout } = useAuth();
  const [profile, setProfile] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [editing, setEditing] = useState(false);
  const [displayName, setDisplayName] = useState('');

  useEffect(() => {
    loadProfile();
  }, []);

  const loadProfile = async () => {
    try {
      const response = await userAPI.getMe();
      setProfile(response.data);
      setDisplayName(response.data.displayName || '');
    } catch (error) {
      console.error('Error loading profile:', error);
    } finally {
      setLoading(false);
    }
  };

  const saveProfile = async () => {
    try {
      await userAPI.updateMe({ displayName });
      setEditing(false);
      loadProfile();
    } catch (error) {
      console.error('Error updating profile:', error);
      alert('Failed to update profile');
    }
  };

  return (
    <div style={{ minHeight: '100vh', backgroundColor: 'var(--bg-secondary)' }}>
      <header style={{ backgroundColor: 'var(--bg-color)', borderBottom: '1px solid var(--border-color)', padding: '1rem' }}>
        <div className="container" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <Link to="/" style={{ textDecoration: 'none', color: 'var(--primary-color)', fontSize: '1.5rem' }}>
            ← Back
          </Link>
          <h1>👤 Profile</h1>
        </div>
      </header>

      <main className="container" style={{ paddingTop: '2rem', paddingBottom: '2rem', maxWidth: '800px' }}>
        {loading ? (
          <div className="loading"><div className="spinner"></div></div>
        ) : (
          <>
            {/* Profile Info */}
            <div className="card" style={{ marginBottom: '2rem' }}>
              <div style={{ display: 'flex', alignItems: 'center', marginBottom: '2rem' }}>
                <div style={{ 
                  width: '80px', 
                  height: '80px', 
                  borderRadius: '50%', 
                  backgroundColor: 'var(--primary-color)', 
                  display: 'flex', 
                  alignItems: 'center', 
                  justifyContent: 'center',
                  color: 'white',
                  fontSize: '2rem',
                  marginRight: '1.5rem'
                }}>
                  {(displayName || user?.email || 'U')[0].toUpperCase()}
                </div>
                <div>
                  <h2>{displayName || 'Anonymous Rider'}</h2>
                  <p style={{ color: 'var(--text-secondary)' }}>{user?.email}</p>
                </div>
              </div>

              {editing ? (
                <div>
                  <label style={{ display: 'block', marginBottom: '0.5rem' }}>Display Name</label>
                  <input
                    type="text"
                    className="input"
                    value={displayName}
                    onChange={(e) => setDisplayName(e.target.value)}
                    style={{ marginBottom: '1rem' }}
                  />
                  <div style={{ display: 'flex', gap: '1rem' }}>
                    <button onClick={saveProfile} className="btn btn-primary">Save</button>
                    <button onClick={() => setEditing(false)} className="btn btn-secondary">Cancel</button>
                  </div>
                </div>
              ) : (
                <button onClick={() => setEditing(true)} className="btn btn-primary">Edit Profile</button>
              )}
            </div>

            {/* Stats */}
            <div className="card" style={{ marginBottom: '2rem' }}>
              <h3 style={{ marginBottom: '1rem' }}>Statistics</h3>
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: '1rem' }}>
                <div>
                  <p style={{ color: 'var(--text-secondary)', fontSize: '0.875rem' }}>Total Rides</p>
                  <p style={{ fontSize: '1.5rem', fontWeight: 'bold' }}>{profile?.stats?.totalRides || 0}</p>
                </div>
                <div>
                  <p style={{ color: 'var(--text-secondary)', fontSize: '0.875rem' }}>Total Distance</p>
                  <p style={{ fontSize: '1.5rem', fontWeight: 'bold' }}>{(profile?.stats?.totalDistance || 0).toFixed(2)} km</p>
                </div>
                <div>
                  <p style={{ color: 'var(--text-secondary)', fontSize: '0.875rem' }}>Points</p>
                  <p style={{ fontSize: '1.5rem', fontWeight: 'bold' }}>{profile?.stats?.points || 0}</p>
                </div>
                <div>
                  <p style={{ color: 'var(--text-secondary)', fontSize: '0.875rem' }}>Current Streak</p>
                  <p style={{ fontSize: '1.5rem', fontWeight: 'bold' }}>{profile?.stats?.streak || 0} days</p>
                </div>
              </div>
            </div>

            {/* Settings */}
            <div className="card" style={{ marginBottom: '2rem' }}>
              <h3 style={{ marginBottom: '1rem' }}>Settings</h3>
              <div style={{ display: 'grid', gap: '1rem' }}>
                <label style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                  <input type="checkbox" defaultChecked />
                  Share location with friends
                </label>
                <label style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                  <input type="checkbox" defaultChecked />
                  Share rides publicly
                </label>
                <label style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                  <input type="checkbox" defaultChecked />
                  Show in leaderboard
                </label>
              </div>
            </div>

            {/* Logout */}
            <div className="card">
              <button onClick={logout} className="btn btn-danger" style={{ width: '100%' }}>
                Logout
              </button>
            </div>
          </>
        )}
      </main>
    </div>
  );
};

export default Profile;
