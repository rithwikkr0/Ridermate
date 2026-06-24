export interface Memory {
  id: string;
  userId: string;
  rideId?: string;
  title: string;
  description: string;
  photos?: string[];
  location?: {
    latitude: number;
    longitude: number;
    name?: string;
  };
  tags?: string[];
  isPublic: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateMemoryData {
  userId: string;
  rideId?: string;
  title: string;
  description: string;
  photos?: string[];
  location?: {
    latitude: number;
    longitude: number;
    name?: string;
  };
  tags?: string[];
  isPublic?: boolean;
}

export interface Friend {
  id: string;
  userId: string;
  friendId: string;
  status: 'pending' | 'accepted' | 'rejected';
  createdAt: Date;
  updatedAt: Date;
}

export interface FriendRequest {
  userId: string;
  friendId: string;
}

export interface LeaderboardEntry {
  userId: string;
  username: string;
  avatar?: string;
  totalDistance: number;
  totalRides: number;
  rank: number;
}

export interface ChatMessage {
  role: 'user' | 'assistant';
  content: string;
}

export interface ChatRequest {
  userId: string;
  message: string;
  conversationHistory?: ChatMessage[];
}

export interface AIAnalysisRequest {
  rideId: string;
  userId: string;
}
