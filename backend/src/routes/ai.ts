import { Router } from 'express';
import { authenticate } from '../middleware/auth';
import { getFirestore } from '../config/firebase';
import OpenAI from 'openai';
import { config } from '../config';
import { AIMessage } from '../types';

const router = Router();

let openai: OpenAI | null = null;

if (config.openai.apiKey) {
  openai = new OpenAI({ apiKey: config.openai.apiKey });
}

// Chat with AI
router.post('/chat', authenticate, async (req, res) => {
  try {
    if (!openai) {
      return res.status(503).json({ 
        error: 'AI service not available. Please configure OpenAI API key.' 
      });
    }

    const db = getFirestore();
    const { message } = req.body;

    // Save user message
    const userMessage: Partial<AIMessage> = {
      userId: req.user!.uid,
      role: 'user',
      content: message,
      timestamp: new Date(),
    };
    await db.collection('aiMessages').add(userMessage);

    // Get AI response
    const completion = await openai.chat.completions.create({
      model: 'gpt-3.5-turbo',
      messages: [
        {
          role: 'system',
          content: 'You are RiderMate AI, a helpful cycling companion that provides coaching, safety tips, and motivation to riders.',
        },
        {
          role: 'user',
          content: message,
        },
      ],
    });

    const aiResponse = completion.choices[0].message.content;

    // Save AI response
    const assistantMessage: Partial<AIMessage> = {
      userId: req.user!.uid,
      role: 'assistant',
      content: aiResponse || 'I apologize, I could not generate a response.',
      timestamp: new Date(),
    };
    await db.collection('aiMessages').add(assistantMessage);

    res.json({ 
      message: aiResponse,
      timestamp: new Date() 
    });
  } catch (error) {
    res.status(500).json({ error: 'Error communicating with AI' });
  }
});

// Get chat history
router.get('/chat/history', authenticate, async (req, res) => {
  try {
    const db = getFirestore();
    const { limit = 50 } = req.query;

    const messagesSnapshot = await db.collection('aiMessages')
      .where('userId', '==', req.user!.uid)
      .orderBy('timestamp', 'desc')
      .limit(Number(limit))
      .get();

    const messages = messagesSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
    })).reverse();

    res.json({ messages });
  } catch (error) {
    res.status(500).json({ error: 'Error fetching chat history' });
  }
});

// Generate weekly summary
router.post('/summary/weekly', authenticate, async (req, res) => {
  try {
    if (!openai) {
      return res.status(503).json({ 
        error: 'AI service not available. Please configure OpenAI API key.' 
      });
    }

    const db = getFirestore();
    
    // Get rides from the last week
    const weekAgo = new Date();
    weekAgo.setDate(weekAgo.getDate() - 7);

    const ridesSnapshot = await db.collection('rides')
      .where('userId', '==', req.user!.uid)
      .where('createdAt', '>=', weekAgo)
      .where('status', '==', 'completed')
      .get();

    const rides = ridesSnapshot.docs.map(doc => doc.data());

    const stats = {
      totalRides: rides.length,
      totalDistance: rides.reduce((sum, ride) => sum + ride.distance, 0),
      totalDuration: rides.reduce((sum, ride) => sum + ride.duration, 0),
      averageSpeed: rides.reduce((sum, ride) => sum + ride.averageSpeed, 0) / (rides.length || 1),
    };

    // Generate AI summary
    const completion = await openai.chat.completions.create({
      model: 'gpt-3.5-turbo',
      messages: [
        {
          role: 'system',
          content: 'You are RiderMate AI. Generate a motivating weekly summary for a cyclist.',
        },
        {
          role: 'user',
          content: `Generate a weekly summary with these stats: ${JSON.stringify(stats)}`,
        },
      ],
    });

    const summary = completion.choices[0].message.content;

    res.json({ 
      stats,
      summary,
      generatedAt: new Date() 
    });
  } catch (error) {
    res.status(500).json({ error: 'Error generating weekly summary' });
  }
});

export default router;
