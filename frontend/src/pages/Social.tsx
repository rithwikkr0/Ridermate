import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { socialAPI } from '../services/api';

const Social: React.FC = () => {
  const [friends, setFriends] = useState<any[]>([]);
  const [rooms, setRooms] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      const [friendsRes, roomsRes] = await Promise.all([
        socialAPI.getFriends(),
        socialAPI.getRooms(),
      ]);
      setFriends(friendsRes.data.friends);
      setRooms(roomsRes.data.rooms);
    } catch (error) {
      console.error('Error loading social data:', error);
    } finally {
      setLoading(false);
    }
  };

  const createRoom = async () => {
    const name = prompt('Enter room name:');
    if (!name) return;

    try {
      await socialAPI.createRoom(name);
      loadData();
    } catch (error) {
      console.error('Error creating room:', error);
      alert('Failed to create room');
    }
  };

  return (
    <div style={{ minHeight: '100vh', backgroundColor: 'var(--bg-secondary)' }}>
      <header style={{ backgroundColor: 'var(--bg-color)', borderBottom: '1px solid var(--border-color)', padding: '1rem' }}>
        <div className="container" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <Link to="/" style={{ textDecoration: 'none', color: 'var(--primary-color)', fontSize: '1.5rem' }}>
            ← Back
          </Link>
          <h1>👥 Social</h1>
        </div>
      </header>

      <main className="container" style={{ paddingTop: '2rem', paddingBottom: '2rem' }}>
        {/* Friends Section */}
        <div className="card" style={{ marginBottom: '2rem' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1rem' }}>
            <h2>Friends</h2>
            <button className="btn btn-primary">Add Friend</button>
          </div>
          
          {loading ? (
            <div className="loading"><div className="spinner"></div></div>
          ) : friends.length === 0 ? (
            <p style={{ color: 'var(--text-secondary)' }}>No friends yet. Add some friends to ride together!</p>
          ) : (
            <div style={{ display: 'grid', gap: '1rem' }}>
              {friends.map((friend) => (
                <div key={friend.id} style={{ padding: '1rem', backgroundColor: 'var(--bg-secondary)', borderRadius: '0.5rem' }}>
                  <p>Friend ID: {friend.friendId}</p>
                  <p style={{ fontSize: '0.875rem', color: 'var(--text-secondary)' }}>Status: {friend.status}</p>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Ride Rooms Section */}
        <div className="card">
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1rem' }}>
            <h2>Ride Rooms</h2>
            <button onClick={createRoom} className="btn btn-primary">Create Room</button>
          </div>
          
          {loading ? (
            <div className="loading"><div className="spinner"></div></div>
          ) : rooms.length === 0 ? (
            <p style={{ color: 'var(--text-secondary)' }}>No active ride rooms. Create one to start riding with friends!</p>
          ) : (
            <div style={{ display: 'grid', gap: '1rem' }}>
              {rooms.map((room) => (
                <div key={room.id} style={{ padding: '1rem', backgroundColor: 'var(--bg-secondary)', borderRadius: '0.5rem' }}>
                  <h3>{room.name}</h3>
                  <p style={{ fontSize: '0.875rem', color: 'var(--text-secondary)' }}>
                    Participants: {room.participants.length}
                  </p>
                  <button className="btn btn-secondary" style={{ marginTop: '0.5rem' }}>
                    Join Room
                  </button>
                </div>
              ))}
            </div>
          )}
        </div>
      </main>
    </div>
  );
};

export default Social;
