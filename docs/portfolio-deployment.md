# Portfolio Application Deployment Guide

## Overview
This guide explains how to deploy the Next.js portfolio application to Kubernetes with full DevOps practices including:
- ✅ Docker containerization
- ✅ Kubernetes deployment with Helm
- ✅ Auto-scaling (HPA)
- ✅ Health checks & readiness probes
- ✅ Prometheus metrics
- ✅ Grafana monitoring dashboard
- ✅ CI/CD pipeline
- ✅ Centralized logging

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     Users/Browser                        │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
        ┌─────────────────────────────┐
        │   NodePort Service (30100)   │
        └─────────────┬───────────────┘
                      │
         ┌────────────┴────────────┐
         │                         │
         ▼                         ▼
┌──────────────┐          ┌──────────────┐
│  Portfolio   │          │  Portfolio   │
│   Pod 1      │    ...   │   Pod N      │
│ (Next.js)    │          │ (Next.js)    │
└──────┬───────┘          └──────┬───────┘
       │                         │
       ├─────────────┬───────────┤
       │             │           │
       ▼             ▼           ▼
┌──────────┐  ┌──────────┐  ┌──────────┐
│Prometheus│  │ Grafana  │  │   Loki   │
│ (Metrics)│  │(Dashboard)│  │  (Logs)  │
└──────────┘  └──────────┘  └──────────┘
```

## Prerequisites
- Minikube running
- kubectl configured
- Helm installed
- Docker installed

## Quick Deploy

```bash
# Deploy everything
./scripts/deploy-portfolio.sh
```

## Manual Deployment Steps

### 1. Build Docker Image
```bash
cd portfolio
docker build -t portfolio-app:latest .
```

### 2. Load Image to Minikube
```bash
minikube image load portfolio-app:latest
```

### 3. Deploy with Helm
```bash
helm install portfolio ./helm/portfolio \
  --namespace default \
  --wait
```

### 4. Verify Deployment
```bash
# Check pods
kubectl get pods -l app=portfolio

# Check service
kubectl get svc -l app=portfolio

# Check HPA
kubectl get hpa
```

## Accessing the Application

### Get Access URL
```bash
minikube ip
kubectl get svc portfolio-portfolio -o jsonpath='{.spec.ports[0].nodePort}'
```

### Access Points
- **Application**: `http://<minikube-ip>:30100`
- **Health Check**: `http://<minikube-ip>:30100/api/health`
- **Ready Check**: `http://<minikube-ip>:30100/api/ready`
- **Metrics**: `http://<minikube-ip>:30100/api/metrics`

## Monitoring & Observability

### Prometheus Metrics
The application exposes Prometheus metrics at `/api/metrics`:
- `process_uptime_seconds` - Application uptime
- `process_memory_usage_bytes` - Memory usage by type
- `http_requests_total` - Total HTTP requests
- `nodejs_app_info` - Application metadata

### Grafana Dashboard
1. Access Grafana: `http://<minikube-ip>:30000`
2. Login: admin / admin
3. Navigate to "Portfolio App Dashboard"
4. View metrics:
   - Application status
   - Uptime
   - Pod count
   - Memory usage
   - HTTP requests
   - CPU usage
   - Network I/O

### Viewing Logs
```bash
# All portfolio pods
kubectl logs -l app=portfolio -f

# Specific pod
kubectl logs <pod-name> -f

# Last 100 lines
kubectl logs -l app=portfolio --tail=100
```

## Auto-Scaling

### Horizontal Pod Autoscaler (HPA)
The application is configured to autoscale based on:
- **CPU**: Target 75% utilization
- **Memory**: Target 80% utilization
- **Min replicas**: 2
- **Max replicas**: 5

```bash
# Watch HPA in action
kubectl get hpa -w

# Describe HPA
kubectl describe hpa portfolio-portfolio
```

### Load Testing
```bash
# Generate load to trigger autoscaling
while true; do
  curl http://<minikube-ip>:30100/
  sleep 0.1
done
```

## Health Checks

### Liveness Probe
- Endpoint: `/api/health`
- Initial Delay: 30s
- Period: 10s
- Timeout: 5s
- Failure Threshold: 3

### Readiness Probe
- Endpoint: `/api/ready`
- Initial Delay: 10s
- Period: 5s
- Timeout: 3s
- Failure Threshold: 3

## CI/CD Pipeline

The GitHub Actions pipeline includes:

### 1. Lint & Test
- ESLint
- TypeScript compilation
- Build verification

### 2. Security Scan
- npm audit
- Trivy vulnerability scanning

### 3. Build & Push
- Docker image build
- Image tagging
- Artifact upload

### 4. Deploy
- Helm deployment
- Rolling update
- Wait for readiness

### 5. Post-Deployment
- Health checks
- Smoke tests

## Troubleshooting

### Pods Not Starting
```bash
# Check pod status
kubectl describe pod <pod-name>

# Check pod logs
kubectl logs <pod-name>

# Check events
kubectl get events --sort-by=.metadata.creationTimestamp
```

### Image Pull Issues
```bash
# Verify image in minikube
minikube image ls | grep portfolio

# Reload image
minikube image load portfolio-app:latest
```

### Service Not Accessible
```bash
# Check service
kubectl get svc portfolio-portfolio

# Check endpoints
kubectl get endpoints portfolio-portfolio

# Port forward for testing
kubectl port-forward svc/portfolio-portfolio 3000:3000
```

## Cleanup

```bash
# Delete Helm release
helm uninstall portfolio

# Delete all resources
kubectl delete all -l app=portfolio

# Delete HPA
kubectl delete hpa portfolio-portfolio
```

## Interview Demo Points

When showcasing this in an interview, highlight:

1. **Full DevOps Lifecycle**
   - Containerization with multi-stage Docker builds
   - Kubernetes orchestration
   - Helm charts for package management

2. **Reliability Engineering**
   - Health checks and readiness probes
   - Auto-healing capabilities
   - Horizontal Pod Autoscaling

3. **Observability**
   - Prometheus metrics integration
   - Custom Grafana dashboards
   - Structured logging

4. **Security**
   - Non-root containers
   - Security scanning in CI/CD
   - Resource limits

5. **CI/CD**
   - Automated testing
   - Security scanning
   - Automated deployment

6. **Production-Ready Features**
   - Zero-downtime deployments
   - Auto-scaling
   - Monitoring & alerting
   - High availability (2+ replicas)

## Next Steps

1. Set up persistent storage for logs
2. Configure ingress controller
3. Add SSL/TLS certificates
4. Implement blue/green deployments
5. Add more comprehensive tests
6. Set up alerts in Prometheus

