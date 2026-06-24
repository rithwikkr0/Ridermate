# RiderMate Backend - Quick Start Guide

## Prerequisites
- Node.js 18+ and npm
- Firebase project with Firestore enabled
- OpenAI API key

## Setup (5 minutes)

### 1. Install Dependencies
```bash
cd backend
npm install
```

### 2. Configure Environment
```bash
cp .env.example .env
```

Edit `.env` and set:
- `FIREBASE_PROJECT_ID` - Your Firebase project ID
- `FIREBASE_PRIVATE_KEY` - Your Firebase private key
- `FIREBASE_CLIENT_EMAIL` - Your Firebase client email
- `OPENAI_API_KEY` - Your OpenAI API key
- `JWT_SECRET` - A secure random string

### 3. Run Development Server
```bash
npm run dev
```

Server will start on http://localhost:3000

### 4. Test the API
```bash
curl http://localhost:3000/health
```

Expected response:
```json
{
  "success": true,
  "message": "RiderMate API is running",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "environment": "development"
}
```

## Production Deployment

### Build
```bash
npm run build
```

### Start Production Server
```bash
npm start
```

## Available Scripts

- `npm run dev` - Start development server with auto-reload
- `npm run build` - Build TypeScript to JavaScript
- `npm start` - Start production server
- `npm run lint` - Lint code
- `npm run format` - Format code with Prettier

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user

### Rides
- `POST /api/rides/start` - Start a new ride
- `POST /api/rides/end` - End active ride
- `POST /api/rides/pause` - Pause active ride
- `POST /api/rides/resume` - Resume paused ride
- `GET /api/rides/:rideId` - Get ride details
- `GET /api/rides/user/:userId` - Get user's rides

### AI Features
- `POST /api/ai/analyze-ride` - Analyze ride with AI
- `POST /api/ai/chat` - Chat with AI assistant

### Social
- `POST /api/memories` - Create memory
- `GET /api/memories/:userId` - Get user memories
- `POST /api/friends/request` - Send friend request
- `GET /api/friends/:userId` - Get user's friends
- `GET /api/leaderboard` - Get global leaderboard

### Health
- `GET /health` - Health check

## Rate Limits

- **Auth endpoints**: 5 requests per 15 minutes
- **AI endpoints**: 20 requests per hour
- **General API**: 100 requests per 15 minutes

## Security Features

✓ JWT token authentication
✓ Password hashing with bcrypt
✓ Rate limiting on all endpoints
✓ Security headers with Helmet
✓ CORS configuration
✓ Input validation
✓ Error handling

## Troubleshooting

### Firebase Connection Issues
Ensure your Firebase credentials are correct in `.env` or use a service account JSON file.

### OpenAI API Errors
Verify your OpenAI API key is valid and has sufficient credits.

### Port Already in Use
Change `PORT` in `.env` to a different port number.

## Documentation

For detailed API documentation, see [README.md](./README.md)

## Support

For issues and questions, please open an issue on GitHub.
