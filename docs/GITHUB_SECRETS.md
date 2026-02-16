# GitHub Secrets Configuration Guide

## Overview

This document lists all GitHub Secrets required for the RiderMate CI/CD pipelines.

## Required Secrets

### Docker Registry

| Secret Name | Description | Example | Required For |
|------------|-------------|---------|--------------|
| `DOCKER_USERNAME` | Docker Hub username | `yourusername` | Docker build & push |
| `DOCKER_PASSWORD` | Docker Hub password or token | `dckr_pat_xxxxx` | Docker build & push |

**Setup**:
1. Create Docker Hub account at https://hub.docker.com
2. Generate access token: Account Settings → Security → New Access Token
3. Add to GitHub Secrets

### Vercel Deployment

| Secret Name | Description | How to Get |
|------------|-------------|------------|
| `VERCEL_TOKEN` | Vercel deployment token | Account Settings → Tokens |
| `VERCEL_ORG_ID` | Organization ID | `.vercel/project.json` after `vercel link` |
| `VERCEL_PROJECT_ID` | Project ID | `.vercel/project.json` after `vercel link` |

**Setup**:
```bash
# Install Vercel CLI
npm install -g vercel

# Login and link project
vercel login
vercel link

# Get IDs from .vercel/project.json
cat .vercel/project.json
```

### Netlify Deployment

| Secret Name | Description | How to Get |
|------------|-------------|------------|
| `NETLIFY_AUTH_TOKEN` | Netlify authentication token | User Settings → Applications → Personal access tokens |
| `NETLIFY_SITE_ID` | Site ID | Site Settings → General → Site information |

**Setup**:
1. Go to https://app.netlify.com
2. User Settings → Applications → New access token
3. Copy token
4. Create site and get Site ID from settings

### Firebase

| Secret Name | Description | How to Get |
|------------|-------------|------------|
| `FIREBASE_SERVICE_ACCOUNT` | Service account JSON | Firebase Console → Project Settings → Service Accounts |
| `FIREBASE_PROJECT_ID` | Firebase project ID | Firebase Console → Project Settings |

**Setup**:
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login:ci

# This generates a token - add to secret
```

### Android Signing

| Secret Name | Description | How to Generate |
|------------|-------------|-----------------|
| `ANDROID_SIGNING_KEY` | Base64 encoded keystore | `base64 -w 0 release-key.jks` |
| `ANDROID_KEY_ALIAS` | Key alias | Same as used in keytool |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password | Password used in keytool |
| `ANDROID_KEY_PASSWORD` | Key password | Password used in keytool |

**Setup**:
```bash
# Create keystore
keytool -genkey -v -keystore release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias release

# Base64 encode (Linux/macOS)
base64 -w 0 release-key.jks

# Base64 encode (macOS alternative)
base64 -i release-key.jks | pbcopy
```

### Google Play

| Secret Name | Description | How to Get |
|------------|-------------|------------|
| `PLAY_SERVICE_ACCOUNT_JSON` | Service account JSON | Google Play Console → Setup → API access |

**Setup**:
1. Go to Google Play Console
2. Setup → API access
3. Create new service account
4. Download JSON key
5. Copy entire JSON content to secret

### Monitoring & Notifications

| Secret Name | Description | How to Get |
|------------|-------------|------------|
| `SENTRY_DSN` | Sentry project DSN | Sentry.io → Project Settings → Client Keys |
| `SLACK_WEBHOOK` | Slack webhook URL | Slack → Apps → Incoming Webhooks |

**Sentry Setup**:
1. Create account at https://sentry.io
2. Create new project (Flutter)
3. Copy DSN from Project Settings → Client Keys

**Slack Setup**:
1. Go to your Slack workspace
2. Add "Incoming Webhooks" app
3. Create webhook for desired channel
4. Copy webhook URL

### Optional Secrets

| Secret Name | Description | Required |
|------------|-------------|----------|
| `CODECOV_TOKEN` | Codecov upload token | Optional |
| `GITLEAKS_LICENSE` | Gitleaks license key | Optional |

## Adding Secrets to GitHub

### Via GitHub UI

1. Go to repository on GitHub
2. Click Settings
3. Navigate to Secrets and variables → Actions
4. Click "New repository secret"
5. Enter name and value
6. Click "Add secret"

### Via GitHub CLI

```bash
# Install GitHub CLI
brew install gh  # macOS
# or
sudo apt install gh  # Ubuntu

# Login
gh auth login

# Add secret
gh secret set DOCKER_USERNAME
# Paste value when prompted

# Add secret from file
gh secret set FIREBASE_SERVICE_ACCOUNT < service-account.json
```

## Secret Management Best Practices

### Security

1. **Never commit secrets** to repository
2. **Rotate secrets regularly** (every 90 days)
3. **Use least privilege** - minimal permissions needed
4. **Monitor secret usage** in audit logs
5. **Delete unused secrets**

### Organization

1. **Use consistent naming** - uppercase with underscores
2. **Document all secrets** - what they're for
3. **Set expiration reminders** - calendar notifications
4. **Have backup access** - multiple team members

### Testing

1. **Test in development** first
2. **Verify secret access** in workflows
3. **Check logs** for errors (secrets are masked)
4. **Use dummy secrets** for testing pipelines

## Verification Checklist

Before first deployment, verify:

- [ ] All required secrets are added
- [ ] Secret names match exactly (case-sensitive)
- [ ] Secrets have correct permissions
- [ ] Workflows can access secrets
- [ ] Test deployment works

## Common Issues

### Secret not found

**Error**: `Secret DOCKER_PASSWORD not found`

**Solution**: 
- Check secret name spelling
- Verify secret is in correct repository
- Check if using organization vs. repository secret

### Permission denied

**Error**: `Authentication failed`

**Solution**:
- Verify secret value is correct
- Check token hasn't expired
- Ensure token has correct permissions

### Masked in logs

**Issue**: Can't see secret value in logs

**Note**: This is intentional - GitHub automatically masks secrets in logs for security.

## Secret Rotation Schedule

| Secret Type | Rotation Period |
|------------|----------------|
| API Tokens | Every 90 days |
| Passwords | Every 90 days |
| SSH Keys | Every 180 days |
| Service Accounts | Every 180 days |
| Certificates | Before expiration |

## Emergency Procedures

### Compromised Secret

1. **Immediately revoke** the compromised secret
2. **Generate new secret** on the service
3. **Update GitHub secret** with new value
4. **Audit usage** - check logs for unauthorized access
5. **Document incident** for review

### Lost Secret

1. **Generate new secret** on the service
2. **Update GitHub secret** with new value
3. **Test workflows** to ensure they work
4. **Document process** for team

## Support

For issues with secrets:
1. Check this documentation
2. Review workflow logs
3. Verify secret in GitHub settings
4. Contact DevOps team

## Resources

- [GitHub Secrets Documentation](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Vercel Tokens](https://vercel.com/docs/rest-api#authentication)
- [Firebase Service Accounts](https://firebase.google.com/docs/admin/setup#initialize-sdk)
- [Android App Signing](https://developer.android.com/studio/publish/app-signing)
