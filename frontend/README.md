# RiderMate Frontend

A modern cycling and ride tracking application built with React 18, TypeScript, Vite, and Tailwind CSS.

## Features

- 🚴 Track cycling rides with GPS
- 📸 Create and share cycling memories
- 👥 Connect with friends and other cyclists
- 🏆 Compete on leaderboards
- 🔥 Firebase authentication and database
- ⚡ Fast development with Vite
- 🎨 Beautiful UI with Tailwind CSS
- 📱 Responsive design

## Tech Stack

- **React 18** - UI library
- **TypeScript** - Type-safe JavaScript
- **Vite** - Build tool and dev server
- **Tailwind CSS** - Utility-first CSS framework
- **React Router v6** - Client-side routing
- **Firebase** - Authentication, Database, and Storage
- **ESLint** - Code linting

## Getting Started

### Prerequisites

- Node.js 18+ and npm
- Firebase project (for authentication and database)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd frontend
```

2. Install dependencies:
```bash
npm install
```

3. Set up environment variables:
```bash
cp .env.example .env
```

4. Edit `.env` and add your Firebase configuration:
```env
VITE_FIREBASE_API_KEY=your_api_key_here
VITE_FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
VITE_FIREBASE_PROJECT_ID=your_project_id
VITE_FIREBASE_STORAGE_BUCKET=your_project.appspot.com
VITE_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
VITE_FIREBASE_APP_ID=your_app_id
```

### Development

Run the development server:
```bash
npm run dev
```

The application will be available at `http://localhost:5173`

### Building for Production

Build the application:
```bash
npm run build
```

Preview the production build:
```bash
npm run preview
```

### Linting

Run ESLint:
```bash
npm run lint
```

## Project Structure

```
frontend/
├── src/
│   ├── assets/          # Images, icons, and static files
│   ├── components/      # Reusable UI components
│   │   ├── MainLayout.tsx
│   │   └── ProtectedRoute.tsx
│   ├── hooks/           # Custom React hooks
│   │   └── useAuth.ts
│   ├── pages/           # Page components
│   │   ├── HomePage.tsx
│   │   ├── LoginPage.tsx
│   │   ├── RegisterPage.tsx
│   │   ├── DashboardPage.tsx
│   │   ├── RidesPage.tsx
│   │   ├── MemoriesPage.tsx
│   │   ├── FriendsPage.tsx
│   │   ├── LeaderboardPage.tsx
│   │   └── ProfilePage.tsx
│   ├── services/        # API and Firebase services
│   │   ├── firebase.ts
│   │   └── auth.ts
│   ├── types/           # TypeScript type definitions
│   │   └── index.ts
│   ├── utils/           # Utility functions
│   │   └── formatters.ts
│   ├── App.tsx          # Main application component
│   ├── main.tsx         # Application entry point
│   └── index.css        # Global styles with Tailwind
├── public/              # Public static files
├── index.html           # HTML template
├── vite.config.ts       # Vite configuration
├── tailwind.config.js   # Tailwind CSS configuration
├── postcss.config.js    # PostCSS configuration
├── tsconfig.json        # TypeScript configuration
└── package.json         # Project dependencies
```

## Available Routes

- `/` - Home page
- `/login` - User login
- `/register` - User registration
- `/dashboard` - User dashboard (protected)
- `/rides` - Rides list (protected)
- `/memories` - Memories/journals (protected)
- `/friends` - Friends list (protected)
- `/leaderboard` - Leaderboard (protected)
- `/profile` - User profile (protected)

## Core Types

The application includes comprehensive TypeScript types for:
- User profiles
- Ride data and statistics
- Memories/journals
- Friend relationships
- Leaderboard entries

See `src/types/index.ts` for full type definitions.

## Firebase Setup

1. Create a Firebase project at https://console.firebase.google.com
2. Enable Authentication (Email/Password)
3. Create a Firestore Database
4. Enable Storage for photo uploads
5. Copy your Firebase config to the `.env` file

## Contributing

1. Create a feature branch
2. Make your changes
3. Run linting and tests
4. Submit a pull request

## License

MIT

