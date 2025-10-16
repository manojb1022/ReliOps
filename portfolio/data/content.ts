// Real portfolio content for B Manoj - DevOps Engineer

export const personalInfo = {
  name: "B Manoj",
  title: "DevOps Engineer & Site Reliability Engineer",
  tagline: "Designing and automating cloud-native infrastructure using AWS, Kubernetes, and Terraform. Driving operational efficiency through automation and reliability engineering.",
  email: "manojb1022@gmail.com",
  phone: "+91 8431799806",
  location: "Bengaluru, India",
  github: "https://github.com/manojb",
  linkedin: "https://linkedin.com/in/manojb22",
  yearsExperience: "4",
  downtimeReduction: "90%",
  workloadReduction: "80%",
  ticketsResolved: "130+",
  migratedApps: "100+",
}

export const summary = "Experienced DevOps Engineer with 4 years in designing and automating cloud-native infrastructure using AWS, Kubernetes, and Terraform. Skilled in CI/CD pipeline development, container orchestration, and system monitoring with Prometheus and Grafana. Adept at cross-functional collaboration and driving operational efficiency through automation and reliability engineering."

export const experiences = [
  {
    title: "Software Engineer 1",
    company: "PowerSchool India Pvt Ltd",
    period: "April 2024 - Present",
    location: "Bengaluru, India",
    achievements: [
      "Developed automated deployment procedures using Argo Workflows with Bash scripting, enhancing operational efficiency and consistency",
      "Designed UI and backend using Next.js and TypeScript for platform features, improving user experience and system functionality",
      "Automated AWS RDS backups to S3, reducing downtime by 90% in critical scenarios and improving disaster recovery",
      "Designed and deployed scalable AWS EFS for multi-tenant system with automated provisioning/decommissioning in Kubernetes, reducing manual workload by 80%",
      "Orchestrated AWS EKS clusters using Terraform, ensuring scalable and robust infrastructure for production environments",
      "Led and executed stable production releases, ensuring minimal downtime and high system reliability"
    ],
    technologies: ["AWS", "Kubernetes", "Terraform", "Argo Workflows", "Next.js", "TypeScript", "EFS", "EKS", "RDS", "S3", "Bash"]
  },
  {
    title: "Associate Software Engineer II",
    company: "PowerSchool India Pvt Ltd",
    period: "April 2023 - March 2024",
    location: "Bengaluru, India",
    achievements: [
      "Optimized deployments by refining Helm configurations, managing dynamic secrets, and resolving scaling issues in StatefulSets",
      "Led and executed seamless migration from Azure to AWS for 100+ applications, ensuring smooth transition and project success",
      "Enhanced Kubernetes configurations to optimize system performance and scalability, improving operational efficiency",
      "Developed and improved both the user interface and the backend components, improving the efficiency of internal tools"
    ],
    technologies: ["Kubernetes", "Helm", "AWS", "Azure", "StatefulSets", "CI/CD"]
  },
  {
    title: "Associate Software Engineer I",
    company: "PowerSchool India Pvt Ltd",
    period: "October 2021 - March 2023",
    location: "Bengaluru, India",
    achievements: [
      "Developed reusable components, reducing development efforts and improving code maintainability",
      "Resolved 130+ JIRA tickets, significantly reducing backlog and ensuring smooth project progression",
      "Collaborated with QA and Product teams throughout Agile life-cycle, ensuring high-quality and timely project delivery",
      "Mentored and onboarded new developer teams, facilitating integration and productivity in ongoing projects"
    ],
    technologies: ["JavaScript", "JIRA", "Git", "Agile", "Development"]
  }
]

export const skills = {
  "Cloud & Infrastructure": ["AWS (EKS, EFS, RDS, S3, EC2)", "Kubernetes", "Docker", "Terraform"],
  "CI/CD & Automation": ["Argo Workflows", "GitHub Actions", "Jenkins", "Bash scripting", "Python"],
  "Monitoring & Tools": ["Prometheus", "Grafana", "JIRA", "Git"],
  "Development": ["JavaScript", "TypeScript", "Next.js", "SQL", "Helm"],
}

export const projects = [
  {
    id: "reliops",
    title: "ReliOps - Production SRE Platform",
    description: "End-to-end Site Reliability Engineering platform with Kubernetes, Terraform, monitoring, and blue/green deployments.",
    longDescription: "Complete DevOps platform demonstrating infrastructure automation, container orchestration, CI/CD pipelines, monitoring with Prometheus/Grafana, centralized logging with Loki, and blue/green deployment strategies.",
    tags: ["Kubernetes", "Terraform", "Docker", "Prometheus", "Grafana", "GitHub Actions", "PostgreSQL", "Helm", "Loki"],
    github: "https://github.com/manojb/reliops",
    liveUrl: null,
    featured: true,
    metrics: [
      "99.9% uptime SLA",
      "Zero-downtime deployments",
      "Auto-healing capabilities",
      "Centralized logging",
      "Infrastructure as Code"
    ]
  },
  {
    id: "aws-efs-automation",
    title: "AWS EFS Multi-Tenant Automation",
    description: "Scalable AWS EFS solution with automated provisioning/decommissioning for multi-tenant Kubernetes environments.",
    longDescription: "Designed and deployed automated EFS provisioning system that reduced manual workload by 80%, enabling seamless tenant onboarding and decommissioning in Kubernetes clusters.",
    tags: ["AWS", "EFS", "Kubernetes", "Terraform", "Bash", "Automation"],
    github: null,
    liveUrl: null,
    featured: true,
    metrics: [
      "80% manual workload reduction",
      "Automated provisioning",
      "Multi-tenant support",
      "Terraform orchestration"
    ]
  },
  {
    id: "rds-backup-automation",
    title: "AWS RDS Automated Backup System",
    description: "Automated RDS backup solution to S3 reducing downtime by 90% and improving disaster recovery capabilities.",
    longDescription: "Implemented automated backup system for AWS RDS databases with S3 integration, significantly improving disaster recovery and reducing downtime in critical scenarios.",
    tags: ["AWS", "RDS", "S3", "Bash", "Automation", "Disaster Recovery"],
    github: null,
    liveUrl: null,
    featured: true,
    metrics: [
      "90% downtime reduction",
      "Automated backups",
      "S3 integration",
      "Disaster recovery"
    ]
  },
  {
    id: "azure-aws-migration",
    title: "Azure to AWS Migration",
    description: "Led seamless migration of 100+ applications from Azure to AWS ensuring zero disruption.",
    longDescription: "Orchestrated and executed large-scale cloud migration project moving 100+ applications from Azure to AWS. Ensured smooth transition with minimal downtime and maintained application performance.",
    tags: ["AWS", "Azure", "Kubernetes", "Terraform", "Migration", "Cloud"],
    github: null,
    liveUrl: null,
    featured: false,
    metrics: [
      "100+ apps migrated",
      "Zero disruption",
      "Seamless transition",
      "Multi-cloud expertise"
    ]
  },
  {
    id: "argo-workflows",
    title: "Argo Workflows Automation",
    description: "Developed automated deployment procedures using Argo Workflows enhancing operational efficiency.",
    longDescription: "Built comprehensive CI/CD automation using Argo Workflows with Bash scripting, improving deployment consistency and reducing manual intervention across production environments.",
    tags: ["Argo Workflows", "Kubernetes", "Bash", "CI/CD", "Automation"],
    github: null,
    liveUrl: null,
    featured: false,
    metrics: [
      "Enhanced efficiency",
      "Consistent deployments",
      "Reduced manual work",
      "Production-grade"
    ]
  },
  {
    id: "eks-terraform",
    title: "EKS Infrastructure with Terraform",
    description: "Orchestrated AWS EKS clusters using Terraform ensuring scalable and robust production infrastructure.",
    longDescription: "Designed and implemented Infrastructure as Code for AWS EKS clusters using Terraform, enabling version-controlled, repeatable, and scalable Kubernetes infrastructure.",
    tags: ["AWS", "EKS", "Terraform", "Kubernetes", "IaC"],
    github: null,
    liveUrl: null,
    featured: false,
    metrics: [
      "Scalable infrastructure",
      "Version controlled",
      "Production-ready",
      "Infrastructure as Code"
    ]
  }
]

export const achievements = [
  {
    title: "VP and Senior Director Recognition",
    description: "Recognized for achieving the highest number of bug resolutions with 130+ tickets",
    icon: "trophy"
  },
  {
    title: "Power Team Award",
    description: "Awarded for best overall team performance",
    icon: "award"
  },
  {
    title: "Cloud Migration Leader",
    description: "Successfully led migration of 100+ applications from Azure to AWS",
    icon: "cloud"
  },
  {
    title: "Automation Champion",
    description: "Reduced manual workload by 80% through infrastructure automation",
    icon: "zap"
  }
]

export const education = {
  degree: "Master of Computer Science (MCA)",
  institution: "Kristu Jayanti College, Autonomous",
  period: "August 2019 - August 2021",
  location: "Bengaluru, India"
}

export const interests = [
  "Runner-up in inter-collegiate IT fest, showcasing problem-solving and technical skills",
  "Led and coordinated college fests SHELLS and MANOEUVRE, demonstrating leadership and event planning"
]
