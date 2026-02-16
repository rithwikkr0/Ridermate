import React from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth';

const Dashboard: React.FC = () => {
  const { user, logout } = useAuth();

  return (
    <div style={{ minHeight: '100vh', backgroundColor: 'var(--bg-secondary)' }}>
      {/* Header */}
      <header style={{ backgroundColor: 'var(--bg-color)', borderBottom: '1px solid var(--border-color)', padding: '1rem' }}>
        <div className="container" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <h1 style={{ color: 'var(--primary-color)' }}>🚴 RiderMate</h1>
          <nav style={{ display: 'flex', gap: '1rem', alignItems: 'center' }}>
            <Link to="/" style={{ textDecoration: 'none', color: 'var(--text-color)' }}>Dashboard</Link>
            <Link to="/ride" style={{ textDecoration: 'none', color: 'var(--text-color)' }}>Ride</Link>
            <Link to="/ai" style={{ textDecoration: 'none', color: 'var(--text-color)' }}>AI Coach</Link>
            <Link to="/social" style={{ textDecoration: 'none', color: 'var(--text-color)' }}>Social</Link>
            <Link to="/leaderboard" style={{ textDecoration: 'none', color: 'var(--text-color)' }}>Leaderboard</Link>
            <Link to="/analytics" style={{ textDecoration: 'none', color: 'var(--text-color)' }}>Analytics</Link>
            <Link to="/profile" style={{ textDecoration: 'none', color: 'var(--text-color)' }}>Profile</Link>
            <button onClick={logout} className="btn btn-danger" style={{ fontSize: '0.875rem', padding: '0.375rem 0.75rem' }}>
              Logout
            </button>
          </nav>
        </div>
      </header>

      {/* Main Content */}
      <main className="container" style={{ paddingTop: '2rem', paddingBottom: '2rem' }}>
        <h2 style={{ marginBottom: '2rem' }}>Welcome, {user?.email}!</h2>

        {/* Quick Stats */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))', gap: '1.5rem', marginBottom: '2rem' }}>
          <div className="card">
            <h3 style={{ color: 'var(--text-secondary)', fontSize: '0.875rem', marginBottom: '0.5rem' }}>Total Rides</h3>
            <p style={{ fontSize: '2rem', fontWeight: 'bold', color: 'var(--primary-color)' }}>0</p>
          </div>
          <div className="card">
            <h3 style={{ color: 'var(--text-secondary)', fontSize: '0.875rem', marginBottom: '0.5rem' }}>Total Distance</h3>
            <p style={{ fontSize: '2rem', fontWeight: 'bold', color: 'var(--secondary-color)' }}>0 km</p>
          </div>
          <div className="card">
            <h3 style={{ color: 'var(--text-secondary)', fontSize: '0.875rem', marginBottom: '0.5rem' }}>Points</h3>
            <p style={{ fontSize: '2rem', fontWeight: 'bold', color: 'var(--warning-color)' }}>0</p>
          </div>
          <div className="card">
            <h3 style={{ color: 'var(--text-secondary)', fontSize: '0.875rem', marginBottom: '0.5rem' }}>Current Streak</h3>
            <p style={{ fontSize: '2rem', fontWeight: 'bold', color: 'var(--danger-color)' }}>0 days</p>
          </div>
        </div>

        {/* Quick Actions */}
        <div className="card" style={{ marginBottom: '2rem' }}>
          <h3 style={{ marginBottom: '1rem' }}>Quick Actions</h3>
          <div style={{ display: 'flex', gap: '1rem', flexWrap: 'wrap' }}>
            <Link to="/ride" className="btn btn-primary">Start New Ride</Link>
            <Link to="/ai" className="btn btn-secondary">Chat with AI Coach</Link>
            <Link to="/social" className="btn btn-primary">Find Riding Partners</Link>
          </div>
        </div>

        {/* Recent Rides */}
        <div className="card">
          <h3 style={{ marginBottom: '1rem' }}>Recent Rides</h3>
          <p style={{ color: 'var(--text-secondary)' }}>No rides yet. Start your first ride to see it here!</p>
        </div>
      </main>
    </div>
  );
};

export default Dashboard;
