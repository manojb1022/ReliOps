# Architecture Diagram

## System Overview

```mermaid
graph TB
    subgraph "Developer Environment"
        DEV[Developer]
        GIT[Git Repository]
        GH[GitHub Actions]
    end
    
    subgraph "Infrastructure Layer"
        TF[Terraform]
        MK[minikube Cluster]
        K8S[Kubernetes]
    end
    
    subgraph "Application Layer"
        APP[Hello API Microservice]
        BLUE[Blue Environment]
        GREEN[Green Environment]
    end
    
    subgraph "Observability Layer"
        PROM[Prometheus]
        GRAF[Grafana]
        ALERT[Alert Manager]
    end
    
    subgraph "Deployment Layer"
        HELM[Helm Charts]
        INGRESS[NGINX Ingress]
        LB[Load Balancer]
    end
    
    DEV --> GIT
    GIT --> GH
    GH --> TF
    TF --> MK
    MK --> K8S
    K8S --> HELM
    HELM --> BLUE
    HELM --> GREEN
    BLUE --> APP
    GREEN --> APP
    APP --> PROM
    PROM --> GRAF
    PROM --> ALERT
    INGRESS --> LB
    LB --> BLUE
    LB --> GREEN
```

## Data Flow Diagram

```mermaid
sequenceDiagram
    participant U as User
    participant I as Ingress
    participant L as Load Balancer
    participant A as Application
    participant P as Prometheus
    participant G as Grafana
    
    U->>I: HTTP Request
    I->>L: Route Request
    L->>A: Forward Request
    A->>A: Process Request
    A->>A: Update Metrics
    A->>P: Expose Metrics
    P->>G: Scrape Metrics
    A->>L: HTTP Response
    L->>I: Forward Response
    I->>U: HTTP Response
    G->>U: Dashboard View
```

## Component Architecture

```mermaid
graph LR
    subgraph "Kubernetes Cluster"
        subgraph "hello-api Namespace"
            APP1[hello-api-blue Pod]
            APP2[hello-api-green Pod]
            SVC[hello-api Service]
            HPA[HorizontalPodAutoscaler]
        end
        
        subgraph "monitoring Namespace"
            PROM[Prometheus Server]
            GRAF[Grafana]
            AM[Alert Manager]
            SM[Service Monitor]
        end
        
        subgraph "ingress-nginx Namespace"
            IC[Ingress Controller]
        end
    end
    
    subgraph "External"
        USER[Users]
        GH[GitHub Actions]
    end
    
    USER --> IC
    IC --> SVC
    SVC --> APP1
    SVC --> APP2
    SM --> APP1
    SM --> APP2
    SM --> PROM
    PROM --> GRAF
    PROM --> AM
    GH --> APP1
    GH --> APP2
    HPA --> APP1
    HPA --> APP2
```

## Deployment Pipeline

```mermaid
graph TD
    A[Code Push] --> B[GitHub Actions]
    B --> C[Lint & Test]
    C --> D[Security Scan]
    D --> E[Build Docker Image]
    E --> F[Push to Registry]
    F --> G[Deploy to K8s]
    G --> H[Smoke Tests]
    H --> I[Blue/Green Switch]
    I --> J[Monitor & Alert]
    
    C -->|Fail| K[Report Failure]
    D -->|Fail| K
    H -->|Fail| L[Rollback]
    J -->|Alert| M[Incident Response]
```

## Monitoring Stack

```mermaid
graph TB
    subgraph "Application Metrics"
        APP[Hello API]
        METRICS[Custom Metrics]
    end
    
    subgraph "Infrastructure Metrics"
        NODE[Node Metrics]
        K8S[K8s Metrics]
    end
    
    subgraph "Prometheus Stack"
        PROM[Prometheus Server]
        AM[Alert Manager]
        SM[Service Monitor]
    end
    
    subgraph "Visualization"
        GRAF[Grafana]
        DASH[Dashboards]
        ALERT[Alert Rules]
    end
    
    APP --> METRICS
    METRICS --> SM
    NODE --> PROM
    K8S --> PROM
    SM --> PROM
    PROM --> AM
    PROM --> GRAF
    GRAF --> DASH
    AM --> ALERT
```

## Security Architecture

```mermaid
graph TB
    subgraph "Container Security"
        NS[Non-root User]
        RO[Read-only FS]
        SC[Security Context]
        RL[Resource Limits]
    end
    
    subgraph "Network Security"
        NP[Network Policies]
        TLS[TLS Termination]
        FW[Firewall Rules]
    end
    
    subgraph "Image Security"
        VS[Vulnerability Scan]
        SB[Base Image Security]
        SIG[Image Signing]
    end
    
    subgraph "Runtime Security"
        PS[Pod Security]
        RBAC[RBAC]
        SA[Service Accounts]
    end
    
    VS --> NS
    NS --> RO
    RO --> SC
    SC --> RL
    NP --> TLS
    TLS --> FW
    PS --> RBAC
    RBAC --> SA
```

## High Availability Design

```mermaid
graph TB
    subgraph "Load Balancing"
        LB[Load Balancer]
        H1[Host 1]
        H2[Host 2]
        H3[Host 3]
    end
    
    subgraph "Application Tier"
        A1[App Instance 1]
        A2[App Instance 2]
        A3[App Instance 3]
    end
    
    subgraph "Data Tier"
        D1[Database 1]
        D2[Database 2]
        D3[Database 3]
    end
    
    LB --> H1
    LB --> H2
    LB --> H3
    H1 --> A1
    H2 --> A2
    H3 --> A3
    A1 --> D1
    A2 --> D2
    A3 --> D3
    D1 --> D2
    D2 --> D3
    D3 --> D1
```

## Disaster Recovery

```mermaid
graph LR
    subgraph "Primary Region"
        P1[Primary Cluster]
        P2[Primary Storage]
        P3[Primary Monitoring]
    end
    
    subgraph "Secondary Region"
        S1[Secondary Cluster]
        S2[Secondary Storage]
        S3[Secondary Monitoring]
    end
    
    subgraph "Backup"
        B1[Data Backup]
        B2[Config Backup]
        B3[Image Backup]
    end
    
    P1 --> S1
    P2 --> S2
    P3 --> S3
    P1 --> B1
    P2 --> B2
    P3 --> B3
    S1 --> B1
    S2 --> B2
    S3 --> B3
```

## Key Design Principles

### 1. **Separation of Concerns**
- Clear separation between infrastructure, application, and monitoring layers
- Modular design with well-defined interfaces

### 2. **High Availability**
- Multi-replica deployments
- Auto-scaling and auto-healing
- Load balancing and failover

### 3. **Observability**
- Comprehensive metrics collection
- Centralized logging and monitoring
- Proactive alerting and incident response

### 4. **Security**
- Defense in depth
- Least privilege access
- Regular security scanning and updates

### 5. **Automation**
- Infrastructure as Code
- Automated testing and deployment
- Self-healing and self-scaling systems

### 6. **Reliability**
- Blue/green deployments
- Circuit breakers and retries
- Graceful degradation

This architecture demonstrates enterprise-grade SRE practices while remaining simple enough to understand and demonstrate in an interview setting.
