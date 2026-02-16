import axios from 'axios';
import { auth } from './firebase';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:5000/api';

const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add auth token to requests
api.interceptors.request.use(async (config) => {
  const user = auth.currentUser;
  if (user) {
    const token = await user.getIdToken();
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Auth endpoints
export const authAPI = {
  verify: () => api.get('/auth/verify'),
  logout: () => api.post('/auth/logout'),
};

// User endpoints
export const userAPI = {
  getMe: () => api.get('/users/me'),
  updateMe: (data: any) => api.put('/users/me', data),
  getUser: (userId: string) => api.get(`/users/${userId}`),
  getMyStats: () => api.get('/users/me/stats'),
};

// Ride endpoints
export const rideAPI = {
  startRide: (data: any) => api.post('/rides/start', data),
  updateLocation: (rideId: string, data: any) => 
    api.put(`/rides/${rideId}/location`, data),
  endRide: (rideId: string) => api.post(`/rides/${rideId}/end`),
  getRides: (params?: any) => api.get('/rides', { params }),
  getRide: (rideId: string) => api.get(`/rides/${rideId}`),
};

// Social endpoints
export const socialAPI = {
  sendFriendRequest: (friendId: string) => 
    api.post('/social/friends/request', { friendId }),
  acceptFriendRequest: (requestId: string) => 
    api.put(`/social/friends/${requestId}/accept`),
  getFriends: () => api.get('/social/friends'),
  createRoom: (name: string) => api.post('/social/rooms', { name }),
  joinRoom: (roomId: string) => api.post(`/social/rooms/${roomId}/join`),
  getRooms: () => api.get('/social/rooms'),
};

// AI endpoints
export const aiAPI = {
  chat: (message: string) => api.post('/ai/chat', { message }),
  getChatHistory: (limit?: number) => 
    api.get('/ai/chat/history', { params: { limit } }),
  getWeeklySummary: () => api.post('/ai/summary/weekly'),
};

// Gamification endpoints
export const gamificationAPI = {
  getAchievements: () => api.get('/gamification/achievements'),
  getMyAchievements: () => api.get('/gamification/achievements/me'),
  getLeaderboard: (type?: string, limit?: number) => 
    api.get('/gamification/leaderboard', { params: { type, limit } }),
  addPoints: (points: number, reason: string) => 
    api.post('/gamification/points/add', { points, reason }),
};

// Analytics endpoints
export const analyticsAPI = {
  getRideAnalytics: (period?: number) => 
    api.get('/analytics/rides', { params: { period } }),
  getTrends: () => api.get('/analytics/trends'),
  getSafetyAnalytics: () => api.get('/analytics/safety'),
};

export default api;
