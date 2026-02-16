import { Router } from 'express';
import { authenticate } from '../middleware/auth';
import { getFirestore } from '../config/firebase';
import { User } from '../types';

const router = Router();

// Get current user profile
router.get('/me', authenticate, async (req, res) => {
  try {
    const db = getFirestore();
    const userDoc = await db.collection('users').doc(req.user!.uid).get();

    if (!userDoc.exists) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json(userDoc.data());
  } catch (error) {
    res.status(500).json({ error: 'Error fetching user profile' });
  }
});

// Update user profile
router.put('/me', authenticate, async (req, res) => {
  try {
    const db = getFirestore();
    const { displayName, photoURL, privacySettings } = req.body;

    const updateData: Partial<User> = {
      updatedAt: new Date(),
    };

    if (displayName) updateData.displayName = displayName;
    if (photoURL) updateData.photoURL = photoURL;
    if (privacySettings) updateData.privacySettings = privacySettings;

    await db.collection('users').doc(req.user!.uid).update(updateData);

    res.json({ message: 'Profile updated successfully', data: updateData });
  } catch (error) {
    res.status(500).json({ error: 'Error updating profile' });
  }
});

// Get user by ID
router.get('/:userId', authenticate, async (req, res) => {
  try {
    const db = getFirestore();
    const userDoc = await db.collection('users').doc(req.params.userId).get();

    if (!userDoc.exists) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json(userDoc.data());
  } catch (error) {
    res.status(500).json({ error: 'Error fetching user' });
  }
});

// Get user stats
router.get('/me/stats', authenticate, async (req, res) => {
  try {
    const db = getFirestore();
    const userDoc = await db.collection('users').doc(req.user!.uid).get();

    if (!userDoc.exists) {
      return res.status(404).json({ error: 'User not found' });
    }

    const userData = userDoc.data() as User;
    res.json(userData.stats || {});
  } catch (error) {
    res.status(500).json({ error: 'Error fetching user stats' });
  }
});

export default router;
