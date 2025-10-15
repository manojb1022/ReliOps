#!/bin/bash
# SRE Portfolio Project - Blue/Green Deployment Script
# This script handles blue/green deployment switching

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CLUSTER_NAME="sre-portfolio"
NAMESPACE="hello-api"
SERVICE_NAME="hello-api"

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

show_usage() {
    echo "Usage: $0 [blue|green]"
    echo ""
    echo "Options:"
    echo "  blue   - Switch traffic to blue environment"
    echo "  green  - Switch traffic to green environment"
    echo "  status - Show current deployment status"
    echo ""
    echo "Examples:"
    echo "  $0 green    # Deploy and switch to green"
    echo "  $0 blue     # Switch back to blue"
    echo "  $0 status   # Show current status"
}

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if kubectl is available
    if ! command -v kubectl >/dev/null 2>&1; then
        log_error "kubectl is not installed or not in PATH"
        exit 1
    fi
    
    # Check if helm is available
    if ! command -v helm >/dev/null 2>&1; then
        log_error "helm is not installed or not in PATH"
        exit 1
    fi
    
    # Check if cluster is accessible
    if ! kubectl cluster-info >/dev/null 2>&1; then
        log_error "Cannot connect to Kubernetes cluster"
        exit 1
    fi
    
    log_success "Prerequisites check passed!"
}

get_current_traffic() {
    # Get current service selector to determine which environment is receiving traffic
    local current_selector=$(kubectl get service $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.spec.selector.version}' 2>/dev/null || echo "unknown")
    echo "$current_selector"
}

deploy_environment() {
    local environment=$1
    local image_tag=$2
    
    log_info "Deploying $environment environment..."
    
    # Deploy the environment
    helm upgrade --install hello-api-$environment ./helm/hello-api \
        --namespace $NAMESPACE \
        --values ./helm/hello-api/values-$environment.yaml \
        --set image.tag=$image_tag \
        --wait \
        --timeout=5m
    
    # Wait for deployment to be ready
    kubectl wait --for=condition=available deployment/hello-api-$environment -n $NAMESPACE --timeout=300s
    
    log_success "$environment environment deployed and ready!"
}

switch_traffic() {
    local target_environment=$1
    
    log_info "Switching traffic to $target_environment environment..."
    
    # Update the service selector to point to the target environment
    kubectl patch service $SERVICE_NAME -n $NAMESPACE -p "{\"spec\":{\"selector\":{\"version\":\"$target_environment\"}}}"
    
    # Wait a moment for the change to take effect
    sleep 5
    
    # Verify the switch
    local current_selector=$(get_current_traffic)
    if [ "$current_selector" = "$target_environment" ]; then
        log_success "Traffic successfully switched to $target_environment environment!"
    else
        log_error "Failed to switch traffic to $target_environment environment"
        exit 1
    fi
}

verify_deployment() {
    local environment=$1
    
    log_info "Verifying $environment deployment..."
    
    # Check if pods are running
    local pod_count=$(kubectl get pods -n $NAMESPACE -l version=$environment --no-headers | wc -l)
    if [ "$pod_count" -eq 0 ]; then
        log_error "No pods found for $environment environment"
        return 1
    fi
    
    # Check if all pods are ready
    local ready_pods=$(kubectl get pods -n $NAMESPACE -l version=$environment --no-headers | grep "Running" | wc -l)
    if [ "$ready_pods" -ne "$pod_count" ]; then
        log_warning "Not all pods are ready for $environment environment ($ready_pods/$pod_count)"
        return 1
    fi
    
    # Test the application
    local minikube_ip=$(minikube ip -p $CLUSTER_NAME 2>/dev/null || echo "localhost")
    local test_url="http://$minikube_ip:30000"
    
    if curl -f "$test_url/health" >/dev/null 2>&1; then
        log_success "$environment environment is healthy and responding"
    else
        log_warning "$environment environment is not responding to health checks"
        return 1
    fi
}

run_smoke_tests() {
    local environment=$1
    
    log_info "Running smoke tests for $environment environment..."
    
    local minikube_ip=$(minikube ip -p $CLUSTER_NAME 2>/dev/null || echo "localhost")
    local test_url="http://$minikube_ip:30000"
    
    # Test health endpoint
    if ! curl -f "$test_url/health" >/dev/null 2>&1; then
        log_error "Health check failed"
        return 1
    fi
    
    # Test ready endpoint
    if ! curl -f "$test_url/ready" >/dev/null 2>&1; then
        log_error "Readiness check failed"
        return 1
    fi
    
    # Test metrics endpoint
    if ! curl -f "$test_url/metrics" >/dev/null 2>&1; then
        log_error "Metrics endpoint failed"
        return 1
    fi
    
    # Test main endpoint
    if ! curl -f "$test_url/" >/dev/null 2>&1; then
        log_error "Main endpoint failed"
        return 1
    fi
    
    log_success "All smoke tests passed for $environment environment!"
}

show_status() {
    log_info "Current deployment status:"
    echo ""
    
    # Show current traffic
    local current_traffic=$(get_current_traffic)
    echo "Current traffic: $current_traffic"
    echo ""
    
    # Show pod status
    echo "Pod status:"
    kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=hello-api
    echo ""
    
    # Show service status
    echo "Service status:"
    kubectl get services -n $NAMESPACE
    echo ""
    
    # Show ingress status
    echo "Ingress status:"
    kubectl get ingress -n $NAMESPACE
    echo ""
    
    # Show deployment status
    echo "Deployment status:"
    kubectl get deployments -n $NAMESPACE
    echo ""
}

cleanup_old_environment() {
    local environment_to_cleanup=$1
    
    log_info "Cleaning up old $environment_to_cleanup environment..."
    
    # Scale down the old environment
    kubectl scale deployment hello-api-$environment_to_cleanup --replicas=0 -n $NAMESPACE
    
    # Wait for pods to terminate
    kubectl wait --for=delete pod -l version=$environment_to_cleanup -n $NAMESPACE --timeout=60s
    
    log_success "Old $environment_to_cleanup environment cleaned up!"
}

# Main deployment function
deploy_and_switch() {
    local target_environment=$1
    local current_traffic=$(get_current_traffic)
    
    log_info "Starting blue/green deployment to $target_environment..."
    echo "Current traffic: $current_traffic"
    echo "Target environment: $target_environment"
    echo ""
    
    # Deploy the target environment
    deploy_environment $target_environment $target_environment
    
    # Run smoke tests
    if ! run_smoke_tests $target_environment; then
        log_error "Smoke tests failed for $target_environment environment"
        exit 1
    fi
    
    # Switch traffic
    switch_traffic $target_environment
    
    # Verify the deployment
    if ! verify_deployment $target_environment; then
        log_error "Deployment verification failed for $target_environment environment"
        exit 1
    fi
    
    # Clean up old environment (optional)
    if [ "$current_traffic" != "unknown" ] && [ "$current_traffic" != "$target_environment" ]; then
        read -p "Do you want to clean up the old $current_traffic environment? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cleanup_old_environment $current_traffic
        fi
    fi
    
    log_success "Blue/green deployment to $target_environment completed successfully!"
}

# Main execution
main() {
    local action=${1:-""}
    
    case $action in
        blue)
            check_prerequisites
            deploy_and_switch "blue"
            ;;
        green)
            check_prerequisites
            deploy_and_switch "green"
            ;;
        status)
            check_prerequisites
            show_status
            ;;
        *)
            show_usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
