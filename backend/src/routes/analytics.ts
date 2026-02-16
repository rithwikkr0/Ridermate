import { Router } from 'express';
import { authenticate } from '../middleware/auth';
import { getFirestore } from '../config/firebase';

const router = Router();

// Get ride analytics
router.get('/rides', authenticate, async (req, res) => {
  try {
    const db = getFirestore();
    const { period = '30' } = req.query;

    const daysAgo = new Date();
    daysAgo.setDate(daysAgo.getDate() - Number(period));

    const ridesSnapshot = await db.collection('rides')
      .where('userId', '==', req.user!.uid)
      .where('createdAt', '>=', daysAgo)
      .where('status', '==', 'completed')
      .orderBy('createdAt', 'desc')
      .get();

    const rides = ridesSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
    }));

    const analytics = {
      totalRides: rides.length,
      totalDistance: rides.reduce((sum, ride) => sum + (ride.distance || 0), 0),
      totalDuration: rides.reduce((sum, ride) => sum + (ride.duration || 0), 0),
      averageSpeed: rides.reduce((sum, ride) => sum + (ride.averageSpeed || 0), 0) / (rides.length || 1),
      maxSpeed: Math.max(...rides.map(ride => ride.maxSpeed || 0)),
      averageSafetyScore: rides.reduce((sum, ride) => sum + (ride.safetyScore || 0), 0) / (rides.length || 1),
    };

    res.json({ analytics, rides });
  } catch (error) {
    res.status(500).json({ error: 'Error fetching analytics' });
  }
});

// Get performance trends
router.get('/trends', authenticate, async (req, res) => {
  try {
    const db = getFirestore();
    
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const ridesSnapshot = await db.collection('rides')
      .where('userId', '==', req.user!.uid)
      .where('createdAt', '>=', thirtyDaysAgo)
      .where('status', '==', 'completed')
      .orderBy('createdAt', 'asc')
      .get();

    const rides = ridesSnapshot.docs.map(doc => doc.data());

    // Group by week
    const weeklyData: { [key: string]: any } = {};
    
    rides.forEach(ride => {
      const date = ride.createdAt.toDate ? ride.createdAt.toDate() : new Date(ride.createdAt);
      // Calculate ISO week number
      const firstDayOfYear = new Date(date.getFullYear(), 0, 1);
      const daysSinceFirstDay = Math.floor((date.getTime() - firstDayOfYear.getTime()) / (24 * 60 * 60 * 1000));
      const weekNumber = Math.ceil((daysSinceFirstDay + firstDayOfYear.getDay() + 1) / 7);
      const weekKey = `${date.getFullYear()}-W${weekNumber}`;
      
      if (!weeklyData[weekKey]) {
        weeklyData[weekKey] = {
          rides: 0,
          distance: 0,
          duration: 0,
        };
      }
      
      weeklyData[weekKey].rides++;
      weeklyData[weekKey].distance += ride.distance || 0;
      weeklyData[weekKey].duration += ride.duration || 0;
    });

    const trends = Object.entries(weeklyData).map(([week, data]) => ({
      week,
      ...data,
    }));

    res.json({ trends });
  } catch (error) {
    res.status(500).json({ error: 'Error fetching trends' });
  }
});

// Get safety analytics
router.get('/safety', authenticate, async (req, res) => {
  try {
    const db = getFirestore();
    
    const ridesSnapshot = await db.collection('rides')
      .where('userId', '==', req.user!.uid)
      .where('status', '==', 'completed')
      .orderBy('createdAt', 'desc')
      .limit(50)
      .get();

    const rides = ridesSnapshot.docs.map(doc => doc.data());

    const safetyAnalytics = {
      averageSafetyScore: rides.reduce((sum, ride) => sum + (ride.safetyScore || 0), 0) / (rides.length || 1),
      totalOverspeeds: rides.reduce((sum, ride) => sum + (ride.overspeeds?.length || 0), 0),
      safeRides: rides.filter(ride => ride.safetyScore >= 80).length,
      riskyRides: rides.filter(ride => ride.safetyScore < 60).length,
    };

    res.json({ safetyAnalytics });
  } catch (error) {
    res.status(500).json({ error: 'Error fetching safety analytics' });
  }
});

export default router;
