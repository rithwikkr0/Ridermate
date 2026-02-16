import { Router } from 'express';
import { authenticate } from '../middleware/auth';
import { getFirestore } from '../config/firebase';
import { Ride, GPSPoint } from '../types';

const router = Router();

// Start a new ride
router.post('/start', authenticate, async (req, res) => {
  try {
    const db = getFirestore();
    const { startLocation } = req.body;

    const rideData: Partial<Ride> = {
      userId: req.user!.uid,
      startTime: new Date(),
      distance: 0,
      duration: 0,
      averageSpeed: 0,
      maxSpeed: 0,
      route: startLocation ? [startLocation] : [],
      overspeeds: [],
      safetyScore: 100,
      status: 'active',
      createdAt: new Date(),
    };

    const rideRef = await db.collection('rides').add(rideData);

    res.status(201).json({ 
      message: 'Ride started', 
      rideId: rideRef.id,
      data: rideData 
    });
  } catch (error) {
    res.status(500).json({ error: 'Error starting ride' });
  }
});

// Update ride location
router.put('/:rideId/location', authenticate, async (req, res) => {
  try {
    const db = getFirestore();
    const { rideId } = req.params;
    const gpsPoint: GPSPoint = req.body;

    const rideDoc = await db.collection('rides').doc(rideId).get();
    if (!rideDoc.exists) {
      return res.status(404).json({ error: 'Ride not found' });
    }

    const rideData = rideDoc.data() as Ride;
    
    // Check if ride belongs to user
    if (rideData.userId !== req.user!.uid) {
      return res.status(403).json({ error: 'Unauthorized' });
    }

    // Add GPS point to route
    const updatedRoute = [...rideData.route, gpsPoint];

    await db.collection('rides').doc(rideId).update({
      route: updatedRoute,
      maxSpeed: Math.max(rideData.maxSpeed, gpsPoint.speed),
    });

    res.json({ message: 'Location updated' });
  } catch (error) {
    res.status(500).json({ error: 'Error updating location' });
  }
});

// End a ride
router.post('/:rideId/end', authenticate, async (req, res) => {
  try {
    const db = getFirestore();
    const { rideId } = req.params;

    const rideDoc = await db.collection('rides').doc(rideId).get();
    if (!rideDoc.exists) {
      return res.status(404).json({ error: 'Ride not found' });
    }

    const rideData = rideDoc.data() as Ride;
    
    if (rideData.userId !== req.user!.uid) {
      return res.status(403).json({ error: 'Unauthorized' });
    }

    const endTime = new Date();
    const startTime = rideData.startTime instanceof Date ? rideData.startTime : (rideData.startTime as any).toDate();
    const duration = (endTime.getTime() - startTime.getTime()) / 1000; // seconds

    await db.collection('rides').doc(rideId).update({
      endTime,
      duration,
      status: 'completed',
    });

    res.json({ message: 'Ride ended', duration });
  } catch (error) {
    res.status(500).json({ error: 'Error ending ride' });
  }
});

// Get user's rides
router.get('/', authenticate, async (req, res) => {
  try {
    const db = getFirestore();
    const { limit = 20, status } = req.query;

    let query = db.collection('rides')
      .where('userId', '==', req.user!.uid)
      .orderBy('createdAt', 'desc')
      .limit(Number(limit));

    if (status) {
      query = query.where('status', '==', status);
    }

    const snapshot = await query.get();
    const rides = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));

    res.json({ rides });
  } catch (error) {
    res.status(500).json({ error: 'Error fetching rides' });
  }
});

// Get ride by ID
router.get('/:rideId', authenticate, async (req, res) => {
  try {
    const db = getFirestore();
    const rideDoc = await db.collection('rides').doc(req.params.rideId).get();

    if (!rideDoc.exists) {
      return res.status(404).json({ error: 'Ride not found' });
    }

    res.json({ id: rideDoc.id, ...rideDoc.data() });
  } catch (error) {
    res.status(500).json({ error: 'Error fetching ride' });
  }
});

export default router;
