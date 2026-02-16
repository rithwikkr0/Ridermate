import { Router } from 'express';
import { authenticate } from '../middleware/auth';
import { getFirestore } from '../config/firebase';
import { Achievement, UserAchievement } from '../types';

const router = Router();

// Get all achievements
router.get('/achievements', authenticate, async (req, res) => {
  try {
    const db = getFirestore();
    
    const achievementsSnapshot = await db.collection('achievements').get();
    const achievements = achievementsSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
    }));

    res.json({ achievements });
  } catch (error) {
    res.status(500).json({ error: 'Error fetching achievements' });
  }
});

// Get user achievements
router.get('/achievements/me', authenticate, async (req, res) => {
  try {
    const db = getFirestore();
    
    const userAchievementsSnapshot = await db.collection('userAchievements')
      .where('userId', '==', req.user!.uid)
      .get();

    const userAchievements = userAchievementsSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
    }));

    res.json({ achievements: userAchievements });
  } catch (error) {
    res.status(500).json({ error: 'Error fetching user achievements' });
  }
});

// Get leaderboard
router.get('/leaderboard', authenticate, async (req, res) => {
  try {
    const db = getFirestore();
    const { limit = 10, type = 'points' } = req.query;

    let orderField = 'stats.points';
    if (type === 'distance') orderField = 'stats.totalDistance';
    if (type === 'rides') orderField = 'stats.totalRides';

    const usersSnapshot = await db.collection('users')
      .orderBy(orderField, 'desc')
      .limit(Number(limit))
      .get();

    const leaderboard = usersSnapshot.docs.map((doc, index) => ({
      rank: index + 1,
      id: doc.id,
      displayName: doc.data().displayName,
      photoURL: doc.data().photoURL,
      stats: doc.data().stats,
    }));

    res.json({ leaderboard });
  } catch (error) {
    res.status(500).json({ error: 'Error fetching leaderboard' });
  }
});

// Update user points
router.post('/points/add', authenticate, async (req, res) => {
  try {
    const db = getFirestore();
    const { points, reason } = req.body;

    const userRef = db.collection('users').doc(req.user!.uid);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      return res.status(404).json({ error: 'User not found' });
    }

    const userData = userDoc.data();
    const currentPoints = userData?.stats?.points || 0;

    await userRef.update({
      'stats.points': currentPoints + points,
    });

    res.json({ 
      message: 'Points added',
      newTotal: currentPoints + points,
      reason 
    });
  } catch (error) {
    res.status(500).json({ error: 'Error updating points' });
  }
});

export default router;
