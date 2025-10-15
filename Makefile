# SRE Portfolio Project - Makefile
# This Makefile provides convenient commands for development and deployment

.PHONY: help setup build test lint clean deploy status demo

# Default target
help:
	@echo "SRE Portfolio Project - Available Commands:"
	@echo ""
	@echo "Setup & Development:"
	@echo "  setup          - Run complete project setup"
	@echo "  build          - Build Docker images"
	@echo "  test           - Run tests"
	@echo "  lint           - Run linting"
	@echo "  clean          - Clean up resources"
	@echo ""
	@echo "Deployment:"
	@echo "  deploy-blue    - Deploy to blue environment"
	@echo "  deploy-green   - Deploy to green environment"
	@echo "  switch-blue    - Switch traffic to blue"
	@echo "  switch-green   - Switch traffic to green"
	@echo "  status         - Show deployment status"
	@echo ""
	@echo "Monitoring:"
	@echo "  logs           - Show application logs"
	@echo "  metrics        - Show Prometheus metrics"
	@echo "  grafana        - Open Grafana dashboard"
	@echo ""
	@echo "Demo:"
	@echo "  demo           - Run interactive demo"
	@echo "  load-test      - Run load test"
	@echo ""

# Setup and development
setup:
	@echo "Setting up SRE Portfolio Project..."
	./scripts/setup.sh

build:
	@echo "Building Docker images..."
	docker build -t hello-api:latest ./app
	docker tag hello-api:latest hello-api:blue
	docker tag hello-api:latest hello-api:green
	minikube image load hello-api:blue
	minikube image load hello-api:green

test:
	@echo "Running tests..."
	cd app && python -m pytest tests/ -v

lint:
	@echo "Running linting..."
	cd app && pylint main.py --disable=C0114,C0116
	cd app && black --check .

clean:
	@echo "Cleaning up resources..."
	minikube delete -p sre-portfolio || true
	docker rmi hello-api:latest hello-api:blue hello-api:green || true

# Deployment commands
deploy-blue:
	@echo "Deploying to blue environment..."
	./scripts/deploy-blue-green.sh blue

deploy-green:
	@echo "Deploying to green environment..."
	./scripts/deploy-blue-green.sh green

switch-blue:
	@echo "Switching traffic to blue..."
	./scripts/deploy-blue-green.sh blue

switch-green:
	@echo "Switching traffic to green..."
	./scripts/deploy-blue-green.sh green

status:
	@echo "Deployment status:"
	./scripts/deploy-blue-green.sh status

# Monitoring commands
logs:
	@echo "Showing application logs..."
	kubectl logs -f deployment/hello-api-blue -n hello-api

metrics:
	@echo "Prometheus metrics:"
	@MINIKUBE_IP=$$(minikube ip -p sre-portfolio); \
	curl -s "http://$$MINIKUBE_IP:30000/metrics" | head -20

grafana:
	@echo "Opening Grafana dashboard..."
	@MINIKUBE_IP=$$(minikube ip -p sre-portfolio); \
	echo "Grafana URL: http://$$MINIKUBE_IP:30000"; \
	echo "Username: admin"; \
	echo "Password: admin123"; \
	open "http://$$MINIKUBE_IP:30000" || echo "Please open the URL in your browser"

# Demo commands
demo:
	@echo "Running interactive demo..."
	./scripts/demo.sh

load-test:
	@echo "Running load test..."
	@MINIKUBE_IP=$$(minikube ip -p sre-portfolio); \
	for i in {1..50}; do \
		curl -s "http://$$MINIKUBE_IP:30000/" >/dev/null & \
		curl -s "http://$$MINIKUBE_IP:30000/simulate-latency?delay=0.1" >/dev/null & \
		curl -s "http://$$MINIKUBE_IP:30000/simulate-error?rate=0.05" >/dev/null & \
	done; \
	echo "Load test completed. Check Grafana dashboard for metrics."

# Utility commands
ip:
	@echo "Minikube IP: $$(minikube ip -p sre-portfolio)"

urls:
	@MINIKUBE_IP=$$(minikube ip -p sre-portfolio); \
	echo "Application URLs:"; \
	echo "  Application: http://$$MINIKUBE_IP:30000"; \
	echo "  Health: http://$$MINIKUBE_IP:30000/health"; \
	echo "  Metrics: http://$$MINIKUBE_IP:30000/metrics"; \
	echo "  Grafana: http://$$MINIKUBE_IP:30000 (admin/admin123)"

# Development helpers
dev-setup:
	@echo "Setting up development environment..."
	python -m venv venv
	. venv/bin/activate && pip install -r app/requirements.txt

dev-test:
	@echo "Running development tests..."
	. venv/bin/activate && cd app && python -m pytest tests/ -v

dev-lint:
	@echo "Running development linting..."
	. venv/bin/activate && cd app && pylint main.py --disable=C0114,C0116
	. venv/bin/activate && cd app && black --check .

# Quick start
quick-start: setup build deploy-blue
	@echo "Quick start completed!"
	@make urls
