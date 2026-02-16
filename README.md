# 🚴 RiderMate - Your Ultimate Cycling Companion

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

RiderMate is a complete, production-ready cycling and ride tracking application featuring GPS tracking, AI-powered coaching, social features, gamification, and comprehensive analytics.

## ✨ Features

### 🎯 Core Features
- **GPS Tracking**: Real-time location tracking, route mapping, and speed monitoring
- **Ride Metrics**: Distance, duration, speed tracking, overspeed detection, and safety scoring
- **AI Companion**: OpenAI-powered analysis, chat coaching, and weekly summaries
- **Social Features**: Friends, ride rooms, and real-time location sharing
- **Memory Journal**: Photo uploads with captions and location tagging
- **Gamification**: Points, badges, achievements, leaderboards, and streaks
- **Analytics**: Ride history, performance metrics, trends, and visualizations
- **Authentication**: Firebase authentication with user profiles and privacy controls

### ��️ Technology Stack

**Backend:**
- Node.js & Express
- TypeScript
- Firebase Admin SDK (Firestore, Authentication)
- OpenAI API Integration
- WebSocket support (ws)
- Rate limiting & security middleware

**Frontend:**
- React 18 with TypeScript
- React Router for navigation
- React Leaflet for maps
- Recharts for data visualization
- Vite for fast development
- Dark/Light theme support

**DevOps:**
- Docker & Docker Compose
- GitHub Actions CI/CD
- Production-ready configurations

## 🚀 Quick Start

### Prerequisites
- Node.js 18+ and npm
- Docker and Docker Compose (optional)
- Firebase account
- OpenAI API key (optional, for AI features)

### Local Development

1. **Clone the repository**
```bash
git clone https://github.com/rithwikkr0/Ridermate.git
cd Ridermate
```

2. **Backend Setup**
```bash
cd backend
npm install
cp .env.example .env
# Edit .env with your Firebase and OpenAI credentials
npm run dev
```

3. **Frontend Setup** (in a new terminal)
```bash
cd frontend
npm install
cp .env.example .env
# Edit .env with your Firebase credentials
npm run dev
```

4. **Access the application**
- Frontend: http://localhost:3000
- Backend API: http://localhost:5000
- API Health Check: http://localhost:5000/health

### Docker Deployment

1. **Configure environment variables**
```bash
# Copy and edit backend .env file
cp backend/.env.example backend/.env
```

2. **Build and run with Docker Compose**
```bash
docker-compose up -d
```

3. **Access the application**
- Frontend: http://localhost:3000
- Backend API: http://localhost:5000

## 📁 Project Structure

```
ridermate/
├── backend/                 # Express API server
│   ├── src/
│   │   ├── routes/          # API route definitions
│   │   ├── middleware/      # Custom middleware
│   │   ├── config/          # Configuration files
│   │   ├── types/           # TypeScript type definitions
│   │   └── server.ts        # Entry point
│   ├── tests/               # Test files
│   └── package.json
├── frontend/                # React application
│   ├── src/
│   │   ├── pages/           # Page components
│   │   ├── services/        # API services
│   │   ├── hooks/           # Custom React hooks
│   │   ├── types/           # TypeScript types
│   │   ├── styles/          # Global styles
│   │   └── App.tsx          # Main app component
│   ├── public/
│   └── package.json
├── ridermate_app/           # Flutter app (mobile)
├── docker-compose.yml       # Docker orchestration
├── Dockerfile.backend       # Backend container
├── Dockerfile.frontend      # Frontend container
└── README.md
```

## 🔧 Configuration

### Firebase Setup

1. Create a Firebase project at [https://console.firebase.google.com](https://console.firebase.google.com)
2. Enable Authentication (Email/Password)
3. Create a Firestore database
4. Generate a service account key for the backend
5. Get your web app config for the frontend

### Environment Variables

**Backend (.env)**
```env
PORT=5000
NODE_ENV=development
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY=your-private-key
FIREBASE_CLIENT_EMAIL=your-client-email
OPENAI_API_KEY=your-openai-api-key
CORS_ORIGIN=http://localhost:3000
```

**Frontend (.env)**
```env
VITE_FIREBASE_API_KEY=your-api-key
VITE_FIREBASE_AUTH_DOMAIN=your-auth-domain
VITE_FIREBASE_PROJECT_ID=your-project-id
VITE_FIREBASE_STORAGE_BUCKET=your-storage-bucket
VITE_FIREBASE_MESSAGING_SENDER_ID=your-sender-id
VITE_FIREBASE_APP_ID=your-app-id
VITE_API_URL=http://localhost:5000/api
```

## 📚 API Documentation

### Authentication Endpoints
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - User login
- `GET /api/auth/verify` - Verify token
- `POST /api/auth/logout` - User logout

### Ride Endpoints
- `POST /api/rides/start` - Start a new ride
- `PUT /api/rides/:rideId/location` - Update ride location
- `POST /api/rides/:rideId/end` - End a ride
- `GET /api/rides` - Get user rides
- `GET /api/rides/:rideId` - Get ride details

### Social Endpoints
- `POST /api/social/friends/request` - Send friend request
- `PUT /api/social/friends/:id/accept` - Accept friend request
- `GET /api/social/friends` - Get friends list
- `POST /api/social/rooms` - Create ride room
- `POST /api/social/rooms/:id/join` - Join ride room

### AI Endpoints
- `POST /api/ai/chat` - Chat with AI coach
- `GET /api/ai/chat/history` - Get chat history
- `POST /api/ai/summary/weekly` - Generate weekly summary

### Gamification Endpoints
- `GET /api/gamification/achievements` - Get all achievements
- `GET /api/gamification/achievements/me` - Get user achievements
- `GET /api/gamification/leaderboard` - Get leaderboard

### Analytics Endpoints
- `GET /api/analytics/rides` - Get ride analytics
- `GET /api/analytics/trends` - Get performance trends
- `GET /api/analytics/safety` - Get safety analytics

## 🧪 Testing

```bash
# Backend tests
cd backend
npm test
npm run test:coverage

# Frontend tests
cd frontend
npm test
npm run test:coverage
```

## 🚢 Deployment

### Vercel (Frontend)
```bash
cd frontend
vercel --prod
```

### Render/Railway (Backend)
1. Connect your GitHub repository
2. Set environment variables
3. Deploy with auto-detection

## 🔒 Security

- Firebase Authentication for secure user management
- Helmet.js for HTTP security headers
- CORS protection
- Rate limiting on API endpoints
- Input validation with Joi
- Environment-based configuration
- Secure token handling

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License.

## 👥 Authors

- **Ridermate Team** - Initial work

## 🙏 Acknowledgments

- Firebase for authentication and database
- OpenAI for AI capabilities
- OpenStreetMap for mapping data
- All contributors and supporters

## 📧 Contact

For questions or support, please open an issue on GitHub.

---

**Happy Riding! 🚴‍♂️🚴‍♀️**
