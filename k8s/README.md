# Kubernetes Deployment Guide

## Prerequisites

- kubectl installed
- Access to Kubernetes cluster
- Docker image pushed to registry

## Quick Start

### Deploy to Kubernetes

```bash
# Apply all manifests
kubectl apply -f k8s/

# Or apply individually
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/hpa.yaml
kubectl apply -f k8s/ingress.yaml
```

### Verify Deployment

```bash
# Check deployments
kubectl get deployments

# Check pods
kubectl get pods

# Check services
kubectl get services

# Check HPA
kubectl get hpa

# Check ingress
kubectl get ingress
```

### View Logs

```bash
# View logs
kubectl logs -f deployment/ridermate-web

# View logs for specific pod
kubectl logs -f <pod-name>
```

### Scale Manually

```bash
# Scale to 5 replicas
kubectl scale deployment ridermate-web --replicas=5
```

### Update Deployment

```bash
# Update image
kubectl set image deployment/ridermate-web web=ghcr.io/rithwikkr0/ridermate:v1.0.1

# Or edit deployment
kubectl edit deployment ridermate-web
```

### Rollback

```bash
# View rollout history
kubectl rollout history deployment/ridermate-web

# Rollback to previous version
kubectl rollout undo deployment/ridermate-web

# Rollback to specific revision
kubectl rollout undo deployment/ridermate-web --to-revision=2
```

## Cleanup

```bash
# Delete all resources
kubectl delete -f k8s/
```
