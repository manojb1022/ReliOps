#!/bin/bash
set -e

# Deploy Portfolio Application to Kubernetes
# This script builds the Docker image, loads it to minikube, and deploys using Helm

echo "========================================="
echo "Portfolio Application Deployment"
echo "========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
IMAGE_NAME="portfolio-app"
IMAGE_TAG="latest"
NAMESPACE="default"
RELEASE_NAME="portfolio"

# Step 1: Build Docker image
echo -e "${BLUE}Step 1: Building Docker image${NC}"
cd portfolio
docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
echo -e "${GREEN}✓ Docker image built successfully${NC}"
echo ""

# Step 2: Load image to minikube
echo -e "${BLUE}Step 2: Loading image to minikube${NC}"
cd ..
minikube image load ${IMAGE_NAME}:${IMAGE_TAG}
echo -e "${GREEN}✓ Image loaded to minikube${NC}"
echo ""

# Step 3: Deploy with Helm
echo -e "${BLUE}Step 3: Deploying with Helm${NC}"
helm upgrade --install ${RELEASE_NAME} ./helm/portfolio \
  --namespace ${NAMESPACE} \
  --set image.repository=${IMAGE_NAME} \
  --set image.tag=${IMAGE_TAG} \
  --wait \
  --timeout 5m
echo -e "${GREEN}✓ Helm deployment completed${NC}"
echo ""

# Step 4: Wait for pods to be ready
echo -e "${BLUE}Step 4: Waiting for pods to be ready${NC}"
kubectl wait --for=condition=ready pod \
  -l app=portfolio,release=${RELEASE_NAME} \
  --timeout=300s \
  -n ${NAMESPACE}
echo -e "${GREEN}✓ All pods are ready${NC}"
echo ""

# Step 5: Display deployment info
echo -e "${BLUE}Step 5: Deployment Information${NC}"
echo ""
echo -e "${YELLOW}Pods:${NC}"
kubectl get pods -l app=portfolio -n ${NAMESPACE}
echo ""
echo -e "${YELLOW}Services:${NC}"
kubectl get svc -l app=portfolio -n ${NAMESPACE}
echo ""
echo -e "${YELLOW}HPA:${NC}"
kubectl get hpa -n ${NAMESPACE}
echo ""

# Step 6: Get access URL
NODE_PORT=$(kubectl get svc ${RELEASE_NAME}-portfolio -n ${NAMESPACE} -o jsonpath='{.spec.ports[0].nodePort}')
MINIKUBE_IP=$(minikube ip)

echo "========================================="
echo -e "${GREEN}✓ Deployment Successful!${NC}"
echo "========================================="
echo ""
echo -e "${YELLOW}Access your portfolio at:${NC}"
echo -e "${GREEN}http://${MINIKUBE_IP}:${NODE_PORT}${NC}"
echo ""
echo -e "${YELLOW}Health Check:${NC}"
echo -e "http://${MINIKUBE_IP}:${NODE_PORT}/api/health"
echo ""
echo -e "${YELLOW}Metrics:${NC}"
echo -e "http://${MINIKUBE_IP}:${NODE_PORT}/api/metrics"
echo ""
echo -e "${YELLOW}View logs:${NC}"
echo "kubectl logs -l app=portfolio -f"
echo ""

