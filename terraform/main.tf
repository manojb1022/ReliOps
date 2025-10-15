# Terraform configuration for local minikube cluster setup
# This automates the creation and configuration of a local Kubernetes cluster

terraform {
  required_version = ">= 1.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

# Variables
variable "cluster_name" {
  description = "Name of the minikube cluster"
  type        = string
  default     = "devops-platform"
}

variable "kubernetes_version" {
  description = "Kubernetes version to use"
  type        = string
  default     = "v1.28.0"
}

variable "cpus" {
  description = "Number of CPUs to allocate to minikube"
  type        = number
  default     = 4
}

variable "memory" {
  description = "Amount of memory to allocate to minikube (in MB)"
  type        = number
  default     = 6144
}

variable "disk_size" {
  description = "Disk size for minikube (e.g., '20g')"
  type        = string
  default     = "20g"
}

variable "driver" {
  description = "Minikube driver to use"
  type        = string
  default     = "docker"
}

# Check if required tools are installed
resource "null_resource" "check_prerequisites" {
  provisioner "local-exec" {
    command = <<-EOT
      # Check if minikube is installed
      if ! command -v minikube &> /dev/null; then
        echo "Error: minikube is not installed. Please install minikube first."
        echo "Visit: https://minikube.sigs.k8s.io/docs/start/"
        exit 1
      fi
      
      # Check if kubectl is installed
      if ! command -v kubectl &> /dev/null; then
        echo "Error: kubectl is not installed. Please install kubectl first."
        echo "Visit: https://kubernetes.io/docs/tasks/tools/"
        exit 1
      fi
      
      # Check if helm is installed
      if ! command -v helm &> /dev/null; then
        echo "Error: helm is not installed. Please install helm first."
        echo "Visit: https://helm.sh/docs/intro/install/"
        exit 1
      fi
      
      # Check if docker is running (if using docker driver)
      if [ "${var.driver}" = "docker" ]; then
        if ! docker info &> /dev/null; then
          echo "Error: Docker is not running. Please start Docker first."
          exit 1
        fi
      fi
      
      echo "All prerequisites are satisfied!"
    EOT
  }
}

# Start minikube cluster
resource "null_resource" "start_minikube" {
  depends_on = [null_resource.check_prerequisites]
  
  # Store cluster name as a trigger to make it available during destroy
  triggers = {
    cluster_name = var.cluster_name
  }
  
  provisioner "local-exec" {
    command = <<-EOT
      # Check if cluster already exists
      if minikube status -p ${var.cluster_name} &> /dev/null; then
        echo "Cluster ${var.cluster_name} already exists. Starting it..."
        minikube start -p ${var.cluster_name}
      else
        echo "Creating new cluster ${var.cluster_name}..."
        minikube start \
          -p ${var.cluster_name} \
          --kubernetes-version=${var.kubernetes_version} \
          --cpus=${var.cpus} \
          --memory=${var.memory} \
          --disk-size=${var.disk_size} \
          --driver=${var.driver} \
          --addons=ingress,metrics-server,storage-provisioner \
          --extra-config=apiserver.enable-admission-plugins=DefaultStorageClass
      fi
    EOT
  }
  
  provisioner "local-exec" {
    when = destroy
    command = <<-EOT
      echo "Stopping minikube cluster ${self.triggers.cluster_name}..."
      minikube stop -p ${self.triggers.cluster_name} || true
    EOT
  }
}

# Configure kubectl context
resource "null_resource" "configure_kubectl" {
  depends_on = [null_resource.start_minikube]
  
  provisioner "local-exec" {
    command = <<-EOT
      minikube update-context -p ${var.cluster_name}
      kubectl config use-context ${var.cluster_name}
    EOT
  }
}

# Wait for cluster to be ready
resource "null_resource" "wait_for_cluster" {
  depends_on = [null_resource.configure_kubectl]
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting for cluster to be ready..."
      kubectl wait --for=condition=Ready nodes --all --timeout=300s
      kubectl wait --for=condition=Ready pods --all --all-namespaces --timeout=300s
      echo "Cluster is ready!"
    EOT
  }
}

# Install Helm repositories
resource "null_resource" "setup_helm_repos" {
  depends_on = [null_resource.wait_for_cluster]
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "Setting up Helm repositories..."
      helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
      helm repo add grafana https://grafana.github.io/helm-charts
      helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
      helm repo update
    EOT
  }
}

# Create monitoring namespace
resource "null_resource" "create_monitoring_namespace" {
  depends_on = [null_resource.setup_helm_repos]
  
  provisioner "local-exec" {
    command = <<-EOT
      kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
    EOT
  }
}

# Create application namespace
resource "null_resource" "create_app_namespace" {
  depends_on = [null_resource.setup_helm_repos]
  
  provisioner "local-exec" {
    command = <<-EOT
      kubectl create namespace portfolio --dry-run=client -o yaml | kubectl apply -f -
    EOT
  }
}

# Generate cluster info script
resource "local_file" "cluster_info" {
  depends_on = [null_resource.wait_for_cluster]
  
  filename = "${path.module}/cluster-info.sh"
  content = <<-EOT
#!/bin/bash
# Cluster information script

echo "=== SRE Portfolio Cluster Information ==="
echo "Cluster Name: ${var.cluster_name}"
echo "Kubernetes Version: ${var.kubernetes_version}"
echo "Driver: ${var.driver}"
echo "CPUs: ${var.cpus}"
echo "Memory: ${var.memory}MB"
echo "Disk Size: ${var.disk_size}"
echo ""

echo "=== Cluster Status ==="
minikube status -p ${var.cluster_name}
echo ""

echo "=== Node Information ==="
kubectl get nodes -o wide
echo ""

echo "=== Cluster Access ==="
echo "To access the cluster:"
echo "  kubectl config use-context ${var.cluster_name}"
echo ""
echo "To access minikube dashboard:"
echo "  minikube dashboard -p ${var.cluster_name}"
echo ""
echo "To get minikube IP:"
echo "  minikube ip -p ${var.cluster_name}"
echo ""

echo "=== Useful Commands ==="
echo "View all pods: kubectl get pods --all-namespaces"
echo "View services: kubectl get services --all-namespaces"
echo "View ingress: kubectl get ingress --all-namespaces"
echo "View persistent volumes: kubectl get pv"
echo "View storage classes: kubectl get storageclass"
EOT
}

# Make cluster info script executable
resource "null_resource" "make_cluster_info_executable" {
  depends_on = [local_file.cluster_info]
  
  provisioner "local-exec" {
    command = "chmod +x ${path.module}/cluster-info.sh"
  }
}
