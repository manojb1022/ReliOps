#!/bin/bash
# SRE Portfolio Project - Setup Script
# This script sets up the complete local development environment

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
MONITORING_NAMESPACE="monitoring"

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

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    local missing_tools=()
    
    # Check for required tools
    command -v minikube >/dev/null 2>&1 || missing_tools+=("minikube")
    command -v kubectl >/dev/null 2>&1 || missing_tools+=("kubectl")
    command -v helm >/dev/null 2>&1 || missing_tools+=("helm")
    command -v docker >/dev/null 2>&1 || missing_tools+=("docker")
    command -v terraform >/dev/null 2>&1 || missing_tools+=("terraform")
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        log_info "Please install the missing tools and try again."
        log_info "Installation instructions:"
        log_info "  minikube: https://minikube.sigs.k8s.io/docs/start/"
        log_info "  kubectl: https://kubernetes.io/docs/tasks/tools/"
        log_info "  helm: https://helm.sh/docs/intro/install/"
        log_info "  docker: https://docs.docker.com/get-docker/"
        log_info "  terraform: https://learn.hashicorp.com/tutorials/terraform/install-cli"
        exit 1
    fi
    
    # Check if Docker is running
    if ! docker info >/dev/null 2>&1; then
        log_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
    
    log_success "All prerequisites are satisfied!"
}

setup_terraform() {
    log_info "Setting up infrastructure with Terraform..."
    
    cd terraform
    
    # Initialize Terraform
    terraform init
    
    # Plan the deployment
    terraform plan
    
    # Apply the configuration
    terraform apply -auto-approve
    
    # Get cluster information
    if [ -f "cluster-info.sh" ]; then
        chmod +x cluster-info.sh
        ./cluster-info.sh
    fi
    
    cd ..
    log_success "Infrastructure setup completed!"
}

deploy_database() {
    log_info "Deploying PostgreSQL database..."
    
    # Add PostgreSQL Helm repo
    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm repo update
    
    # Deploy PostgreSQL
    helm upgrade --install postgres bitnami/postgresql \
        --namespace default \
        --values ./helm/postgres/values.yaml \
        --wait \
        --timeout=10m
    
    # Wait for PostgreSQL to be ready
    kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=postgresql -n default --timeout=300s
    
    log_success "PostgreSQL deployed!"
}

deploy_pgadmin() {
    log_info "Deploying pgAdmin..."
    
    # Add pgAdmin Helm repo
    helm repo add runix https://helm.runix.net
    helm repo update
    
    # Deploy pgAdmin
    helm upgrade --install pgadmin runix/pgadmin4 \
        --namespace monitoring \
        --values ./monitoring/pgadmin/pgadmin-values.yaml \
        --wait \
        --timeout=10m
    
    log_success "pgAdmin deployed!"
}

deploy_logging() {
    log_info "Deploying Loki logging stack..."
    
    # Deploy Loki
    helm upgrade --install loki grafana/loki \
        --namespace $MONITORING_NAMESPACE \
        --values ./monitoring/loki/loki-values.yaml \
        --wait \
        --timeout=10m
    
    # Deploy Promtail
    helm upgrade --install promtail grafana/promtail \
        --namespace $MONITORING_NAMESPACE \
        --values ./monitoring/loki/promtail-values.yaml \
        --wait \
        --timeout=10m
    
    log_success "Loki logging stack deployed!"
}

build_application() {
    log_info "Building application Docker image..."
    
    # Build the Docker image
    docker build -t hello-api:latest ./app
    
    # Tag for minikube
    docker tag hello-api:latest hello-api:blue
    docker tag hello-api:latest hello-api:green
    
    # Load image into minikube
    minikube image load hello-api:blue -p $CLUSTER_NAME
    minikube image load hello-api:green -p $CLUSTER_NAME
    
    log_success "Application built and loaded into minikube!"
}

deploy_monitoring() {
    log_info "Deploying monitoring stack..."
    
    # Add Helm repositories
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo add grafana https://grafana.github.io/helm-charts
    helm repo update
    
    # Deploy Prometheus
    helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
        --namespace $MONITORING_NAMESPACE \
        --create-namespace \
        --values monitoring/prometheus/prometheus-values.yaml \
        --wait \
        --timeout=10m
    
    # Deploy Grafana
    helm upgrade --install grafana grafana/grafana \
        --namespace $MONITORING_NAMESPACE \
        --values monitoring/grafana/grafana-values.yaml \
        --wait \
        --timeout=10m
    
    log_success "Monitoring stack deployed!"
}

deploy_application() {
    log_info "Deploying application..."
    
    # Deploy blue environment
    helm upgrade --install hello-api-blue ./helm/hello-api \
        --namespace $NAMESPACE \
        --create-namespace \
        --values ./helm/hello-api/values-blue.yaml \
        --set image.tag=blue \
        --wait \
        --timeout=5m
    
    # Deploy green environment (for blue/green testing)
    helm upgrade --install hello-api-green ./helm/hello-api \
        --namespace $NAMESPACE \
        --values ./helm/hello-api/values-green.yaml \
        --set image.tag=green \
        --wait \
        --timeout=5m
    
    log_success "Application deployed!"
}

setup_ingress() {
    log_info "Setting up ingress..."
    
    # Install NGINX Ingress Controller
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    helm repo update
    
    helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
        --namespace ingress-nginx \
        --create-namespace \
        --wait \
        --timeout=10m
    
    # Wait for ingress controller to be ready
    kubectl wait --namespace ingress-nginx \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=300s
    
    log_success "Ingress controller installed!"
}

verify_deployment() {
    log_info "Verifying deployment..."
    
    # Check pods
    log_info "Checking pods..."
    kubectl get pods -n $NAMESPACE
    kubectl get pods -n $MONITORING_NAMESPACE
    
    # Check services
    log_info "Checking services..."
    kubectl get services -n $NAMESPACE
    kubectl get services -n $MONITORING_NAMESPACE
    
    # Check ingress
    log_info "Checking ingress..."
    kubectl get ingress -n $NAMESPACE
    
    # Test application endpoints
    log_info "Testing application endpoints..."
    
    # Get minikube IP
    MINIKUBE_IP=$(minikube ip -p $CLUSTER_NAME)
    
    # Test health endpoint
    if curl -f "http://$MINIKUBE_IP:30000/health" >/dev/null 2>&1; then
        log_success "Health endpoint is responding"
    else
        log_warning "Health endpoint is not responding yet"
    fi
    
    log_success "Deployment verification completed!"
}

show_access_info() {
    log_info "Access Information:"
    echo ""
    echo "=== Application Access ==="
    MINIKUBE_IP=$(minikube ip -p $CLUSTER_NAME)
    echo "Application URL: http://$MINIKUBE_IP:30000"
    echo "Health Check: http://$MINIKUBE_IP:30000/health"
    echo "Metrics: http://$MINIKUBE_IP:30000/metrics"
    echo ""
    echo "=== Database API Endpoints ==="
    echo "Request Logs: http://$MINIKUBE_IP:30000/api/requests"
    echo "Statistics: http://$MINIKUBE_IP:30000/api/stats"
    echo "DB Health: http://$MINIKUBE_IP:30000/api/database/health"
    echo ""
    
    echo "=== Monitoring Access ==="
    echo "Grafana: http://$MINIKUBE_IP:30000"
    echo "  Username: admin"
    echo "  Password: $(kubectl get secret --namespace monitoring grafana -o jsonpath='{.data.admin-password}' | base64 --decode)"
    echo ""
    echo "Prometheus: http://$MINIKUBE_IP:30000"
    echo ""
    
    echo "=== Database Admin ==="
    echo "pgAdmin: http://$MINIKUBE_IP:30100"
    echo "  Username: admin@reliops.com"
    echo "  Password: admin123"
    echo ""
    echo "PostgreSQL Connection:"
    echo "  Host: postgres-postgresql.default.svc.cluster.local"
    echo "  Port: 5432"
    echo "  Database: reliops_db"
    echo "  Username: reliops"
    echo "  Password: reliops123"
    echo ""
    
    echo "=== Useful Commands ==="
    echo "View all pods: kubectl get pods --all-namespaces"
    echo "View services: kubectl get services --all-namespaces"
    echo "View logs: kubectl logs -f deployment/hello-api-blue -n $NAMESPACE"
    echo "Port forward: kubectl port-forward svc/hello-api-blue 8080:80 -n $NAMESPACE"
    echo "Minikube dashboard: minikube dashboard -p $CLUSTER_NAME"
    echo ""
    
    echo "=== Blue/Green Deployment ==="
    echo "Switch to green: ./scripts/deploy-blue-green.sh green"
    echo "Switch to blue: ./scripts/deploy-blue-green.sh blue"
    echo "Run demo: ./scripts/demo.sh"
    echo ""
}

cleanup() {
    log_info "Cleaning up on exit..."
    # Add any cleanup logic here if needed
}

# Main execution
main() {
    log_info "Starting SRE Portfolio Project setup..."
    echo ""
    
    # Set up cleanup trap
    trap cleanup EXIT
    
    # Run setup steps
    check_prerequisites
    setup_terraform
    deploy_database
    build_application
    deploy_monitoring
    deploy_pgadmin
    deploy_logging
    deploy_application
    verify_deployment
    show_access_info
    
    log_success "Setup completed successfully!"
    log_info "You can now access the application and monitoring dashboards."
    log_info "Run './scripts/demo.sh' to see a demonstration of the system."
}

# Run main function
main "$@"
