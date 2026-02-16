import { openai, OPENAI_MODEL } from '../config/openai.config';
import { Ride } from '../types/ride.types';
import { ChatMessage } from '../types/other.types';

export const analyzeRide = async (ride: Ride): Promise<{
  safetyScore: number;
  insights: string[];
  suggestions: string[];
}> => {
  try {
    const rideInfo = `
Ride Analysis Request:
- Duration: ${ride.stats.duration} seconds
- Distance: ${ride.stats.distance} meters
- Average Speed: ${ride.stats.averageSpeed} m/s
- Max Speed: ${ride.stats.maxSpeed} m/s
- Elevation Gain: ${ride.stats.elevationGain} meters
- Route Points: ${ride.route.length}
`;

    const prompt = `You are an expert cycling coach and safety analyst. Analyze the following ride data and provide:
1. A safety score (0-100) based on speed patterns, route complexity, and general cycling safety
2. Key insights about the ride (2-3 points)
3. Suggestions for improvement (2-3 points)

${rideInfo}

Respond in JSON format:
{
  "safetyScore": <number>,
  "insights": ["insight1", "insight2", "insight3"],
  "suggestions": ["suggestion1", "suggestion2", "suggestion3"]
}`;

    const response = await openai.chat.completions.create({
      model: OPENAI_MODEL,
      messages: [
        {
          role: 'system',
          content: 'You are an expert cycling coach and safety analyst. Always respond with valid JSON.',
        },
        {
          role: 'user',
          content: prompt,
        },
      ],
      temperature: 0.7,
      max_tokens: 500,
    });

    const content = response.choices[0]?.message?.content || '{}';
    const analysis = JSON.parse(content);

    return {
      safetyScore: analysis.safetyScore || 75,
      insights: analysis.insights || [],
      suggestions: analysis.suggestions || [],
    };
  } catch (error) {
    console.error('Error analyzing ride with OpenAI:', error);
    // Return default values if OpenAI fails
    return {
      safetyScore: 75,
      insights: ['Unable to analyze ride at this time'],
      suggestions: ['Try again later'],
    };
  }
};

export const generateWeeklyAnalysis = async (
  rides: Ride[]
): Promise<string> => {
  try {
    const totalDistance = rides.reduce((sum, ride) => sum + ride.stats.distance, 0);
    const totalDuration = rides.reduce((sum, ride) => sum + ride.stats.duration, 0);
    const avgSpeed = rides.length > 0 
      ? rides.reduce((sum, ride) => sum + ride.stats.averageSpeed, 0) / rides.length 
      : 0;

    const prompt = `You are a cycling coach providing a weekly summary. Based on these stats:
- Total rides: ${rides.length}
- Total distance: ${(totalDistance / 1000).toFixed(2)} km
- Total duration: ${(totalDuration / 3600).toFixed(2)} hours
- Average speed: ${(avgSpeed * 3.6).toFixed(2)} km/h

Provide a brief, encouraging weekly summary (2-3 sentences) highlighting achievements and suggesting areas for improvement.`;

    const response = await openai.chat.completions.create({
      model: OPENAI_MODEL,
      messages: [
        {
          role: 'system',
          content: 'You are an encouraging cycling coach.',
        },
        {
          role: 'user',
          content: prompt,
        },
      ],
      temperature: 0.8,
      max_tokens: 200,
    });

    return response.choices[0]?.message?.content || 'Great week of riding! Keep it up!';
  } catch (error) {
    console.error('Error generating weekly analysis:', error);
    return 'Great week of riding! Keep up the good work.';
  }
};

export const chatWithAI = async (
  message: string,
  conversationHistory: ChatMessage[] = []
): Promise<string> => {
  try {
    const messages = [
      {
        role: 'system' as const,
        content: 'You are RiderMate AI, a friendly and knowledgeable cycling assistant. Help users with cycling tips, route suggestions, safety advice, and motivation. Keep responses concise and helpful.',
      },
      ...conversationHistory.map(msg => ({
        role: msg.role,
        content: msg.content,
      })),
      {
        role: 'user' as const,
        content: message,
      },
    ];

    const response = await openai.chat.completions.create({
      model: OPENAI_MODEL,
      messages,
      temperature: 0.8,
      max_tokens: 300,
    });

    return response.choices[0]?.message?.content || 'I apologize, but I could not generate a response at this time.';
  } catch (error) {
    console.error('Error chatting with OpenAI:', error);
    return 'I apologize, but I am having trouble processing your request right now. Please try again later.';
  }
};

export const calculateSafetyScore = (ride: Ride): number => {
  let score = 100;

  // Penalize very high speeds
  if (ride.stats.maxSpeed > 15) { // >= 54 km/h
    score -= 10;
  }

  // Penalize very long rides without breaks
  if (ride.stats.duration > 7200 && !ride.pauseTimestamps?.length) { // 2 hours
    score -= 5;
  }

  // Reward consistent speed
  const speedVariation = Math.abs(ride.stats.maxSpeed - ride.stats.averageSpeed);
  if (speedVariation < 3) {
    score += 5;
  }

  return Math.max(0, Math.min(100, score));
};
