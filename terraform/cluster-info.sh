#!/bin/bash
# Cluster information script

echo "=== SRE Portfolio Cluster Information ==="
echo "Cluster Name: devops-platform"
echo "Kubernetes Version: v1.28.0"
echo "Driver: docker"
echo "CPUs: 4"
echo "Memory: 6144MB"
echo "Disk Size: 20g"
echo ""

echo "=== Cluster Status ==="
minikube status -p devops-platform
echo ""

echo "=== Node Information ==="
kubectl get nodes -o wide
echo ""

echo "=== Cluster Access ==="
echo "To access the cluster:"
echo "  kubectl config use-context devops-platform"
echo ""
echo "To access minikube dashboard:"
echo "  minikube dashboard -p devops-platform"
echo ""
echo "To get minikube IP:"
echo "  minikube ip -p devops-platform"
echo ""

echo "=== Useful Commands ==="
echo "View all pods: kubectl get pods --all-namespaces"
echo "View services: kubectl get services --all-namespaces"
echo "View ingress: kubectl get ingress --all-namespaces"
echo "View persistent volumes: kubectl get pv"
echo "View storage classes: kubectl get storageclass"
