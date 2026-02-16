# CI/CD Pipeline Documentation

## Overview

RiderMate uses GitHub Actions for continuous integration and continuous deployment. The CI/CD pipeline automatically builds, tests, and deploys the application on every push and pull request.

## Workflows

### 1. Flutter CI/CD (.github/workflows/flutter-ci.yml)

**Trigger**: Push or PR to `main` or `dev` branches

**Jobs**:
- **Analyze**: Code analysis and linting
  - Format checking
  - Static analysis
  - Dependency audit
  
- **Test**: Run automated tests
  - Unit tests
  - Widget tests
  - Coverage reporting
  
- **Build Web**: Build Flutter web application
  - Production build
  - Artifact upload
  
- **Build Android**: Build Android APK
  - Release APK
  - Artifact upload
  
- **Build Docker**: Build and push Docker image
  - Multi-platform build
  - Push to GitHub Container Registry
  - Docker Hub (optional)

### 2. Web Deployment (.github/workflows/deploy-web.yml)

**Trigger**: Push to `main` branch or manual workflow dispatch

**Jobs**:
- **Deploy to Vercel**: Deploy web app to Vercel
- **Deploy to Firebase**: Deploy to Firebase Hosting
- **Deploy to Netlify**: Deploy to Netlify
- **Smoke Tests**: Post-deployment validation
- **Notify**: Send deployment notifications

### 3. Security Scanning (.github/workflows/security.yml)

**Trigger**: Push, PR, weekly schedule, or manual dispatch

**Jobs**:
- **CodeQL Analysis**: Static application security testing (SAST)
- **Docker Scan**: Container image vulnerability scanning
- **Secret Scan**: Detect exposed secrets
- **OWASP Dependency Check**: Dependency vulnerability scanning
- **License Check**: License compliance verification

### 4. Android Release (.github/workflows/android-release.yml)

**Trigger**: Push tags (v*) or manual dispatch

**Jobs**:
- **Build Release**: Build signed APK and App Bundle
- **Create Release**: Create GitHub release
- **Upload to Play Store**: Deploy to Google Play (internal testing)

## Pipeline Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Push/PR to main/dev                      │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
        ┌──────────────────────────────┐
        │  1. Code Analysis & Linting  │
        └──────────────┬───────────────┘
                       │
                       ▼
        ┌──────────────────────────────┐
        │      2. Run Tests            │
        │   - Unit tests               │
        │   - Widget tests             │
        │   - Coverage report          │
        └──────────────┬───────────────┘
                       │
                       ▼
        ┌──────────────────────────────────────────┐
        │      3. Parallel Builds                  │
        ├──────────────┬───────────────┬───────────┤
        │   Web Build  │ Android Build │  Docker   │
        └──────────────┴───────────────┴───────────┘
                       │
                       ▼
        ┌──────────────────────────────┐
        │  4. Security Scanning         │
        │   - CodeQL                    │
        │   - Container scanning        │
        │   - Secret detection          │
        └──────────────┬───────────────┘
                       │
                       ▼
        ┌──────────────────────────────┐
        │  5. Deploy (main branch)     │
        │   - Vercel                   │
        │   - Firebase                 │
        │   - Docker Registry          │
        └──────────────┬───────────────┘
                       │
                       ▼
        ┌──────────────────────────────┐
        │  6. Post-Deploy               │
        │   - Smoke tests              │
        │   - Notifications            │
        └──────────────────────────────┘
```

## Required GitHub Secrets

### Docker Registry
```
DOCKER_USERNAME       # Docker Hub username
DOCKER_PASSWORD       # Docker Hub password or token
```

### Vercel
```
VERCEL_TOKEN          # Vercel deployment token
VERCEL_ORG_ID         # Organization ID
VERCEL_PROJECT_ID     # Project ID
```

### Netlify
```
NETLIFY_AUTH_TOKEN    # Netlify authentication token
NETLIFY_SITE_ID       # Site ID
```

### Firebase
```
FIREBASE_SERVICE_ACCOUNT    # Service account JSON
FIREBASE_PROJECT_ID         # Project ID
```

### Android Signing
```
ANDROID_SIGNING_KEY         # Base64 encoded keystore
ANDROID_KEY_ALIAS           # Key alias
ANDROID_KEYSTORE_PASSWORD   # Keystore password
ANDROID_KEY_PASSWORD        # Key password
```

### Google Play
```
PLAY_SERVICE_ACCOUNT_JSON   # Service account for Play Store
```

### Monitoring & Notifications
```
SENTRY_DSN            # Sentry DSN for error tracking
SLACK_WEBHOOK         # Slack webhook URL for notifications
```

### Optional
```
GITLEAKS_LICENSE      # Gitleaks license key
CODECOV_TOKEN         # Codecov token for coverage reports
```

## Setting Up Secrets

### GitHub Repository Secrets

1. Go to repository Settings
2. Navigate to Secrets and Variables → Actions
3. Click "New repository secret"
4. Add each secret with name and value

### Vercel Setup

```bash
# Install Vercel CLI
npm install -g vercel

# Login
vercel login

# Link project
vercel link

# Get org and project IDs from .vercel/project.json
cat .vercel/project.json
```

### Firebase Setup

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login:ci

# This generates a token - add to FIREBASE_SERVICE_ACCOUNT
```

### Android Signing Setup

```bash
# Create keystore
keytool -genkey -v -keystore release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias release

# Base64 encode for GitHub secret
base64 -i release-key.jks | pbcopy  # macOS
base64 -w 0 release-key.jks          # Linux
```

## Workflow Customization

### Modify Trigger Branches

Edit the workflow file:
```yaml
on:
  push:
    branches: [ main, dev, staging ]  # Add more branches
  pull_request:
    branches: [ main, dev ]
```

### Add Environment Variables

```yaml
env:
  FLUTTER_VERSION: '3.38.3'
  NODE_VERSION: '18'
  JAVA_VERSION: '17'
```

### Conditional Jobs

```yaml
jobs:
  deploy:
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
```

### Matrix Builds

```yaml
strategy:
  matrix:
    platform: [web, android, ios]
    environment: [staging, production]
```

## Deployment Environments

### Development
- Automatic deployment on push to `dev` branch
- Deploy to staging environment
- Enable debug features

### Staging
- Automatic deployment on push to `staging` branch
- Full production features with test data
- Used for final QA

### Production
- Automatic deployment on push to `main` branch
- Requires approval (optional)
- Production configuration

## Branch Protection Rules

Recommended settings for `main` branch:

1. **Require pull request before merging**
   - Require approvals: 1
   - Dismiss stale reviews
   
2. **Require status checks to pass**
   - analyze
   - test
   - build-web
   - security checks
   
3. **Require branches to be up to date**

4. **Do not allow bypassing**

## Monitoring Workflows

### View Workflow Runs
1. Go to Actions tab in GitHub
2. Select workflow from left sidebar
3. Click on a run to see details

### Download Artifacts
1. Go to workflow run
2. Scroll to "Artifacts" section
3. Download needed artifacts

### Debugging Failed Runs
1. Click on failed job
2. Expand failed step
3. Review error logs
4. Re-run with debug logging:
   ```yaml
   - name: Debug
     run: |
       echo "::debug::Debug message"
       echo "::warning::Warning message"
       echo "::error::Error message"
   ```

## Best Practices

### 1. Keep Workflows Fast
- Use caching for dependencies
- Run jobs in parallel
- Skip unnecessary steps

### 2. Security
- Never commit secrets
- Use GitHub Secrets for sensitive data
- Scan for vulnerabilities regularly

### 3. Reliability
- Set timeout limits
- Add retry logic for flaky steps
- Use `continue-on-error` for non-critical steps

### 4. Notifications
- Set up Slack/email notifications
- Alert on deployment failures
- Weekly security scan reports

### 5. Documentation
- Document all secrets needed
- Keep workflow files commented
- Maintain this documentation

## Troubleshooting

### Common Issues

#### 1. Build Fails
```
Error: Flutter build failed
```
**Solution**: Check Flutter version, dependencies, and code errors

#### 2. Docker Build Timeout
```
Error: Build exceeded maximum time
```
**Solution**: Use build cache, optimize Dockerfile layers

#### 3. Deployment Fails
```
Error: Authentication failed
```
**Solution**: Verify secrets are correctly configured

#### 4. Tests Fail
```
Error: Test suite failed
```
**Solution**: Run tests locally, fix failing tests

### Getting Help

- Check workflow logs in Actions tab
- Review [Troubleshooting Guide](TROUBLESHOOTING.md)
- Open issue with workflow run link

## Metrics and Analytics

### Key Metrics
- Build time per platform
- Test coverage percentage
- Deployment frequency
- Success rate
- Mean time to recovery (MTTR)

### Tracking
- Use GitHub Insights
- Monitor in Actions dashboard
- Set up custom dashboards (optional)

## Future Improvements

- [ ] Implement blue-green deployments
- [ ] Add canary deployments
- [ ] Integrate performance testing
- [ ] Add visual regression testing
- [ ] Implement feature flags
- [ ] Add A/B testing infrastructure
