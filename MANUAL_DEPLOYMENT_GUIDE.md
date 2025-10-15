# Manual Deployment Guide - Step by Step

## 📋 Overview
This guide walks you through **manually deploying** the entire DevOps platform so you understand every step.

---

## 🚀 PHASE 1: Create Kubernetes Cluster with Terraform

### Step 1: Navigate to terraform directory
```bash
cd /Users/b.manoj/ReliOps/terraform
```

### Step 2: Initialize Terraform (downloads providers)
```bash
terraform init
```
**What this does:**
- Downloads required Terraform providers (null, local)
- Sets up backend for state management
- Prepares Terraform workspace

### Step 3: Review what will be created
```bash
terraform plan
```
**What this shows:**
- All resources that will be created
- Cluster configuration details
- No actual changes yet (dry-run)

### Step 4: Create the cluster
```bash
terraform apply
```
**Type `yes` when prompted**

**What this does:**
- Starts minikube cluster named `devops-platform`
- Allocates 4 CPUs and 6GB RAM
- Installs Kubernetes v1.28.0
- Configures kubectl context
- Sets up Helm repositories
- Creates namespaces (portfolio, monitoring)

**This will take 2-3 minutes...**

### Step 5: Verify cluster is running
```bash
minikube status -p devops-platform
```
**Expected output:**
```
devops-platform
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
```

### Step 6: Check kubectl context
```bash
kubectl config current-context
```
**Should show:** `devops-platform`

### Step 7: View cluster nodes
```bash
kubectl get nodes
```
**Should show:** 1 node in Ready status

---

## 📦 PHASE 2: Build Docker Image

### Step 1: Navigate to portfolio directory
```bash
cd /Users/b.manoj/ReliOps/portfolio
```

### Step 2: Build the Docker image
```bash
docker build -t portfolio-app:latest .
```
**What this does:**
- Stage 1: Installs Node.js dependencies
- Stage 2: Builds Next.js production bundle
- Stage 3: Creates minimal runtime image
- Creates non-root user for security
- Adds health checks

**This will take 3-5 minutes...**

### Step 3: Verify image was created
```bash
docker images | grep portfolio-app
```
**Expected output:**
```
portfolio-app    latest    abc123def456    1 minute ago    150MB
```

### Step 4: Load image into minikube
```bash
minikube image load portfolio-app:latest -p devops-platform
```
**What this does:**
- Copies Docker image into minikube's Docker daemon
- Makes image available to Kubernetes pods

### Step 5: Verify image in minikube
```bash
minikube image ls -p devops-platform | grep portfolio
```

---

## ☸️ PHASE 3: Deploy Application with Helm

### Step 1: Navigate back to project root
```bash
cd /Users/b.manoj/ReliOps
```

### Step 2: Review Helm chart
```bash
helm lint ./helm/portfolio
```
**What this does:**
- Validates Helm chart syntax
- Checks for errors in templates

### Step 3: Dry-run deployment (see what will be created)
```bash
helm install portfolio ./helm/portfolio --dry-run --debug
```
**What this shows:**
- All Kubernetes manifests that will be created
- No actual deployment yet

### Step 4: Deploy the application
```bash
helm install portfolio ./helm/portfolio --namespace default --wait
```
**What this creates:**
- Deployment with 2 replicas
- Service (NodePort on 30100)
- HorizontalPodAutoscaler (scales 2-5 pods)
- ServiceAccount
- ServiceMonitor (for Prometheus)

**This will take 1-2 minutes...**

### Step 5: Watch pods starting
```bash
kubectl get pods -l app=portfolio -w
```
**Press Ctrl+C to stop watching**

**Expected output:**
```
NAME                        READY   STATUS    RESTARTS   AGE
portfolio-xxx-yyy           1/1     Running   0          30s
portfolio-xxx-zzz           1/1     Running   0          30s
```

### Step 6: Check all created resources
```bash
# Pods
kubectl get pods -l app=portfolio

# Service
kubectl get svc -l app=portfolio

# HPA (Auto-scaler)
kubectl get hpa

# ServiceMonitor (Prometheus)
kubectl get servicemonitor
```

---

## 🌐 PHASE 4: Access the Application

### Step 1: Get minikube IP
```bash
minikube ip -p devops-platform
```
**Save this IP (e.g., 192.168.49.2)**

### Step 2: Get NodePort
```bash
kubectl get svc portfolio-portfolio -o jsonpath='{.spec.ports[0].nodePort}'
echo ""
```
**Should show:** `30100`

### Step 3: Access the application
```bash
# Method 1: Open in browser
open http://$(minikube ip -p devops-platform):30100

# Method 2: Use curl
curl http://$(minikube ip -p devops-platform):30100
```

### Step 4: Test health endpoint
```bash
curl http://$(minikube ip -p devops-platform):30100/api/health
```
**Expected response:**
```json
{
  "status": "healthy",
  "timestamp": "2024-...",
  "uptime": 123.45,
  "service": "portfolio-app",
  "version": "1.0.0"
}
```

### Step 5: Test metrics endpoint (for Prometheus)
```bash
curl http://$(minikube ip -p devops-platform):30100/api/metrics
```
**Expected response:** Prometheus metrics format

---

## 📊 PHASE 5: Deploy Monitoring Stack

### Step 1: Add Helm repositories (if not already added)
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

### Step 2: Install Prometheus
```bash
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --values monitoring/prometheus/prometheus-values.yaml \
  --wait
```
**This will take 3-5 minutes...**

### Step 3: Check Prometheus pods
```bash
kubectl get pods -n monitoring | grep prometheus
```

### Step 4: Access Prometheus UI
```bash
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
```
**Open:** http://localhost:9090

### Step 5: Install Grafana
```bash
helm install grafana grafana/grafana \
  --namespace monitoring \
  --values monitoring/grafana/grafana-values.yaml \
  --wait
```

### Step 6: Get Grafana admin password
```bash
kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode
echo ""
```

### Step 7: Access Grafana
```bash
# Method 1: Port forward
kubectl port-forward -n monitoring svc/grafana 3001:80

# Method 2: NodePort (if configured)
open http://$(minikube ip -p devops-platform):30000
```

**Login:** admin / (password from step 6)

---

## 🔍 PHASE 6: Verify Everything

### Check all pods across all namespaces
```bash
kubectl get pods --all-namespaces
```

### Check all services
```bash
kubectl get svc --all-namespaces
```

### Check HPA status
```bash
kubectl get hpa -w
```

### View application logs
```bash
kubectl logs -l app=portfolio -f
```

### Describe a pod (detailed info)
```bash
kubectl describe pod $(kubectl get pods -l app=portfolio -o jsonpath='{.items[0].metadata.name}')
```

---

## 🎯 INTERVIEW DEMO CHECKLIST

### 1. Show Infrastructure as Code
```bash
cd terraform
cat main.tf  # Show Terraform configuration
terraform show  # Show current state
```

### 2. Show Containerization
```bash
cd portfolio
cat Dockerfile  # Show multi-stage build
docker images portfolio-app  # Show image
```

### 3. Show Kubernetes Deployment
```bash
kubectl get all -l app=portfolio
kubectl describe deployment portfolio-portfolio
```

### 4. Show Auto-scaling
```bash
kubectl get hpa
kubectl top pods -l app=portfolio  # Show resource usage
```

### 5. Show Monitoring
- Open Grafana dashboard
- Show Prometheus metrics
- Demonstrate custom metrics endpoint

### 6. Show Health Checks
```bash
curl http://$(minikube ip -p devops-platform):30100/api/health
curl http://$(minikube ip -p devops-platform):30100/api/ready
```

---

## 🧪 PHASE 7: Test Auto-scaling

### Generate load to trigger HPA
```bash
# Terminal 1: Watch HPA
kubectl get hpa -w

# Terminal 2: Generate load
for i in {1..1000}; do
  curl -s http://$(minikube ip -p devops-platform):30100/ > /dev/null
  sleep 0.1
done
```

**You should see:**
- CPU usage increase
- HPA trigger scaling
- New pods being created
- Pods automatically scale from 2 to 3, 4, or 5

---

## 🛠️ Troubleshooting Commands

### Pod not starting?
```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Service not accessible?
```bash
kubectl get endpoints portfolio-portfolio
kubectl describe svc portfolio-portfolio
```

### Image pull issues?
```bash
minikube image ls -p devops-platform | grep portfolio
# If missing, reload:
minikube image load portfolio-app:latest -p devops-platform
```

### Reset everything?
```bash
# Delete Helm release
helm uninstall portfolio

# Rebuild and redeploy
docker build -t portfolio-app:latest ./portfolio
minikube image load portfolio-app:latest -p devops-platform
helm install portfolio ./helm/portfolio --wait
```

---

## 🧹 Cleanup (After Demo)

### Step 1: Delete Helm releases
```bash
helm uninstall portfolio
helm uninstall prometheus -n monitoring
helm uninstall grafana -n monitoring
```

### Step 2: Delete cluster with Terraform
```bash
cd terraform
terraform destroy
```
**Type `yes` when prompted**

---

## 📚 Key Concepts to Explain in Interview

### 1. **Infrastructure as Code (Terraform)**
"I use Terraform to provision the Kubernetes cluster programmatically, ensuring reproducible and version-controlled infrastructure."

### 2. **Containerization (Docker)**
"Multi-stage Docker builds reduce image size, non-root users enhance security, and health checks enable auto-healing."

### 3. **Orchestration (Kubernetes)**
"Kubernetes manages container lifecycle, auto-healing, and provides declarative configuration for desired state."

### 4. **Package Management (Helm)**
"Helm charts template Kubernetes manifests, enabling reusable, parameterized deployments across environments."

### 5. **Auto-scaling (HPA)**
"Horizontal Pod Autoscaler monitors CPU/memory and scales pods automatically based on load."

### 6. **Observability (Prometheus/Grafana)**
"Custom metrics endpoints expose application health, Prometheus scrapes them, Grafana visualizes the data."

### 7. **CI/CD Ready**
"This setup is automated via GitHub Actions, enabling continuous deployment with every commit."

---

## 🎉 Success Criteria

✅ Cluster created and healthy  
✅ Application deployed with 2+ pods  
✅ Service accessible on NodePort 30100  
✅ Health checks passing  
✅ Metrics endpoint working  
✅ HPA configured and monitoring  
✅ Can access via browser  
✅ Logs are viewable  

**You're now ready to showcase a production-grade DevOps platform!** 🚀

