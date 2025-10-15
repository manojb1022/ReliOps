# GitHub Branch Protection Setup Guide

## 🛡️ Step-by-Step Instructions to Protect Main Branch

Follow these steps to set up branch protection on GitHub:

---

## 📍 Step 1: Navigate to Repository Settings

1. Go to your repository: **https://github.com/manojb1022/ReliOps**
2. Click on **⚙️ Settings** (top menu bar, far right)
3. In the left sidebar, click **Branches** (under "Code and automation")

---

## 📍 Step 2: Add Branch Protection Rule

1. Click **"Add branch protection rule"** button
2. In **"Branch name pattern"** field, enter: `main`

---

## 📍 Step 3: Configure Protection Settings

### ✅ Enable These Settings:

#### 1. **Require a pull request before merging**
   - ✅ Check this box
   - Sub-options:
     - ✅ **Require approvals**: Set to `1` (if working solo, you can skip this)
     - ✅ **Dismiss stale pull request approvals when new commits are pushed**
     - ✅ **Require review from Code Owners** (optional)

#### 2. **Require status checks to pass before merging**
   - ✅ Check this box
   - ✅ **Require branches to be up to date before merging**
   - **Search for and select these status checks** (they'll appear after first CI/CD run):
     - `lint-and-test`
     - `security-scan`
     - `build`
   
   > **Note**: If you don't see these checks yet, push a commit to `development` first to trigger the workflow, then come back and add them.

#### 3. **Require conversation resolution before merging**
   - ✅ Check this box (ensures all PR comments are resolved)

#### 4. **Require signed commits** (Optional, Advanced)
   - ⬜ Leave unchecked (unless you want GPG signing)

#### 5. **Require linear history** (Optional, keeps clean history)
   - ✅ Check this box (recommended)

#### 6. **Require deployments to succeed before merging** (Optional)
   - ⬜ Leave unchecked for now

#### 7. **Lock branch** (Read-only)
   - ⬜ Leave unchecked (this makes branch completely read-only)

#### 8. **Do not allow bypassing the above settings**
   - ✅ Check this box (enforces rules even for admins)

#### 9. **Restrict who can push to matching branches** (Optional)
   - ⬜ Leave unchecked if working solo

#### 10. **Allow force pushes**
   - ⬜ Leave UNCHECKED ❌ (never allow force pushes to main)

#### 11. **Allow deletions**
   - ⬜ Leave UNCHECKED ❌ (never allow deleting main branch)

---

## 📍 Step 4: Save Protection Rule

1. Scroll to the bottom
2. Click **"Create"** button
3. ✅ Your `main` branch is now protected!

---

## 📍 Step 5: Set Default Branch to Development

1. Still in **Settings → Branches**
2. Look for **"Default branch"** section at the top
3. Click the ↔️ switch icon next to `main`
4. Select **`development`** from dropdown
5. Click **"Update"**
6. Confirm the change

**Result**: New clones will checkout `development` by default

---

## 📍 Step 6: Verify Protection is Active

### Test 1: Try Direct Push to Main (Should Fail)
```bash
git checkout main
echo "test" >> test.txt
git add test.txt
git commit -m "test"
git push origin main
```

**Expected Result**: ❌ Push rejected with error:
```
remote: error: GH006: Protected branch update failed for refs/heads/main.
remote: error: At least 1 approving review is required by reviewers with write access.
```

### Test 2: Create Pull Request (Should Work)
```bash
git checkout development
echo "New feature" >> README.md
git add README.md
git commit -m "feat: update readme"
git push origin development
```

Then on GitHub:
1. Go to **Pull requests** tab
2. Click **"New pull request"**
3. Base: `main` ← Compare: `development`
4. Create PR
5. Wait for CI/CD checks to pass ✅
6. Merge when ready

---

## 🎯 What This Achieves

### Security & Quality
- ✅ Prevents accidental commits to production (`main`)
- ✅ Forces code review via Pull Requests
- ✅ Ensures all tests pass before merge
- ✅ Maintains clean, linear commit history
- ✅ All changes are auditable

### Professional Workflow
- ✅ Mimics industry-standard Git workflow
- ✅ Shows DevOps maturity in interviews
- ✅ Reduces risk of breaking production
- ✅ Enables team collaboration patterns

---

## 🔄 Daily Workflow After Protection

```bash
# Work on development branch
git checkout development
git pull origin development

# Make changes
# ... edit files ...

# Commit and push (triggers CI/CD)
git add .
git commit -m "feat: add new feature"
git push origin development

# When ready for production release:
# 1. Go to GitHub
# 2. Create Pull Request: development → main
# 3. Review CI/CD checks
# 4. Merge PR (this updates main)
```

---

## 📊 Visual Workflow

```
Development Branch (default)
    ↓ (work here daily)
    ↓ git push origin development
    ↓ (CI/CD runs automatically)
    ↓
    ↓ (when ready for release)
    ↓
    ↓ Create Pull Request
    ↓
    ↓ GitHub UI: development → main
    ↓
Main Branch (protected)
    ↓ (requires PR + CI/CD pass + review)
    ↓ Merge PR
    ↓
    ✅ Production Ready Code
```

---

## 🎓 Interview Talking Points

When explaining this setup:

**"I implemented a protected `main` branch with branch protection rules that:**
- Require all changes to go through Pull Requests
- Enforce automated CI/CD checks before merge
- Prevent direct commits to production
- Ensure code quality and review standards
- Maintain audit trail of all changes

**This follows enterprise Git workflow patterns used at companies like Google, Microsoft, and AWS."**

---

## 📞 Quick Reference Links

- Your repo settings: https://github.com/manojb1022/ReliOps/settings
- Branch protection: https://github.com/manojb1022/ReliOps/settings/branches
- Create PR: https://github.com/manojb1022/ReliOps/compare/main...development
- Actions (CI/CD): https://github.com/manojb1022/ReliOps/actions

---

## 🆘 Troubleshooting

### "I don't see status checks to select"
**Solution**: Push a commit to trigger the workflow first:
```bash
git checkout development
git commit --allow-empty -m "ci: trigger workflow"
git push origin development
```
Wait for workflow to complete, then add status checks.

### "I accidentally committed to main"
**Before protection**: Reset and move to development:
```bash
git checkout development
git merge main
git push origin development
git checkout main
git reset --hard origin/main
```

### "I want to bypass protection temporarily"
**Not recommended**, but if you must:
1. Settings → Branches → Edit rule
2. Temporarily disable "Do not allow bypassing"
3. Make your change
4. Re-enable immediately

---

## ✅ Checklist

After completing this guide:

- ✅ Main branch has protection rule enabled
- ✅ Pull requests are required for main
- ✅ CI/CD checks are required before merge
- ✅ Force pushes are disabled
- ✅ Development is set as default branch
- ✅ Workflow tested with sample PR

**Your repository now follows industry best practices! 🚀**

