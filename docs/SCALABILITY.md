# Scalability Guide

## Overview

This guide covers strategies for scaling RiderMate application to handle growth in users, data, and traffic.

## Current Architecture

```
┌─────────────────────────────────────────────────────┐
│                    Load Balancer                     │
│                    (Optional)                        │
└──────────────────────┬──────────────────────────────┘
                       │
         ┌─────────────┴─────────────┐
         │                           │
    ┌────▼────┐                 ┌────▼────┐
    │  Web    │                 │  Web    │
    │  Server │                 │  Server │
    │ (nginx) │                 │ (nginx) │
    └────┬────┘                 └────┬────┘
         │                           │
         └─────────────┬─────────────┘
                       │
              ┌────────▼────────┐
              │   Firestore     │
              │   (Database)    │
              └─────────────────┘
```

## Horizontal Scaling

### Web Application

#### Docker Swarm
```bash
# Initialize swarm
docker swarm init

# Deploy stack
docker stack deploy -c docker-compose.yml ridermate

# Scale web service
docker service scale ridermate_web=5
```

#### Docker Compose (Development)
```yaml
version: '3.8'
services:
  web:
    image: ridermate:latest
    deploy:
      replicas: 3
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
      restart_policy:
        condition: on-failure
```

### Kubernetes Deployment

#### Deployment Manifest
```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ridermate-web
  labels:
    app: ridermate
spec:
  replicas: 3
  selector:
    matchLabels:
      app: ridermate
  template:
    metadata:
      labels:
        app: ridermate
    spec:
      containers:
      - name: web
        image: ghcr.io/rithwikkr0/ridermate:latest
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
```

#### Service
```yaml
# k8s/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: ridermate-service
spec:
  type: LoadBalancer
  selector:
    app: ridermate
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

#### Horizontal Pod Autoscaler
```yaml
# k8s/hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: ridermate-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: ridermate-web
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

## Load Balancing

### nginx Load Balancer

```nginx
# nginx-lb.conf
upstream ridermate_backend {
    least_conn;  # Load balancing method
    server web1:80 max_fails=3 fail_timeout=30s;
    server web2:80 max_fails=3 fail_timeout=30s;
    server web3:80 max_fails=3 fail_timeout=30s;
    
    # Health check (nginx plus)
    # health_check interval=10s;
}

server {
    listen 80;
    server_name ridermate.com;
    
    location / {
        proxy_pass http://ridermate_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
    
    # Health check endpoint
    location /health {
        access_log off;
        return 200 "healthy\n";
    }
}
```

### Cloud Load Balancers

#### Google Cloud Load Balancer
```bash
# Create instance group
gcloud compute instance-groups managed create ridermate-group \
  --base-instance-name ridermate \
  --size 3 \
  --template ridermate-template

# Create health check
gcloud compute health-checks create http ridermate-health-check \
  --port 80 \
  --request-path /health

# Create backend service
gcloud compute backend-services create ridermate-backend \
  --protocol HTTP \
  --health-checks ridermate-health-check \
  --global

# Add instance group to backend
gcloud compute backend-services add-backend ridermate-backend \
  --instance-group ridermate-group \
  --global

# Create URL map
gcloud compute url-maps create ridermate-lb \
  --default-service ridermate-backend

# Create HTTP proxy
gcloud compute target-http-proxies create ridermate-proxy \
  --url-map ridermate-lb

# Create forwarding rule
gcloud compute forwarding-rules create ridermate-forwarding-rule \
  --global \
  --target-http-proxy ridermate-proxy \
  --ports 80
```

## Database Scaling

### Firestore Scaling

Firestore automatically scales, but optimize usage:

#### Indexing
```javascript
// Create composite indexes for common queries
// firestore.indexes.json
{
  "indexes": [
    {
      "collectionGroup": "rides",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "userId", "order": "ASCENDING" },
        { "fieldPath": "timestamp", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "memories",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "privacy", "order": "ASCENDING" },
        { "fieldPath": "likes", "order": "DESCENDING" }
      ]
    }
  ]
}
```

#### Query Optimization
```dart
// Limit query results
final rides = await firestore
  .collection('rides')
  .where('userId', isEqualTo: userId)
  .orderBy('timestamp', descending: true)
  .limit(50)  // Limit results
  .get();

// Use pagination
final firstPage = await firestore
  .collection('rides')
  .limit(20)
  .get();

final lastDoc = firstPage.docs.last;

final secondPage = await firestore
  .collection('rides')
  .startAfterDocument(lastDoc)
  .limit(20)
  .get();
```

#### Batch Operations
```dart
// Use batch writes
final batch = firestore.batch();

for (var ride in rides) {
  batch.set(
    firestore.collection('rides').doc(ride.id),
    ride.toJson(),
  );
}

await batch.commit();  // Single network call
```

### Caching Strategy

#### Redis Cache
```yaml
# docker-compose.yml
services:
  redis:
    image: redis:alpine
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
    command: redis-server --appendonly yes

volumes:
  redis-data:
```

#### Implement Caching
```dart
import 'package:redis/redis.dart';

class CacheService {
  final RedisConnection conn = RedisConnection();
  Command? _command;
  
  Future<void> connect() async {
    _command = await conn.connect('localhost', 6379);
  }
  
  Future<void> set(String key, String value, {int ttl = 3600}) async {
    await _command?.send_object(['SET', key, value, 'EX', ttl]);
  }
  
  Future<String?> get(String key) async {
    return await _command?.send_object(['GET', key]);
  }
  
  // Cache user data
  Future<User?> getUserCached(String userId) async {
    final cached = await get('user:$userId');
    if (cached != null) {
      return User.fromJson(jsonDecode(cached));
    }
    
    // Fetch from Firestore
    final user = await fetchUserFromFirestore(userId);
    
    // Cache for 1 hour
    await set('user:$userId', jsonEncode(user.toJson()), ttl: 3600);
    
    return user;
  }
}
```

## CDN Configuration

### Cloudflare Setup

1. **Add Site to Cloudflare**
   - Sign up at cloudflare.com
   - Add ridermate.com
   - Update nameservers

2. **Configure Caching**
   ```
   Page Rules:
   - ridermate.com/assets/*
     - Cache Level: Cache Everything
     - Edge Cache TTL: 1 month
   
   - ridermate.com/api/*
     - Cache Level: Bypass
   ```

3. **Performance Optimizations**
   - Enable Brotli compression
   - Enable Auto Minify (JS, CSS, HTML)
   - Enable Rocket Loader
   - Enable HTTP/3

### Asset Optimization

#### Image Optimization
```dart
// Use cached network image
import 'package:cached_network_image/cached_network_image.dart';

CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
  maxHeightDiskCache: 1000,
  maxWidthDiskCache: 1000,
)
```

#### Lazy Loading
```dart
// Implement lazy loading for lists
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    // Only build visible items
    return ItemWidget(items[index]);
  },
)
```

## Auto-Scaling Policies

### Cloud Run Auto-Scaling

```bash
# Deploy with auto-scaling
gcloud run deploy ridermate \
  --image gcr.io/PROJECT_ID/ridermate \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --min-instances 1 \
  --max-instances 100 \
  --cpu 1 \
  --memory 512Mi \
  --concurrency 80
```

### AWS ECS Auto-Scaling

```json
{
  "family": "ridermate",
  "taskDefinition": {
    "containerDefinitions": [
      {
        "name": "web",
        "image": "ghcr.io/rithwikkr0/ridermate:latest",
        "memory": 512,
        "cpu": 256,
        "essential": true,
        "portMappings": [
          {
            "containerPort": 80,
            "hostPort": 80
          }
        ]
      }
    ]
  },
  "autoScaling": {
    "targetTrackingScaling": {
      "targetValue": 70,
      "scaleInCooldown": 300,
      "scaleOutCooldown": 60,
      "predefinedMetricType": "ECSServiceAverageCPUUtilization"
    },
    "minCapacity": 2,
    "maxCapacity": 10
  }
}
```

## Performance Optimization

### Code Splitting

Already handled by Flutter web build:
```bash
flutter build web --release --split-debug-info=debug-info/ --obfuscate
```

### Progressive Web App (PWA)

Update `web/manifest.json`:
```json
{
  "name": "RiderMate",
  "short_name": "RiderMate",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#000000",
  "theme_color": "#0066FF",
  "description": "Cycling & Ride Tracking App",
  "icons": [
    {
      "src": "icons/icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "icons/icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
```

Add service worker for offline support.

## Monitoring Scalability

### Key Metrics

```yaml
# Metrics to monitor
- Response Time (p50, p95, p99)
- Request Rate (requests/second)
- Error Rate (%)
- CPU Utilization (%)
- Memory Usage (MB)
- Active Connections
- Queue Depth
- Cache Hit Rate (%)
```

### Alerting Thresholds

```yaml
alerts:
  - name: high_cpu
    condition: cpu > 80%
    duration: 5m
    action: scale_up
    
  - name: high_memory
    condition: memory > 85%
    duration: 5m
    action: scale_up
    
  - name: high_response_time
    condition: p95_response_time > 1000ms
    duration: 2m
    action: investigate
    
  - name: high_error_rate
    condition: error_rate > 1%
    duration: 1m
    action: alert_immediately
```

## Cost Optimization

### Right-Sizing
- Monitor resource usage
- Scale down during off-peak
- Use spot/preemptible instances
- Implement auto-scaling

### Caching
- Reduce database calls
- CDN for static assets
- Browser caching
- API response caching

### Database Optimization
- Efficient queries
- Proper indexing
- Connection pooling
- Read replicas (if needed)

## Best Practices

1. **Design for Horizontal Scaling**: Stateless services
2. **Use Load Balancers**: Distribute traffic
3. **Implement Caching**: Reduce database load
4. **Optimize Queries**: Minimize database operations
5. **Monitor Continuously**: Track key metrics
6. **Auto-Scale**: Respond to demand automatically
7. **Test at Scale**: Load testing regularly
8. **Plan for Failure**: Redundancy and failover
9. **Document Changes**: Keep scaling docs updated
10. **Cost Awareness**: Monitor and optimize costs

## Scaling Roadmap

### Phase 1: Current (0-1K users)
- Single server deployment
- Firestore database
- Basic monitoring

### Phase 2: Growth (1K-10K users)
- Multiple server instances
- Load balancer
- CDN for static assets
- Enhanced monitoring

### Phase 3: Scale (10K-100K users)
- Auto-scaling
- Redis caching
- Database optimization
- Advanced monitoring

### Phase 4: Enterprise (100K+ users)
- Kubernetes orchestration
- Multi-region deployment
- Advanced caching strategies
- Dedicated support team

## Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Docker Swarm](https://docs.docker.com/engine/swarm/)
- [Google Cloud Auto-scaling](https://cloud.google.com/compute/docs/autoscaler)
- [Firestore Best Practices](https://cloud.google.com/firestore/docs/best-practices)
