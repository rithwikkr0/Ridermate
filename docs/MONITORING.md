# Monitoring & Logging Setup Guide

## Overview

This guide covers setting up comprehensive monitoring and logging for RiderMate application to ensure reliability, performance, and quick issue resolution.

## Monitoring Stack

### Application Monitoring
- **Sentry**: Error tracking and crash reporting
- **Firebase Analytics**: User behavior and app analytics
- **Google Analytics**: Web analytics (optional)

### Infrastructure Monitoring
- **UptimeRobot**: Uptime monitoring
- **Docker Stats**: Container resource monitoring
- **GitHub Actions**: CI/CD pipeline monitoring

### Performance Monitoring
- **Lighthouse CI**: Web performance monitoring
- **Firebase Performance**: Mobile performance monitoring

## Error Tracking with Sentry

### Setup Sentry

1. **Create Sentry Account**
   - Visit https://sentry.io
   - Create new organization
   - Create new project (Flutter)

2. **Get DSN**
   - Copy DSN from project settings
   - Add to `.env.production`:
     ```env
     SENTRY_DSN=https://xxxxx@xxxxx.ingest.sentry.io/xxxxx
     ```

3. **Install Sentry Package**
   ```bash
   cd ridermate_app
   flutter pub add sentry_flutter
   ```

4. **Initialize Sentry**
   
   Update `lib/main.dart`:
   ```dart
   import 'package:sentry_flutter/sentry_flutter.dart';
   
   Future<void> main() async {
     await SentryFlutter.init(
       (options) {
         options.dsn = 'YOUR_SENTRY_DSN';
         options.tracesSampleRate = 1.0;
         options.environment = 'production';
       },
       appRunner: () => runApp(RiderMateApp()),
     );
   }
   ```

5. **Capture Errors**
   ```dart
   try {
     // Your code
   } catch (error, stackTrace) {
     await Sentry.captureException(
       error,
       stackTrace: stackTrace,
     );
   }
   ```

### Sentry Configuration

#### Performance Monitoring
```dart
final transaction = Sentry.startTransaction(
  'ride_tracking',
  'task',
);

try {
  // Track ride
} catch (e) {
  transaction.status = SpanStatus.internalError();
  rethrow;
} finally {
  await transaction.finish();
}
```

#### User Context
```dart
Sentry.configureScope((scope) {
  scope.setUser(SentryUser(
    id: userId,
    email: userEmail,
    username: username,
  ));
});
```

#### Custom Tags
```dart
Sentry.configureScope((scope) {
  scope.setTag('feature', 'ride_tracking');
  scope.setTag('platform', 'mobile');
});
```

## Uptime Monitoring

### UptimeRobot Setup

1. **Create Account**
   - Visit https://uptimerobot.com
   - Create free account (50 monitors)

2. **Add Monitors**
   
   **Web Application**:
   - Monitor Type: HTTPS
   - URL: https://your-app.vercel.app
   - Interval: 5 minutes
   - Alert Contacts: Email, Slack
   
   **Health Endpoint**:
   - Monitor Type: HTTPS
   - URL: https://your-app.vercel.app/health
   - Keyword: "healthy"
   - Interval: 5 minutes

3. **Configure Alerts**
   - Email notifications
   - Slack integration
   - SMS (optional)
   - Webhook (optional)

### Alternative: Better Uptime

```bash
# Setup Better Uptime
1. Visit https://betteruptime.com
2. Add monitors for:
   - Main application
   - API endpoints
   - Health checks
3. Configure:
   - Check frequency: 60 seconds
   - Alert channels: Email, Slack
   - Incident management
```

## Application Analytics

### Firebase Analytics

1. **Setup Firebase**
   ```bash
   cd ridermate_app
   flutter pub add firebase_analytics
   flutter pub add firebase_core
   ```

2. **Initialize Firebase**
   ```dart
   import 'package:firebase_core/firebase_core.dart';
   import 'package:firebase_analytics/firebase_analytics.dart';
   
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp();
     runApp(RiderMateApp());
   }
   ```

3. **Track Events**
   ```dart
   final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
   
   // Track screen views
   await analytics.logScreenView(
     screenName: 'Home',
   );
   
   // Track custom events
   await analytics.logEvent(
     name: 'ride_started',
     parameters: {
       'distance': distance,
       'duration': duration,
     },
   );
   
   // Track user properties
   await analytics.setUserProperty(
     name: 'user_type',
     value: 'premium',
   );
   ```

## Performance Monitoring

### Firebase Performance

1. **Install Package**
   ```bash
   flutter pub add firebase_performance
   ```

2. **Setup Performance Monitoring**
   ```dart
   import 'package:firebase_performance/firebase_performance.dart';
   
   // Trace custom operations
   final Trace trace = FirebasePerformance.instance.newTrace('ride_processing');
   await trace.start();
   
   // Your operation
   processRideData();
   
   await trace.stop();
   ```

3. **Monitor HTTP Requests**
   ```dart
   final HttpMetric metric = FirebasePerformance.instance
     .newHttpMetric('https://api.example.com/rides', HttpMethod.Get);
   
   await metric.start();
   
   final response = await http.get(Uri.parse('...'));
   
   metric.responsePayloadSize = response.contentLength;
   metric.responseContentType = response.headers['Content-Type'];
   metric.httpResponseCode = response.statusCode;
   
   await metric.stop();
   ```

### Lighthouse CI

Add to GitHub Actions:
```yaml
- name: Run Lighthouse CI
  uses: treosh/lighthouse-ci-action@v9
  with:
    urls: |
      https://your-app.vercel.app
    uploadArtifacts: true
    temporaryPublicStorage: true
```

## Logging

### Application Logging

#### Setup Logger
```dart
import 'package:logger/logger.dart';

final logger = Logger(
  printer: PrettyPrinter(),
  level: Level.debug, // Set based on environment
);

// Usage
logger.d('Debug message');
logger.i('Info message');
logger.w('Warning message');
logger.e('Error message', error, stackTrace);
```

#### Environment-Based Logging
```dart
enum Environment { development, staging, production }

final env = Environment.production;

final logger = Logger(
  level: env == Environment.production 
    ? Level.warning 
    : Level.debug,
);
```

### Docker Logging

#### Configure Docker Logging
```yaml
# docker-compose.yml
services:
  web:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

#### View Logs
```bash
# View real-time logs
docker-compose logs -f web

# View last 100 lines
docker-compose logs --tail=100 web

# Export logs
docker logs ridermate > app.log 2>&1
```

## Monitoring Dashboards

### Sentry Dashboard

**Key Metrics**:
- Error frequency
- Error types
- Affected users
- Stack traces
- Release health

**Custom Dashboards**:
1. Go to Dashboards in Sentry
2. Create new dashboard
3. Add widgets:
   - Error rate over time
   - Most common errors
   - Errors by release
   - User impact

### Firebase Console

**Key Metrics**:
- Active users
- Session duration
- Screen views
- Custom events
- Performance traces

### Custom Monitoring Dashboard

Create a simple status page:

```html
<!DOCTYPE html>
<html>
<head>
  <title>RiderMate Status</title>
  <script src="https://unpkg.com/axios/dist/axios.min.js"></script>
</head>
<body>
  <h1>RiderMate System Status</h1>
  <div id="status"></div>
  
  <script>
    async function checkStatus() {
      try {
        const response = await axios.get('/health');
        document.getElementById('status').innerHTML = 
          '<p style="color: green">✅ All Systems Operational</p>';
      } catch (error) {
        document.getElementById('status').innerHTML = 
          '<p style="color: red">❌ System Down</p>';
      }
    }
    
    checkStatus();
    setInterval(checkStatus, 60000); // Check every minute
  </script>
</body>
</html>
```

## Alerting

### Alert Configuration

#### Sentry Alerts
```
1. Go to Alerts in Sentry
2. Create new alert rule:
   - When: Error count > 10 in 1 hour
   - Then: Send notification to #alerts Slack channel
   
3. Create performance alert:
   - When: P95 response time > 1000ms
   - Then: Send email to DevOps team
```

#### UptimeRobot Alerts
```
1. Configure alert contacts
2. Set up notification channels:
   - Email: immediate
   - Slack: immediate
   - SMS: for critical only
3. Define downtime threshold: 2 minutes
```

### Slack Integration

1. **Create Slack Webhook**
   ```
   1. Go to Slack App Directory
   2. Search "Incoming Webhooks"
   3. Add to workspace
   4. Create webhook URL
   5. Add to GitHub Secrets as SLACK_WEBHOOK
   ```

2. **Configure Notifications**
   - Deployment notifications
   - Error alerts
   - Uptime alerts
   - Performance degradation

## Health Checks

### Application Health Check

Add health endpoint to your web server (nginx):
```nginx
location /health {
    access_log off;
    return 200 "healthy\n";
    add_header Content-Type text/plain;
}
```

### Docker Health Check

Already configured in Dockerfile:
```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost/health || exit 1
```

### Monitor Health
```bash
# Check container health
docker inspect --format='{{.State.Health.Status}}' ridermate

# Continuous monitoring
watch -n 5 'docker inspect --format="{{.State.Health.Status}}" ridermate'
```

## Metrics Collection

### Custom Metrics

Track application-specific metrics:
```dart
class MetricsCollector {
  static Future<void> trackRideComplete(double distance, int duration) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'ride_complete',
      parameters: {
        'distance_km': distance,
        'duration_minutes': duration,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
  
  static Future<void> trackError(String errorType) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'error_occurred',
      parameters: {
        'error_type': errorType,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}
```

## Log Aggregation

### Using Cloud Logging

For production, consider:
- **Google Cloud Logging**
- **AWS CloudWatch**
- **Azure Monitor**
- **Datadog**
- **Loggly**

### Log Format

Use structured logging:
```dart
logger.i({
  'event': 'ride_started',
  'user_id': userId,
  'timestamp': DateTime.now().toIso8601String(),
  'metadata': {
    'location': location,
    'device': deviceInfo,
  }
});
```

## Best Practices

1. **Set Up Alerts Early**: Don't wait for issues
2. **Monitor Key Metrics**: Focus on what matters
3. **Regular Reviews**: Weekly metric reviews
4. **Test Alerting**: Ensure notifications work
5. **Document Incidents**: Learn from failures
6. **Rotate On-Call**: Prevent burnout
7. **Automate Response**: Where possible
8. **Keep Dashboards Simple**: Easy to understand at a glance

## Monitoring Checklist

- [ ] Error tracking configured (Sentry)
- [ ] Uptime monitoring active (UptimeRobot)
- [ ] Analytics integrated (Firebase)
- [ ] Performance monitoring enabled
- [ ] Health checks implemented
- [ ] Logging configured
- [ ] Alerts set up
- [ ] Dashboards created
- [ ] On-call rotation established
- [ ] Incident response plan documented

## Resources

- [Sentry Documentation](https://docs.sentry.io/)
- [Firebase Analytics](https://firebase.google.com/docs/analytics)
- [UptimeRobot Help](https://uptimerobot.com/help/)
- [Docker Logging](https://docs.docker.com/config/containers/logging/)
