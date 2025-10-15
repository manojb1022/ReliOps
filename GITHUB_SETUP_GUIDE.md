# GitHub Setup Guide

## 📋 Pre-Push Checklist

Before pushing to GitHub, follow these steps:

---

## 🔧 Step 1: Create GitHub Repository

### Option A: Via GitHub Website (Recommended)

1. **Go to GitHub**: https://github.com
2. **Click** the `+` icon (top right) → **New repository**
3. **Repository settings**:
   ```
   Repository name: ReliOps
   Description: Production-grade DevOps platform with Kubernetes, Docker, Terraform, and monitoring
   Visibility: ✅ Public (for portfolio showcase)
   
   ❌ DO NOT initialize with:
      - README (we already have one)
      - .gitignore (we already have one)
      - License (we already have one)
   ```
4. **Click** "Create repository"

5. **Copy the repository URL**:
   ```
   https://github.com/YOUR_USERNAME/ReliOps.git
   ```

### Option B: Via GitHub CLI

```bash
# Install GitHub CLI if not installed
brew install gh

# Authenticate
gh auth login

# Create repo
gh repo create ReliOps --public --source=. --remote=origin
```

---

## 🔐 Step 2: Configure Git (If Not Already Done)

```bash
# Set your name and email
git config --global user.name "B Manoj"
git config --global user.email "manojb1022@gmail.com"

# Verify configuration
git config --list
```

---

## 📦 Step 3: Initialize and Push to GitHub

### Initialize Git (if not already done)
```bash
cd /Users/b.manoj/ReliOps
git init
```

### Add all files
```bash
git add .
```

### Check what will be committed
```bash
git status
```

**You should see:**
- ✅ All project files in green
- ❌ No sensitive files (credentials, secrets)
- ❌ No `node_modules/` (should be in .gitignore)
- ❌ No `.terraform/` (should be in .gitignore)

### Create first commit
```bash
git commit -m "Initial commit: Complete DevOps platform with Next.js portfolio

Features:
- Infrastructure as Code (Terraform)
- Kubernetes deployment with Helm
- Next.js portfolio application
- Docker containerization
- Prometheus & Grafana monitoring
- Auto-scaling (HPA)
- CI/CD pipeline (GitHub Actions)
- Health checks & observability
- Complete documentation"
```

### Add remote origin
```bash
# Replace YOUR_USERNAME with your actual GitHub username
git remote add origin https://github.com/YOUR_USERNAME/ReliOps.git
```

### Verify remote
```bash
git remote -v
```

### Create main branch and push
```bash
# Rename master to main (modern convention)
git branch -M main

# Push to GitHub
git push -u origin main
```

---

## 🔒 Step 4: Configure Repository Settings (Important!)

### Go to your repo settings on GitHub:
`https://github.com/YOUR_USERNAME/ReliOps/settings`

### 1. General Settings
- ✅ Enable **Issues** (for tracking)
- ✅ Enable **Projects** (optional)
- ✅ Enable **Wiki** (optional)

### 2. Add Topics (helps with discoverability)
Click "Add topics" and add:
```
devops, kubernetes, docker, terraform, helm, prometheus, 
grafana, nextjs, portfolio, sre, infrastructure-as-code, 
ci-cd, monitoring, observability, cloud-native
```

### 3. Update Repository Details
Add:
- **Description**: Production-grade DevOps platform showcasing Kubernetes, Docker, Terraform, monitoring, and SRE practices
- **Website**: (Your portfolio URL if deployed)

### 4. Setup Branch Protection (Optional but Professional)
Go to: Settings → Branches → Add rule

For `main` branch:
- ✅ Require pull request reviews before merging
- ✅ Require status checks to pass before merging
- ✅ Require branches to be up to date before merging

---

## 🚀 Step 5: Enable GitHub Actions (CI/CD)

GitHub Actions should work automatically once you push, but verify:

1. Go to **Actions** tab in your repo
2. You should see workflows from `.github/workflows/`
3. The pipeline will trigger on next push

---

## 📝 Step 6: Create Additional Documentation Files

### Create CONTRIBUTING.md (optional but professional)
```bash
cat > CONTRIBUTING.md << 'EOF'
# Contributing to ReliOps

Thank you for your interest in contributing!

## Development Setup

1. Clone the repository
2. Install prerequisites (Docker, minikube, kubectl, Helm, Terraform)
3. Follow the MANUAL_DEPLOYMENT_GUIDE.md

## Pull Request Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Code Style

- Use meaningful commit messages
- Follow existing code structure
- Update documentation for significant changes
- Test changes locally before pushing
EOF
```

---

## 🏷️ Step 7: Create GitHub Release (Optional)

After first successful push:

```bash
# Create a tag
git tag -a v1.0.0 -m "Initial release: Complete DevOps platform"

# Push the tag
git push origin v1.0.0
```

Then on GitHub:
1. Go to **Releases** → **Create a new release**
2. Choose tag `v1.0.0`
3. Release title: `v1.0.0 - Initial Release`
4. Description:
```markdown
## 🎉 Initial Release

Complete production-grade DevOps platform featuring:

### Infrastructure
- ✅ Terraform for cluster provisioning
- ✅ Kubernetes with Helm charts
- ✅ Docker multi-stage builds

### Application
- ✅ Next.js 15 portfolio
- ✅ TypeScript & TailwindCSS
- ✅ Responsive design

### Observability
- ✅ Prometheus metrics
- ✅ Grafana dashboards
- ✅ Health checks

### Automation
- ✅ CI/CD with GitHub Actions
- ✅ Auto-scaling (HPA)
- ✅ Automated deployment scripts

### Documentation
- ✅ Complete setup guides
- ✅ Manual deployment steps
- ✅ Architecture diagrams
```

---

## 📊 Step 8: Add README Badges (Optional)

Add at the top of README.md:

```markdown
![Build Status](https://github.com/YOUR_USERNAME/ReliOps/workflows/Portfolio%20App%20CI%2FCD%20Pipeline/badge.svg)
![GitHub last commit](https://img.shields.io/github/last-commit/YOUR_USERNAME/ReliOps)
![GitHub repo size](https://img.shields.io/github/repo-size/YOUR_USERNAME/ReliOps)
![GitHub stars](https://img.shields.io/github/stars/YOUR_USERNAME/ReliOps?style=social)
```

---

## 🔍 Step 9: Verify Everything Works

After pushing:

1. **Check Repository**: All files visible on GitHub
2. **Check Actions Tab**: CI/CD pipeline should appear
3. **Check README**: Should render properly with formatting
4. **Check Documentation**: All .md files should be readable

---

## ⚠️ Important: What NOT to Commit

These are already in `.gitignore`, but double-check:

```bash
# Check .gitignore includes:
cat .gitignore | grep -E "node_modules|.terraform|.env|*.tfstate|*.tfvars"
```

**Never commit:**
- ❌ `node_modules/`
- ❌ `.terraform/`
- ❌ `terraform.tfstate` (contains state, could have sensitive data)
- ❌ `.env` files
- ❌ Secrets or API keys
- ❌ Personal credentials

---

## 🎯 Final Checklist Before Push

```bash
# Run this checklist:

# 1. Check for sensitive data
grep -r "password\|secret\|api_key" . --exclude-dir={node_modules,.git,.terraform}

# 2. Verify .gitignore is working
git status --ignored

# 3. Check file sizes (GitHub has 100MB limit per file)
find . -type f -size +50M

# 4. Lint check (if applicable)
cd portfolio && npm run lint

# 5. Review commit
git log --oneline -1
git show HEAD --stat
```

---

## 🚀 Complete Push Sequence

```bash
# Navigate to project
cd /Users/b.manoj/ReliOps

# Check current status
git status

# Stage all files
git add .

# Create commit
git commit -m "Initial commit: Complete DevOps platform"

# Add remote (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/ReliOps.git

# Push to GitHub
git branch -M main
git push -u origin main

# Success message
echo "✅ Successfully pushed to GitHub!"
echo "🌐 View at: https://github.com/YOUR_USERNAME/ReliOps"
```

---

## 🎓 For Interviews - GitHub Highlights

When showing your GitHub repo in interviews:

1. **Professional README**: Well-structured with badges and diagrams
2. **Complete Documentation**: Multiple guides for different users
3. **CI/CD Pipeline**: Visible GitHub Actions workflows
4. **Commit History**: Clean, meaningful commit messages
5. **Topics/Tags**: Proper categorization
6. **File Structure**: Clean, organized, professional
7. **Active Maintenance**: Recent commits show it's maintained

---

## 📞 Need Help?

If you encounter issues:

```bash
# Check Git status
git status

# Check remote
git remote -v

# Check branch
git branch

# Reset if needed (CAUTION)
git reset --soft HEAD^  # Undo last commit but keep changes
```

---

## ✅ Success Indicators

After pushing, you should:
- ✅ See your code on GitHub
- ✅ README displays properly with formatting
- ✅ Actions tab shows your CI/CD workflow
- ✅ All documentation is readable
- ✅ Repository has description and topics
- ✅ No sensitive data visible

**You're now ready to share your portfolio with recruiters!** 🎉

