# RiderMate Quick Start Guide

## 🚀 Get Started in 5 Minutes

### For Local Development

```bash
# 1. Clone the repository
git clone https://github.com/rithwikkr0/Ridermate.git
cd Ridermate/ridermate_app

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run -d chrome
```

**That's it!** The app is now running at http://localhost:8080

### For Docker Development

```bash
# 1. Start with Docker Compose
docker-compose --profile dev up

# 2. Access the app
# Open http://localhost:8080
```

### For Production Deployment

#### Option 1: Vercel (Recommended - 2 minutes)

```bash
# 1. Install Vercel CLI
npm install -g vercel

# 2. Deploy
cd ridermate_app
flutter build web --release
cd ..
vercel --prod ridermate_app/build/web
```

#### Option 2: Docker (Self-hosted - 3 minutes)

```bash
# 1. Build the image
docker build -t ridermate:latest .

# 2. Run in production
docker run -d -p 80:80 --name ridermate ridermate:latest

# 3. Access at http://your-server-ip
```

#### Option 3: GitHub Actions (Automated)

1. Configure GitHub Secrets (see [docs/GITHUB_SECRETS.md](docs/GITHUB_SECRETS.md))
2. Push to `main` branch
3. GitHub Actions automatically deploys!

## 📚 Essential Documentation

| Document | What's Inside | When to Use |
|----------|---------------|-------------|
| [DEPLOYMENT.md](docs/DEPLOYMENT.md) | All deployment options explained | Before deploying to production |
| [LOCAL_DEVELOPMENT.md](docs/LOCAL_DEVELOPMENT.md) | Set up dev environment | When starting development |
| [CI_CD.md](docs/CI_CD.md) | GitHub Actions pipelines | Setting up automated deployments |
| [GITHUB_SECRETS.md](docs/GITHUB_SECRETS.md) | Configure CI/CD secrets | Configuring GitHub Actions |
| [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) | Fix common issues | When something breaks |

## 🔧 Common Tasks

### Run Tests
```bash
cd ridermate_app
flutter test
```

### Build for Production
```bash
# Web
flutter build web --release

# Android
flutter build apk --release

# iOS
flutter build ios --release
```

### Check Code Quality
```bash
# Format code
dart format .

# Analyze code
flutter analyze

# Run linter
flutter pub run dart_code_metrics:metrics analyze lib
```

### View Logs
```bash
# Docker logs
docker logs ridermate -f

# Flutter logs
flutter logs
```

## 🛠️ Quick Fixes

### App won't start?
```bash
flutter clean
flutter pub get
flutter run
```

### Docker build fails?
```bash
docker system prune -a
docker build --no-cache -t ridermate:latest .
```

### CI/CD failing?
1. Check GitHub Secrets are configured
2. Review workflow logs in Actions tab
3. See [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)

## 📞 Need Help?

1. **Check Documentation**: See [docs/](docs/) directory
2. **Search Issues**: Look for similar problems in GitHub Issues
3. **Create Issue**: Open a new issue with details
4. **Review Logs**: Always include error logs when asking for help

## 🎯 Quick Links

- **Local Dev**: [docs/LOCAL_DEVELOPMENT.md](docs/LOCAL_DEVELOPMENT.md)
- **Deploy**: [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)
- **CI/CD Setup**: [docs/CI_CD.md](docs/CI_CD.md)
- **Troubleshoot**: [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)
- **Production**: [docs/PRODUCTION_CHECKLIST.md](docs/PRODUCTION_CHECKLIST.md)
- **Monitor**: [docs/MONITORING.md](docs/MONITORING.md)
- **Kubernetes**: [k8s/README.md](k8s/README.md)

## 🔐 Security

- **No secrets in code**: Use `.env` files
- **GitHub Secrets**: Configure for CI/CD
- **Security scans**: Automated in every PR
- **Health checks**: `/health` endpoint

## 📊 Monitoring

After deployment, set up:
1. **Sentry**: Error tracking
2. **UptimeRobot**: Uptime monitoring
3. **Firebase Analytics**: User analytics

See [docs/MONITORING.md](docs/MONITORING.md) for details.

## 🚦 Deployment Checklist

Before deploying to production:

- [ ] Configure environment variables
- [ ] Set up GitHub Secrets
- [ ] Configure monitoring (Sentry)
- [ ] Set up uptime monitoring
- [ ] Review security settings
- [ ] Test deployment in staging
- [ ] Configure backups
- [ ] Set up SSL/TLS certificates

See [docs/PRODUCTION_CHECKLIST.md](docs/PRODUCTION_CHECKLIST.md) for complete list.

---

**Need more details?** Check the [complete documentation](docs/).
