import { Router } from 'express';
import { authenticate } from '../middleware/auth';
import { getFirestore } from '../config/firebase';
import { Friend, RideRoom } from '../types';

const router = Router();

// Send friend request
router.post('/friends/request', authenticate, async (req, res) => {
  try {
    const db = getFirestore();
    const { friendId } = req.body;

    if (friendId === req.user!.uid) {
      return res.status(400).json({ error: 'Cannot add yourself as friend' });
    }

    const friendData: Partial<Friend> = {
      userId: req.user!.uid,
      friendId,
      status: 'pending',
      createdAt: new Date(),
    };

    const friendRef = await db.collection('friends').add(friendData);

    res.status(201).json({ 
      message: 'Friend request sent', 
      requestId: friendRef.id 
    });
  } catch (error) {
    res.status(500).json({ error: 'Error sending friend request' });
  }
});

// Accept friend request
router.put('/friends/:requestId/accept', authenticate, async (req, res) => {
  try {
    const db = getFirestore();
    const { requestId } = req.params;

    const friendDoc = await db.collection('friends').doc(requestId).get();
    if (!friendDoc.exists) {
      return res.status(404).json({ error: 'Friend request not found' });
    }

    await db.collection('friends').doc(requestId).update({
      status: 'accepted',
    });

    res.json({ message: 'Friend request accepted' });
  } catch (error) {
    res.status(500).json({ error: 'Error accepting friend request' });
  }
});

// Get friends list
router.get('/friends', authenticate, async (req, res) => {
  try {
    const db = getFirestore();
    
    const friendsSnapshot = await db.collection('friends')
      .where('userId', '==', req.user!.uid)
      .where('status', '==', 'accepted')
      .get();

    const friends = friendsSnapshot.docs.map(doc => ({ 
      id: doc.id, 
      ...doc.data() 
    }));

    res.json({ friends });
  } catch (error) {
    res.status(500).json({ error: 'Error fetching friends' });
  }
});

// Create ride room
router.post('/rooms', authenticate, async (req, res) => {
  try {
    const db = getFirestore();
    const { name } = req.body;

    const roomData: Partial<RideRoom> = {
      name,
      creatorId: req.user!.uid,
      participants: [req.user!.uid],
      isActive: true,
      createdAt: new Date(),
    };

    const roomRef = await db.collection('rideRooms').add(roomData);

    res.status(201).json({ 
      message: 'Ride room created', 
      roomId: roomRef.id,
      data: roomData 
    });
  } catch (error) {
    res.status(500).json({ error: 'Error creating ride room' });
  }
});

// Join ride room
router.post('/rooms/:roomId/join', authenticate, async (req, res) => {
  try {
    const db = getFirestore();
    const { roomId } = req.params;

    const roomDoc = await db.collection('rideRooms').doc(roomId).get();
    if (!roomDoc.exists) {
      return res.status(404).json({ error: 'Room not found' });
    }

    const roomData = roomDoc.data() as RideRoom;
    
    if (roomData.participants.includes(req.user!.uid)) {
      return res.status(400).json({ error: 'Already in room' });
    }

    await db.collection('rideRooms').doc(roomId).update({
      participants: [...roomData.participants, req.user!.uid],
    });

    res.json({ message: 'Joined ride room' });
  } catch (error) {
    res.status(500).json({ error: 'Error joining ride room' });
  }
});

// Get active ride rooms
router.get('/rooms', authenticate, async (req, res) => {
  try {
    const db = getFirestore();
    
    const roomsSnapshot = await db.collection('rideRooms')
      .where('isActive', '==', true)
      .orderBy('createdAt', 'desc')
      .limit(20)
      .get();

    const rooms = roomsSnapshot.docs.map(doc => ({ 
      id: doc.id, 
      ...doc.data() 
    }));

    res.json({ rooms });
  } catch (error) {
    res.status(500).json({ error: 'Error fetching rooms' });
  }
});

export default router;
