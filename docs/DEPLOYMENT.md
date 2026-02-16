# RiderMate Deployment Guide

## Table of Contents
- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Deployment Options](#deployment-options)
- [Web Deployment](#web-deployment)
- [Mobile Deployment](#mobile-deployment)
- [Docker Deployment](#docker-deployment)
- [Environment Configuration](#environment-configuration)
- [Post-Deployment](#post-deployment)

## Overview

RiderMate is a Flutter-based cycling and ride tracking application that can be deployed as:
- **Web Application**: Vercel, Netlify, Firebase Hosting, or Docker
- **Mobile Application**: Google Play Store, Apple App Store
- **Containerized**: Docker with nginx

## Prerequisites

### Required Tools
- Flutter SDK 3.38.3 or later
- Docker Desktop (for containerized deployment)
- Git
- Node.js 18+ (for some deployment platforms)

### Required Accounts
- GitHub account (for CI/CD)
- Cloud platform account (Vercel/Netlify/Firebase)
- Docker Hub account (optional)
- Google Play Console (for Android)
- Apple Developer Account (for iOS)

## Deployment Options

### Option 1: Vercel (Recommended for Web)

#### Setup
1. Install Vercel CLI:
   ```bash
   npm install -g vercel
   ```

2. Build the Flutter web app:
   ```bash
   cd ridermate_app
   flutter build web --release --web-renderer canvaskit
   ```

3. Deploy to Vercel:
   ```bash
   vercel --prod build/web
   ```

### Option 2: Docker Deployment

#### Build and Run
```bash
# Build Docker image
docker build -t ridermate:latest .

# Run container
docker run -d -p 3000:80 --name ridermate ridermate:latest

# Access at http://localhost:3000
```

#### Using Docker Compose
```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

## Environment Configuration

### GitHub Secrets

Configure these secrets in GitHub repository settings:

#### Docker Registry
- `DOCKER_USERNAME`: Docker Hub username
- `DOCKER_PASSWORD`: Docker Hub password or access token

#### Vercel
- `VERCEL_TOKEN`: Vercel deployment token
- `VERCEL_ORG_ID`: Organization ID
- `VERCEL_PROJECT_ID`: Project ID

#### Monitoring
- `SENTRY_DSN`: Sentry project DSN
- `SLACK_WEBHOOK`: Slack webhook URL

## Rollback Procedure

#### Docker
```bash
# Stop current version
docker stop ridermate

# Start previous version
docker run -d -p 80:80 --name ridermate \
  ghcr.io/rithwikkr0/ridermate:v0.9.0
```

For detailed deployment instructions, see full guide sections above.
