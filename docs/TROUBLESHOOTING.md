# Troubleshooting Guide

## Table of Contents
- [Build Issues](#build-issues)
- [Deployment Issues](#deployment-issues)
- [Runtime Issues](#runtime-issues)
- [Docker Issues](#docker-issues)
- [CI/CD Issues](#cicd-issues)
- [Performance Issues](#performance-issues)

## Build Issues

### Flutter Build Fails

#### Issue: "Flutter not found"
```
Error: flutter: command not found
```
**Solution**:
1. Verify Flutter is installed: `flutter --version`
2. Add Flutter to PATH
3. Run `flutter doctor` to diagnose issues

#### Issue: "Dependencies not found"
```
Error: Could not resolve dependencies
```
**Solution**:
```bash
flutter clean
rm pubspec.lock
flutter pub get
```

#### Issue: "Gradle build failed" (Android)
```
Error: Gradle build failed with exit code 1
```
**Solution**:
```bash
cd android
./gradlew clean
cd ..
flutter build apk
```

#### Issue: "CocoaPods error" (iOS)
```
Error: CocoaPods not installed
```
**Solution**:
```bash
sudo gem install cocoapods
cd ios
pod install
pod update
cd ..
flutter build ios
```

### Web Build Issues

#### Issue: "Canvas kit renderer error"
```
Error: Failed to compile with canvas kit
```
**Solution**:
```bash
# Try HTML renderer instead
flutter build web --web-renderer html

# Or auto renderer
flutter build web --web-renderer auto
```

### Docker Build Issues

#### Issue: "Docker build timeout"
```
Error: Build exceeded maximum time
```
**Solution**:
1. Increase build timeout
2. Use multi-stage build (already implemented)
3. Optimize layer caching
4. Use `.dockerignore` properly

#### Issue: "Out of disk space"
```
Error: No space left on device
```
**Solution**:
```bash
# Clean Docker system
docker system prune -a

# Remove unused images
docker image prune -a

# Remove build cache
docker builder prune
```

## Deployment Issues

### Vercel Deployment

#### Issue: "Build fails on Vercel"
```
Error: Build command failed
```
**Solution**:
1. Check `vercel.json` configuration
2. Verify build directory path
3. Check deployment logs in Vercel dashboard

#### Issue: "404 on refresh"
```
Error: Page not found on refresh
```
**Solution**:
Add to `vercel.json`:
```json
{
  "routes": [
    { "src": "/(.*)", "dest": "/index.html" }
  ]
}
```

### Firebase Deployment

#### Issue: "Authentication failed"
```
Error: Authentication error
```
**Solution**:
```bash
firebase login
firebase use --add  # Select project
```

#### Issue: "Hosting setup incomplete"
```
Error: No hosting configuration found
```
**Solution**:
```bash
firebase init hosting
# Follow prompts
```

### Docker Deployment

#### Issue: "Container exits immediately"
```
Container ridermate exited with code 1
```
**Solution**:
```bash
# Check logs
docker logs ridermate

# Run interactively to debug
docker run -it ridermate:latest /bin/sh
```

#### Issue: "Port already in use"
```
Error: Port 80 is already allocated
```
**Solution**:
```bash
# Use different port
docker run -p 8080:80 ridermate:latest

# Or stop conflicting container
docker ps
docker stop <container-id>
```

## Runtime Issues

### Application Errors

#### Issue: "White screen on load"
```
App shows blank white screen
```
**Solution**:
1. Check browser console for errors
2. Verify all assets are loaded
3. Check for JavaScript errors
4. Clear browser cache

#### Issue: "API calls failing"
```
Error: Network request failed
```
**Solution**:
1. Check API endpoint configuration
2. Verify CORS settings
3. Check network connectivity
4. Review API logs

#### Issue: "Firebase connection error"
```
Error: Firebase: Error (auth/configuration-not-found)
```
**Solution**:
1. Verify Firebase configuration in `.env`
2. Check `google-services.json` (Android)
3. Check `GoogleService-Info.plist` (iOS)
4. Initialize Firebase in code

### Performance Issues

#### Issue: "Slow initial load"
```
App takes too long to load
```
**Solution**:
1. Enable code splitting
2. Optimize images
3. Use CDN for static assets
4. Enable caching
5. Use `--web-renderer canvaskit` for better performance

#### Issue: "High memory usage"
```
App crashes due to memory
```
**Solution**:
1. Profile with Flutter DevTools
2. Check for memory leaks
3. Optimize image sizes
4. Implement lazy loading

## Docker Issues

### Container Issues

#### Issue: "Container health check failing"
```
Container is unhealthy
```
**Solution**:
```bash
# Check health status
docker inspect --format='{{.State.Health.Status}}' ridermate

# View health logs
docker inspect ridermate | jq '.[0].State.Health'

# Test health endpoint manually
curl http://localhost/health
```

#### Issue: "Volume mount not working"
```
Error: Files not syncing
```
**Solution**:
```bash
# Check volume mounts
docker inspect ridermate | jq '.[0].Mounts'

# Ensure correct permissions
chmod -R 755 ./ridermate_app

# For Windows, check Docker Desktop settings
```

### Docker Compose Issues

#### Issue: "Service fails to start"
```
Error: Service 'web' failed to build
```
**Solution**:
```bash
# View detailed logs
docker-compose logs web

# Rebuild without cache
docker-compose build --no-cache

# Start with verbose output
docker-compose up --verbose
```

#### Issue: "Network connectivity between services"
```
Error: Connection refused
```
**Solution**:
```bash
# Check network
docker network ls
docker network inspect ridermate-network

# Ensure services are on same network
# Use service names as hostnames
```

## CI/CD Issues

### GitHub Actions Issues

#### Issue: "Workflow not triggering"
```
Workflow doesn't run on push
```
**Solution**:
1. Check workflow file syntax
2. Verify trigger configuration
3. Check branch name matches
4. Ensure workflow is enabled

#### Issue: "Secret not found"
```
Error: Secret DOCKER_PASSWORD not found
```
**Solution**:
1. Add secret in GitHub Settings → Secrets
2. Verify secret name matches exactly
3. Check repository vs organization secrets
4. Verify access permissions

#### Issue: "Build cache not working"
```
Build takes too long every time
```
**Solution**:
```yaml
# Verify cache configuration
- uses: actions/cache@v3
  with:
    path: |
      ~/.pub-cache
    key: ${{ runner.os }}-pub-${{ hashFiles('**/pubspec.lock') }}
```

#### Issue: "Artifacts upload fails"
```
Error: Failed to upload artifacts
```
**Solution**:
1. Check artifact path is correct
2. Verify files exist after build
3. Check artifact size limits
4. Use correct artifact action version

### Docker Registry Issues

#### Issue: "Push to registry fails"
```
Error: Authentication required
```
**Solution**:
```bash
# Login to Docker Hub
docker login -u $DOCKER_USERNAME

# Login to GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin
```

#### Issue: "Image size too large"
```
Warning: Image size is XGB
```
**Solution**:
1. Use multi-stage builds (already implemented)
2. Minimize layers
3. Clean up in same RUN command
4. Use `.dockerignore`

## Performance Issues

### Build Performance

#### Issue: "Flutter build very slow"
```
Build takes 10+ minutes
```
**Solution**:
1. Use build cache
2. Parallelize where possible
3. Use `--release` mode only when needed
4. Enable `--split-debug-info`

### Runtime Performance

#### Issue: "App laggy on mobile"
```
UI stuttering and lag
```
**Solution**:
1. Profile with Flutter DevTools
2. Check for expensive operations in build()
3. Use `const` constructors
4. Implement `ListView.builder` for lists
5. Optimize images

#### Issue: "High CPU usage"
```
CPU usage at 100%
```
**Solution**:
1. Profile with DevTools
2. Check for infinite loops
3. Debounce frequent operations
4. Use isolates for heavy computation

## Getting Help

### Debug Steps
1. Check error logs
2. Review documentation
3. Search GitHub issues
4. Check Stack Overflow
5. Contact support

### Useful Commands

#### Flutter Diagnostics
```bash
flutter doctor -v
flutter analyze
flutter test --coverage
```

#### Docker Diagnostics
```bash
docker ps -a
docker logs <container>
docker inspect <container>
docker stats
```

#### Git Diagnostics
```bash
git status
git log --oneline -10
git remote -v
```

### Log Locations

- **Flutter logs**: `flutter logs`
- **Docker logs**: `docker logs <container>`
- **GitHub Actions logs**: Actions tab in GitHub
- **Web console**: Browser DevTools
- **Sentry**: Error tracking dashboard

### Support Channels

- GitHub Issues: https://github.com/rithwikkr0/Ridermate/issues
- Documentation: [docs/](.)
- Stack Overflow: Tag with `flutter` and `ridermate`

## Prevention

### Best Practices
1. Run tests before committing
2. Use linting and formatting
3. Review code before merging
4. Monitor error rates
5. Keep dependencies updated
6. Use semantic versioning
7. Document changes

### Monitoring
- Set up error tracking (Sentry)
- Configure uptime monitoring
- Enable performance monitoring
- Review logs regularly
- Set up alerts

## Common Error Codes

| Error Code | Meaning | Solution |
|------------|---------|----------|
| Exit 1 | General error | Check logs for details |
| Exit 127 | Command not found | Install required tool |
| Exit 137 | Out of memory | Increase memory limit |
| Exit 143 | Terminated | Check why container was stopped |
| 404 | Not found | Check URLs and routes |
| 500 | Server error | Check server logs |
| 502 | Bad gateway | Check upstream service |

## Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Docker Documentation](https://docs.docker.com/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Deployment Guide](DEPLOYMENT.md)
- [CI/CD Guide](CI_CD.md)
