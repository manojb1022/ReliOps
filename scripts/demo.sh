#!/bin/bash
# SRE Portfolio Project - Demo Script
# This script demonstrates the SRE portfolio project capabilities

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
CLUSTER_NAME="sre-portfolio"
NAMESPACE="hello-api"
MINIKUBE_IP=""

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_demo() {
    echo -e "${PURPLE}[DEMO]${NC} $1"
}

log_step() {
    echo -e "${CYAN}[STEP]${NC} $1"
}

get_minikube_ip() {
    MINIKUBE_IP=$(minikube ip -p $CLUSTER_NAME 2>/dev/null || echo "localhost")
}

wait_for_user() {
    echo ""
    read -p "Press Enter to continue to the next step..."
    echo ""
}

show_demo_intro() {
    clear
    echo "=================================================="
    echo "    SRE Portfolio Project - Live Demo"
    echo "=================================================="
    echo ""
    echo "This demo will showcase:"
    echo "• Infrastructure as Code (Terraform)"
    echo "• Container Orchestration (Kubernetes)"
    echo "• CI/CD Pipeline (GitHub Actions)"
    echo "• Observability (Prometheus + Grafana)"
    echo "• Blue/Green Deployment"
    echo "• Auto-healing and Reliability"
    echo "• Security Scanning"
    echo ""
    echo "Prerequisites:"
    echo "• minikube cluster running"
    echo "• Application deployed"
    echo "• Monitoring stack running"
    echo ""
    wait_for_user
}

check_prerequisites() {
    log_step "Checking prerequisites..."
    
    # Check if minikube is running
    if ! minikube status -p $CLUSTER_NAME >/dev/null 2>&1; then
        log_error "Minikube cluster '$CLUSTER_NAME' is not running"
        log_info "Please run './scripts/setup.sh' first"
        exit 1
    fi
    
    # Check if application is deployed
    if ! kubectl get pods -n $NAMESPACE >/dev/null 2>&1; then
        log_error "Application is not deployed in namespace '$NAMESPACE'"
        log_info "Please run './scripts/setup.sh' first"
        exit 1
    fi
    
    get_minikube_ip
    log_success "Prerequisites check passed!"
    echo "Minikube IP: $MINIKUBE_IP"
    wait_for_user
}

demo_infrastructure() {
    log_step "1. Infrastructure as Code (Terraform)"
    
    log_demo "Showing Terraform configuration..."
    echo ""
    echo "Terraform files:"
    ls -la terraform/
    echo ""
    
    log_demo "Showing current infrastructure state..."
    kubectl get nodes -o wide
    echo ""
    
    log_demo "Showing namespaces..."
    kubectl get namespaces
    echo ""
    
    log_demo "Showing storage classes..."
    kubectl get storageclass
    echo ""
    
    wait_for_user
}

demo_application() {
    log_step "2. Application and Containerization"
    
    log_demo "Showing application structure..."
    echo ""
    echo "Application files:"
    ls -la app/
    echo ""
    
    log_demo "Showing Docker image..."
    docker images | grep hello-api
    echo ""
    
    log_demo "Showing application pods..."
    kubectl get pods -n $NAMESPACE -o wide
    echo ""
    
    log_demo "Showing application services..."
    kubectl get services -n $NAMESPACE
    echo ""
    
    log_demo "Testing application endpoints..."
    echo "Health check:"
    curl -s "http://$MINIKUBE_IP:30000/health" | jq . 2>/dev/null || curl -s "http://$MINIKUBE_IP:30000/health"
    echo ""
    
    echo "Main endpoint:"
    curl -s "http://$MINIKUBE_IP:30000/" | jq . 2>/dev/null || curl -s "http://$MINIKUBE_IP:30000/"
    echo ""
    
    wait_for_user
}

demo_monitoring() {
    log_step "3. Observability and Monitoring"
    
    log_demo "Showing Prometheus metrics..."
    echo ""
    echo "Application metrics endpoint:"
    curl -s "http://$MINIKUBE_IP:30000/metrics" | head -20
    echo "..."
    echo ""
    
    log_demo "Showing monitoring pods..."
    kubectl get pods -n monitoring
    echo ""
    
    log_demo "Showing monitoring services..."
    kubectl get services -n monitoring
    echo ""
    
    log_demo "Accessing Grafana dashboard..."
    echo "Grafana URL: http://$MINIKUBE_IP:30000"
    echo "Username: admin"
    echo "Password: admin123"
    echo ""
    echo "Opening Grafana in browser..."
    open "http://$MINIKUBE_IP:30000" 2>/dev/null || log_info "Please open http://$MINIKUBE_IP:30000 in your browser"
    echo ""
    
    wait_for_user
}

demo_blue_green() {
    log_step "4. Blue/Green Deployment"
    
    log_demo "Current deployment status..."
    ./scripts/deploy-blue-green.sh status
    echo ""
    
    log_demo "Deploying to green environment..."
    ./scripts/deploy-blue-green.sh green
    echo ""
    
    log_demo "Verifying green deployment..."
    kubectl get pods -n $NAMESPACE -l version=green
    echo ""
    
    log_demo "Testing green environment..."
    curl -s "http://$MINIKUBE_IP:30000/health" | jq . 2>/dev/null || curl -s "http://$MINIKUBE_IP:30000/health"
    echo ""
    
    log_demo "Switching back to blue environment..."
    ./scripts/deploy-blue-green.sh blue
    echo ""
    
    wait_for_user
}

demo_reliability() {
    log_step "5. Reliability and Auto-healing"
    
    log_demo "Showing current pod status..."
    kubectl get pods -n $NAMESPACE
    echo ""
    
    log_demo "Simulating pod failure..."
    echo "Deleting a pod to demonstrate auto-healing..."
    POD_NAME=$(kubectl get pods -n $NAMESPACE -l version=blue -o jsonpath='{.items[0].metadata.name}')
    kubectl delete pod $POD_NAME -n $NAMESPACE
    echo ""
    
    log_demo "Watching pod recreation..."
    echo "Waiting for pod to be recreated..."
    kubectl get pods -n $NAMESPACE -w --timeout=60s
    echo ""
    
    log_demo "Showing auto-scaling..."
    echo "Current HPA status:"
    kubectl get hpa -n $NAMESPACE
    echo ""
    
    wait_for_user
}

demo_load_testing() {
    log_step "6. Load Testing and Alerting"
    
    log_demo "Generating load to test monitoring..."
    echo "Running load test for 30 seconds..."
    echo ""
    
    # Generate load using curl in background
    for i in {1..100}; do
        curl -s "http://$MINIKUBE_IP:30000/" >/dev/null &
        curl -s "http://$MINIKUBE_IP:30000/simulate-latency?delay=0.1" >/dev/null &
        curl -s "http://$MINIKUBE_IP:30000/simulate-error?rate=0.05" >/dev/null &
    done
    
    echo "Load test running... Check Grafana dashboard for metrics"
    echo "Grafana URL: http://$MINIKUBE_IP:30000"
    echo ""
    
    sleep 30
    
    log_demo "Checking metrics after load test..."
    curl -s "http://$MINIKUBE_IP:30000/metrics" | grep -E "(http_requests_total|http_request_duration_seconds)" | head -10
    echo ""
    
    wait_for_user
}

demo_security() {
    log_step "7. Security and Best Practices"
    
    log_demo "Showing security configurations..."
    echo ""
    echo "Pod security context:"
    kubectl get pods -n $NAMESPACE -o jsonpath='{.items[0].spec.securityContext}' | jq . 2>/dev/null || echo "Security context configured"
    echo ""
    
    echo "Container security context:"
    kubectl get pods -n $NAMESPACE -o jsonpath='{.items[0].spec.containers[0].securityContext}' | jq . 2>/dev/null || echo "Container security context configured"
    echo ""
    
    log_demo "Showing resource limits..."
    kubectl describe deployment hello-api-blue -n $NAMESPACE | grep -A 10 "Limits\|Requests"
    echo ""
    
    log_demo "Showing network policies..."
    kubectl get networkpolicies -n $NAMESPACE 2>/dev/null || echo "No network policies configured"
    echo ""
    
    wait_for_user
}

demo_cicd() {
    log_step "8. CI/CD Pipeline"
    
    log_demo "Showing GitHub Actions workflow..."
    echo ""
    echo "CI/CD Pipeline stages:"
    echo "1. Lint & Test (pylint, black, pytest)"
    echo "2. Security Scan (Trivy)"
    echo "3. Build & Push (Docker)"
    echo "4. Deploy (Helm)"
    echo "5. Smoke Test"
    echo "6. Blue/Green Deployment"
    echo ""
    
    log_demo "Showing workflow file..."
    head -20 .github/workflows/ci-cd.yaml
    echo "..."
    echo ""
    
    log_demo "To trigger CI/CD pipeline:"
    echo "1. Push code to main branch"
    echo "2. Create a pull request"
    echo "3. Use workflow_dispatch for manual deployment"
    echo ""
    
    wait_for_user
}

show_demo_summary() {
    log_step "Demo Summary"
    
    echo "=================================================="
    echo "    SRE Portfolio Project - Demo Complete"
    echo "=================================================="
    echo ""
    echo "What we demonstrated:"
    echo "✅ Infrastructure as Code with Terraform"
    echo "✅ Container orchestration with Kubernetes"
    echo "✅ CI/CD pipeline with GitHub Actions"
    echo "✅ Observability with Prometheus & Grafana"
    echo "✅ Blue/Green deployment strategy"
    echo "✅ Auto-healing and reliability features"
    echo "✅ Security best practices"
    echo "✅ Load testing and alerting"
    echo ""
    echo "Access URLs:"
    echo "• Application: http://$MINIKUBE_IP:30000"
    echo "• Grafana: http://$MINIKUBE_IP:30000 (admin/admin123)"
    echo "• Prometheus: http://$MINIKUBE_IP:30000"
    echo ""
    echo "Useful commands:"
    echo "• View logs: kubectl logs -f deployment/hello-api-blue -n $NAMESPACE"
    echo "• Scale app: kubectl scale deployment hello-api-blue --replicas=3 -n $NAMESPACE"
    echo "• Blue/Green: ./scripts/deploy-blue-green.sh [blue|green]"
    echo "• Status: ./scripts/deploy-blue-green.sh status"
    echo ""
    echo "Thank you for watching the SRE Portfolio demo!"
    echo ""
}

# Main execution
main() {
    show_demo_intro
    check_prerequisites
    demo_infrastructure
    demo_application
    demo_monitoring
    demo_blue_green
    demo_reliability
    demo_load_testing
    demo_security
    demo_cicd
    show_demo_summary
}

# Run main function
main "$@"
