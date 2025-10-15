# Git Branching Strategy & CI/CD Workflow

## 🌳 Branch Structure

```
main (protected)
  ↑
  └── Pull Requests from development
        ↑
        └── development (default working branch)
              ↑
              └── feature branches (optional)
```

---

## 📋 Branch Descriptions

### `main` Branch (Protected)
- **Purpose**: Production-ready code only
- **Protection**: Requires pull request reviews
- **CI/CD**: Runs full pipeline on PR merge
- **Direct commits**: ❌ Blocked
- **Status**: Stable, deployable at any time

### `development` Branch (Default)
- **Purpose**: Active development and testing
- **CI/CD**: Runs on every push
- **Direct commits**: ✅ Allowed
- **Merge to**: `main` via Pull Request
- **Status**: Integration testing branch

### `feature/*` Branches (Optional)
- **Purpose**: Individual features or experiments
- **Created from**: `development`
- **Merge to**: `development` via PR
- **Naming**: `feature/add-logging`, `feature/update-helm-chart`

---

## 🔄 Workflow

### Daily Development Workflow

```bash
# 1. Switch to development branch
git checkout development

# 2. Pull latest changes
git pull origin development

# 3. Make your changes
# ... edit files ...

# 4. Stage and commit
git add .
git commit -m "feat: add new feature"

# 5. Push to development (triggers CI/CD)
git push origin development
```

### Creating a Pull Request to Main

```bash
# 1. Ensure development is up to date
git checkout development
git pull origin development

# 2. Push to development
git push origin development

# 3. Go to GitHub and create Pull Request
#    From: development → To: main
#    
#    Title: "Release v1.1.0 - New features"
#    Description:
#      - Added feature X
#      - Fixed bug Y
#      - Updated documentation

# 4. Wait for CI/CD checks to pass
# 5. Request review (if team members exist)
# 6. Merge when approved
```

### Feature Branch Workflow (Optional)

```bash
# 1. Create feature branch from development
git checkout development
git pull origin development
git checkout -b feature/add-monitoring-alerts

# 2. Work on your feature
# ... make changes ...

# 3. Commit and push
git add .
git commit -m "feat: add Prometheus alerting rules"
git push origin feature/add-monitoring-alerts

# 4. Create PR: feature/add-monitoring-alerts → development
# 5. Merge to development after review
```

---

## 🛡️ Branch Protection Rules (GitHub Settings)

### Protect `main` Branch

Go to: **Settings → Branches → Add branch protection rule**

#### Rule Configuration:

**Branch name pattern**: `main`

**Settings to Enable**:
- ✅ **Require a pull request before merging**
  - ✅ Require approvals: 1 (if working in a team)
  - ✅ Dismiss stale pull request approvals when new commits are pushed
  
- ✅ **Require status checks to pass before merging**
  - ✅ Require branches to be up to date before merging
  - Select: `lint-and-test`, `security-scan`, `build`
  
- ✅ **Require conversation resolution before merging**

- ✅ **Require linear history** (optional, keeps history clean)

- ✅ **Do not allow bypassing the above settings**

- ❌ **Allow force pushes** (keep disabled)

- ❌ **Allow deletions** (keep disabled)

**Save changes**

---

## 🚀 CI/CD Pipeline Triggers

### Current Configuration

| Event | Branch | Trigger | Actions |
|-------|--------|---------|---------|
| Push | `development` | ✅ Runs CI/CD | Lint → Test → Scan → Build |
| Push | `main` | ✅ Runs CI/CD | Full pipeline + Deploy |
| Pull Request | → `main` | ✅ Runs CI/CD | Full validation before merge |
| Manual | Any | ✅ Workflow Dispatch | Manual trigger available |

### What Runs on Each Branch

**Development Branch (Push)**:
```yaml
✓ Lint & Test
✓ Security Scan (Trivy)
✓ Docker Build
✓ Kubernetes Deployment (optional)
```

**Main Branch (PR Merge)**:
```yaml
✓ Lint & Test
✓ Security Scan (Trivy)
✓ Docker Build
✓ Tag & Push Image
✓ Production Deployment
```

---

## 📝 Commit Message Convention

Use semantic commit messages for clear history:

```bash
feat:     New feature
fix:      Bug fix
docs:     Documentation changes
style:    Code style changes (formatting, no logic change)
refactor: Code refactoring
test:     Adding or updating tests
chore:    Build process, dependencies, configs
perf:     Performance improvements
ci:       CI/CD pipeline changes
```

**Examples**:
```bash
git commit -m "feat: add Prometheus alerting rules"
git commit -m "fix: resolve memory leak in health check"
git commit -m "docs: update deployment guide"
git commit -m "ci: add Docker image caching"
```

---

## 🔍 Checking Branch Status

```bash
# View all branches
git branch -a

# View current branch
git branch --show-current

# View branch protection status (on GitHub)
# Settings → Branches → Branch protection rules

# View CI/CD status
# Go to Actions tab on GitHub
```

---

## 🆘 Common Operations

### Switch Branches
```bash
git checkout development    # Switch to development
git checkout main          # Switch to main
```

### Sync Development with Main
```bash
git checkout development
git pull origin main       # Pull changes from main
git push origin development
```

### Delete Old Feature Branch
```bash
git branch -d feature/old-feature        # Local delete
git push origin --delete feature/old-feature  # Remote delete
```

### View Branch History
```bash
git log --oneline --graph --all --decorate
```

### Undo Last Commit (Local Only)
```bash
git reset --soft HEAD~1    # Keep changes, undo commit
```

---

## 🎯 Best Practices

1. **Never commit directly to `main`** - Always use Pull Requests
2. **Keep `development` in sync** - Regularly pull from `main`
3. **Small, frequent commits** - Easier to review and revert
4. **Meaningful commit messages** - Use semantic conventions
5. **Test before pushing** - Run local tests first
6. **Review CI/CD results** - Check Actions tab after push
7. **Clean up old branches** - Delete merged feature branches
8. **Keep PR descriptions clear** - Document what changed and why

---

## 📊 Example Workflow for Interview Demo

### Scenario: Adding New Feature

```bash
# 1. Start from development
git checkout development
git pull origin development

# 2. Make changes
echo "New feature" >> portfolio/app/page.tsx

# 3. Commit with semantic message
git add .
git commit -m "feat: add new landing page section"

# 4. Push to development (CI/CD runs)
git push origin development

# 5. Verify CI/CD passes (GitHub Actions)

# 6. Create PR to main for production release
# Go to GitHub → Pull Requests → New PR
# Base: main ← Compare: development

# 7. Wait for checks, get approval, merge

# 8. Main branch automatically deploys to production
```

---

## 🔐 Security Considerations

- ✅ `main` is protected from accidental changes
- ✅ All code must pass CI/CD checks
- ✅ Security scans run on every push
- ✅ Pull Requests provide code review opportunity
- ✅ Commit history is preserved and auditable

---

## 📞 Quick Reference

```bash
# Daily workflow
git checkout development
git pull
# ... make changes ...
git add .
git commit -m "feat: description"
git push origin development

# Create release
# GitHub UI: PR from development → main
# Review → Approve → Merge
```

---

## 🎓 For Interviews

**Talk about**:
- "I use a protected `main` branch for production code"
- "Active development happens in `development` branch"
- "Every push triggers automated CI/CD pipeline"
- "Pull Requests enforce code quality and reviews"
- "Branch protection prevents accidental production changes"

This demonstrates **professional Git workflow** and **DevOps best practices**! 🚀

