# Terraform outputs for minikube cluster

output "cluster_name" {
  description = "Name of the created minikube cluster"
  value       = var.cluster_name
}

output "cluster_status" {
  description = "Status of the minikube cluster"
  value       = "Use 'minikube status -p ${var.cluster_name}' to check status"
}

output "kubectl_context" {
  description = "Kubectl context to use for accessing the cluster"
  value       = var.cluster_name
}

output "cluster_ip" {
  description = "IP address of the minikube cluster"
  value       = "Use 'minikube ip -p ${var.cluster_name}' to get IP"
}

output "dashboard_url" {
  description = "URL to access the minikube dashboard"
  value       = "Use 'minikube dashboard -p ${var.cluster_name}' to open dashboard"
}

output "cluster_info_script" {
  description = "Path to the cluster information script"
  value       = "${path.module}/cluster-info.sh"
}

output "namespaces" {
  description = "Created namespaces"
  value = {
    monitoring = "monitoring"
    application = "portfolio"
  }
}

output "helm_repos" {
  description = "Added Helm repositories"
  value = {
    prometheus = "prometheus-community"
    grafana = "grafana"
    ingress_nginx = "ingress-nginx"
  }
}
