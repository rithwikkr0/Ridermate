import { getFirestore } from '../config/firebase.config';
import { User, UserRegistrationData } from '../types/user.types';
import { Ride, StartRideData, EndRideData } from '../types/ride.types';
import { Memory, CreateMemoryData, Friend, FriendRequest } from '../types/other.types';
import { AppError } from '../types/api.types';

const db = getFirestore();

// User operations
export const createUser = async (userData: Omit<User, 'id'>): Promise<User> => {
  const userRef = db.collection('users').doc();
  const user: User = {
    id: userRef.id,
    ...userData,
  };
  await userRef.set(user);
  return user;
};

export const getUserById = async (userId: string): Promise<User | null> => {
  const userDoc = await db.collection('users').doc(userId).get();
  if (!userDoc.exists) {
    return null;
  }
  return userDoc.data() as User;
};

export const getUserByEmail = async (email: string): Promise<User | null> => {
  const snapshot = await db.collection('users').where('email', '==', email).limit(1).get();
  if (snapshot.empty) {
    return null;
  }
  return snapshot.docs[0].data() as User;
};

export const updateUser = async (userId: string, data: Partial<User>): Promise<void> => {
  await db.collection('users').doc(userId).update({
    ...data,
    updatedAt: new Date(),
  });
};

// Ride operations
export const createRide = async (rideData: Omit<Ride, 'id'>): Promise<Ride> => {
  const rideRef = db.collection('rides').doc();
  const ride: Ride = {
    id: rideRef.id,
    ...rideData,
  };
  await rideRef.set(ride);
  return ride;
};

export const getRideById = async (rideId: string): Promise<Ride | null> => {
  const rideDoc = await db.collection('rides').doc(rideId).get();
  if (!rideDoc.exists) {
    return null;
  }
  return rideDoc.data() as Ride;
};

export const updateRide = async (rideId: string, data: Partial<Ride>): Promise<void> => {
  await db.collection('rides').doc(rideId).update({
    ...data,
    updatedAt: new Date(),
  });
};

export const getUserRides = async (userId: string, limit = 50): Promise<Ride[]> => {
  const snapshot = await db
    .collection('rides')
    .where('userId', '==', userId)
    .orderBy('startTime', 'desc')
    .limit(limit)
    .get();
  
  return snapshot.docs.map(doc => doc.data() as Ride);
};

// Memory operations
export const createMemory = async (memoryData: Omit<Memory, 'id'>): Promise<Memory> => {
  const memoryRef = db.collection('memories').doc();
  const memory: Memory = {
    id: memoryRef.id,
    ...memoryData,
  };
  await memoryRef.set(memory);
  return memory;
};

export const getUserMemories = async (userId: string, limit = 50): Promise<Memory[]> => {
  const snapshot = await db
    .collection('memories')
    .where('userId', '==', userId)
    .orderBy('createdAt', 'desc')
    .limit(limit)
    .get();
  
  return snapshot.docs.map(doc => doc.data() as Memory);
};

// Friend operations
export const createFriendRequest = async (
  friendData: Omit<Friend, 'id'>
): Promise<Friend> => {
  const friendRef = db.collection('friends').doc();
  const friend: Friend = {
    id: friendRef.id,
    ...friendData,
  };
  await friendRef.set(friend);
  return friend;
};

export const getUserFriends = async (userId: string): Promise<Friend[]> => {
  const snapshot = await db
    .collection('friends')
    .where('userId', '==', userId)
    .where('status', '==', 'accepted')
    .get();
  
  return snapshot.docs.map(doc => doc.data() as Friend);
};

// Leaderboard operations
export const getLeaderboard = async (limit = 10) => {
  const snapshot = await db
    .collection('users')
    .orderBy('stats.totalDistance', 'desc')
    .limit(limit)
    .get();
  
  return snapshot.docs.map((doc, index) => {
    const user = doc.data() as User;
    return {
      userId: user.id,
      username: user.username,
      avatar: user.profile?.avatar,
      totalDistance: user.stats?.totalDistance || 0,
      totalRides: user.stats?.totalRides || 0,
      rank: index + 1,
    };
  });
};
