# Deployment Guide

## Prerequisites

- Node.js 18+ installed
- npm or yarn
- Firebase account with project created
- OpenAI API key (optional)
- Docker (for container deployment)

## Local Development Deployment

### 1. Clone and Setup

```bash
git clone https://github.com/rithwikkr0/Ridermate.git
cd Ridermate
```

### 2. Backend Setup

```bash
cd backend
npm install
cp .env.example .env
```

Edit `.env` file with your credentials:
```env
PORT=5000
NODE_ENV=development
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxx@your-project.iam.gserviceaccount.com
OPENAI_API_KEY=sk-...
CORS_ORIGIN=http://localhost:3000
```

Start backend:
```bash
npm run dev
```

### 3. Frontend Setup

```bash
cd ../frontend
npm install
cp .env.example .env
```

Edit `.env` file:
```env
VITE_FIREBASE_API_KEY=your-api-key
VITE_FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
VITE_FIREBASE_PROJECT_ID=your-project-id
VITE_FIREBASE_STORAGE_BUCKET=your-project.appspot.com
VITE_FIREBASE_MESSAGING_SENDER_ID=123456789
VITE_FIREBASE_APP_ID=1:123456789:web:abcdef
VITE_API_URL=http://localhost:5000/api
```

Start frontend:
```bash
npm run dev
```

## Docker Deployment

### 1. Configure Environment

```bash
cp backend/.env.example backend/.env
# Edit backend/.env with your credentials
```

### 2. Build and Run

```bash
docker-compose up -d
```

Access:
- Frontend: http://localhost:3000
- Backend: http://localhost:5000

### 3. Stop Containers

```bash
docker-compose down
```

## Production Deployment

### Option 1: Vercel (Frontend) + Render (Backend)

#### Frontend on Vercel

1. Install Vercel CLI:
```bash
npm i -g vercel
```

2. Deploy:
```bash
cd frontend
vercel --prod
```

3. Set environment variables in Vercel dashboard

#### Backend on Render

1. Create new Web Service on Render.com
2. Connect GitHub repository
3. Configure:
   - Build Command: `cd backend && npm install && npm run build`
   - Start Command: `cd backend && npm start`
   - Environment: Add all env variables from `.env`

### Option 2: Railway

1. Install Railway CLI:
```bash
npm i -g @railway/cli
```

2. Deploy backend:
```bash
cd backend
railway login
railway init
railway up
```

3. Deploy frontend:
```bash
cd ../frontend
railway init
railway up
```

### Option 3: Digital Ocean / AWS / GCP

#### Backend Deployment

1. Create a droplet/instance
2. Install Node.js 18+
3. Clone repository
4. Install dependencies
5. Build application
6. Use PM2 for process management:

```bash
npm i -g pm2
cd backend
npm run build
pm2 start dist/server.js --name ridermate-api
pm2 save
pm2 startup
```

#### Frontend Deployment

Build and serve with Nginx:

```bash
cd frontend
npm run build
```

Nginx configuration:
```nginx
server {
    listen 80;
    server_name your-domain.com;
    root /var/www/ridermate/frontend/dist;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

## Firebase Configuration

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create new project
3. Enable Authentication (Email/Password)
4. Create Firestore database

### 2. Get Credentials

**For Backend:**
1. Go to Project Settings > Service Accounts
2. Generate new private key
3. Use the JSON file contents for env variables

**For Frontend:**
1. Go to Project Settings > General
2. Scroll to "Your apps"
3. Add a web app
4. Copy the config values

### 3. Security Rules

Set Firestore rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    // Rides can be read by owner or friends
    match /rides/{rideId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.userId;
    }
    
    // Friends
    match /friends/{friendId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
    }
    
    // Public data
    match /achievements/{achievementId} {
      allow read: if true;
    }
  }
}
```

## Environment Variables Reference

### Backend
- `PORT` - Server port (default: 5000)
- `NODE_ENV` - Environment (development/production)
- `FIREBASE_PROJECT_ID` - Firebase project ID
- `FIREBASE_PRIVATE_KEY` - Firebase service account private key
- `FIREBASE_CLIENT_EMAIL` - Firebase service account email
- `OPENAI_API_KEY` - OpenAI API key
- `CORS_ORIGIN` - Allowed frontend origin
- `RATE_LIMIT_WINDOW_MS` - Rate limit window (default: 900000)
- `RATE_LIMIT_MAX_REQUESTS` - Max requests per window (default: 100)

### Frontend
- `VITE_FIREBASE_API_KEY` - Firebase web API key
- `VITE_FIREBASE_AUTH_DOMAIN` - Firebase auth domain
- `VITE_FIREBASE_PROJECT_ID` - Firebase project ID
- `VITE_FIREBASE_STORAGE_BUCKET` - Firebase storage bucket
- `VITE_FIREBASE_MESSAGING_SENDER_ID` - Firebase messaging sender ID
- `VITE_FIREBASE_APP_ID` - Firebase app ID
- `VITE_API_URL` - Backend API URL

## Post-Deployment Checklist

- [ ] Test user registration
- [ ] Test user login
- [ ] Test ride creation
- [ ] Test GPS tracking
- [ ] Test AI chat
- [ ] Test social features
- [ ] Test leaderboard
- [ ] Verify all API endpoints
- [ ] Check error logging
- [ ] Monitor performance
- [ ] Set up backups
- [ ] Configure SSL/HTTPS
- [ ] Set up monitoring alerts

## Troubleshooting

### Backend won't start
- Check Node.js version (18+)
- Verify all env variables are set
- Check Firebase credentials
- Check port availability

### Frontend can't connect to backend
- Verify CORS_ORIGIN in backend
- Check VITE_API_URL in frontend
- Ensure backend is running
- Check network/firewall settings

### Firebase authentication errors
- Verify Firebase config
- Check authentication method is enabled
- Verify credentials are correct
- Check Firebase quotas

## Monitoring

### Logs
- Backend: Check Winston logs
- Frontend: Browser console
- Docker: `docker-compose logs -f`

### Health Checks
- Backend: `curl http://localhost:5000/health`
- Frontend: Access in browser

### Performance
- Monitor response times
- Check database query performance
- Monitor memory usage
- Track error rates
