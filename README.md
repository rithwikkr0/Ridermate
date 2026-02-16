# RiderMate 🚴

RiderMate is a comprehensive cycling and ride tracking application built with Flutter. Track your rides, share memories, connect with friends, and earn points for your cycling adventures.

## Features

- 🚴 **Real-time Ride Tracking**: Track distance, speed, duration, and calories
- 📍 **Location Memories**: Save and share your favorite cycling spots
- 👥 **Social Features**: Connect with friends and see their location on the map
- 🏆 **Points & Rewards**: Earn points for each ride and referrals
- 🚨 **SOS Alert**: Emergency button to alert contacts
- 🎵 **Music Integration**: Control music while riding
- 📊 **Ride History**: View past rides and statistics

## Quick Start

### Prerequisites

- Flutter SDK 3.38.3 or later
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Docker (for containerized deployment)

### Local Development

```bash
# Clone the repository
git clone https://github.com/rithwikkr0/Ridermate.git
cd Ridermate/ridermate_app

# Install dependencies
flutter pub get

# Run the app
flutter run
```

For detailed setup instructions, see [Local Development Guide](docs/LOCAL_DEVELOPMENT.md).

### Docker Deployment

```bash
# Build and run with Docker Compose
docker-compose up -d

# Access at http://localhost:3000
```

## Documentation

- **[Deployment Guide](docs/DEPLOYMENT.md)** - Deploy to production
- **[Local Development](docs/LOCAL_DEVELOPMENT.md)** - Set up local environment
- **[CI/CD Pipeline](docs/CI_CD.md)** - GitHub Actions workflows
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Common issues and solutions
- **[Production Checklist](docs/PRODUCTION_CHECKLIST.md)** - Pre-launch checklist
- **[Monitoring Setup](docs/MONITORING.md)** - Application monitoring
- **[Backup & Recovery](docs/BACKUP_RECOVERY.md)** - Data backup strategy
- **[Scalability Guide](docs/SCALABILITY.md)** - Scaling the application
- **[GitHub Secrets](docs/GITHUB_SECRETS.md)** - Configure CI/CD secrets

## Architecture

### Frontend
- **Framework**: Flutter 3.38.3
- **Language**: Dart
- **Platforms**: Web, Android, iOS

### Backend (Planned)
- **Database**: Firebase Firestore
- **Authentication**: Firebase Auth
- **Storage**: Firebase Storage

### Infrastructure
- **Web Hosting**: Vercel / Netlify / Firebase Hosting
- **Container Registry**: GitHub Container Registry / Docker Hub
- **CI/CD**: GitHub Actions
- **Monitoring**: Sentry, Firebase Analytics

## Deployment Options

### Web
- **Vercel** (Recommended)
- **Netlify**
- **Firebase Hosting**
- **Docker with nginx**

### Mobile
- **Android**: Google Play Store
- **iOS**: Apple App Store

### Container
- **Docker**: Local or cloud deployment
- **Kubernetes**: For scaling (optional)

## CI/CD Pipeline

The project includes comprehensive GitHub Actions workflows:

- **Flutter CI/CD**: Build, test, and deploy
- **Security Scanning**: CodeQL, dependency checks, container scanning
- **Web Deployment**: Automatic deployment to Vercel/Netlify/Firebase
- **Android Release**: Build and publish to Play Store

## Environment Setup

```bash
# Copy environment template
cp .env.example .env.development

# Edit with your configuration
nano .env.development

# Available environments:
# - .env.development (local development)
# - .env.staging (staging environment)
# - .env.production (production environment)
```

See [GitHub Secrets Guide](docs/GITHUB_SECRETS.md) for CI/CD configuration.

## Project Structure

```
Ridermate/
├── ridermate_app/          # Flutter application
│   ├── lib/                # Application code
│   ├── test/               # Tests
│   ├── web/                # Web assets
│   └── pubspec.yaml        # Dependencies
├── .github/
│   ├── workflows/          # GitHub Actions
│   └── dependabot.yml      # Dependency updates
├── docs/                   # Documentation
├── k8s/                    # Kubernetes manifests (optional)
├── Dockerfile              # Docker configuration
├── docker-compose.yml      # Docker Compose setup
├── nginx.conf              # nginx configuration
└── .env.example            # Environment template
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Testing

```bash
# Run all tests
cd ridermate_app
flutter test

# Run with coverage
flutter test --coverage

# Run specific test
flutter test test/widget_test.dart
```

## Security

- Security scanning with CodeQL
- Dependency scanning with Dependabot
- Container scanning with Trivy
- Secret scanning with Gitleaks

See [Security Workflow](.github/workflows/security.yml) for details.

## Monitoring

- **Error Tracking**: Sentry
- **Analytics**: Firebase Analytics
- **Uptime**: UptimeRobot
- **Performance**: Firebase Performance Monitoring

See [Monitoring Guide](docs/MONITORING.md) for setup instructions.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

- **Documentation**: Check the [docs/](docs/) directory
- **Issues**: Open an issue on GitHub
- **Discussions**: Use GitHub Discussions

## Roadmap

- [x] Basic ride tracking
- [x] Social features
- [x] Points system
- [x] Docker support
- [x] CI/CD pipeline
- [ ] Backend API integration
- [ ] Real-time friend tracking
- [ ] Leaderboards
- [ ] Route recommendations
- [ ] Integration with fitness devices

## Acknowledgments

Built with:
- [Flutter](https://flutter.dev/)
- [Firebase](https://firebase.google.com/)
- [Docker](https://www.docker.com/)
- [GitHub Actions](https://github.com/features/actions)
