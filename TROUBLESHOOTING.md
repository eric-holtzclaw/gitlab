# GitLab Troubleshooting Guide

## Issue: Can't Access http://localhost:8080

### Common Causes

1. **GitLab Not Ready Yet** (Most Common)
   - GitLab takes 5-10 minutes to fully start
   - Container is running but services are still initializing

2. **Port-Forward Not Running**
   - No process forwarding port 8080

3. **GitLab Pod Not Running**
   - Pod crashed or failed to start

---

## 🔍 Diagnostic Steps

### Step 1: Check Pod Status

```bash
kubectl get pods -n gitlab
```

**Expected States:**
- `PodInitializing` - Still starting (normal, wait 5-10 minutes)
- `Running` but not `Ready` - Initializing (normal, wait 5-10 minutes)
- `Running` and `Ready` - ✅ Ready to use!

### Step 2: Check if Port-Forward is Running

```bash
lsof -i :8080
```

**If nothing shows:** Port-forward is not running

**If something shows:** Port-forward is already running (try accessing http://localhost:8080)

### Step 3: Check GitLab Logs

```bash
kubectl logs -n gitlab -l app=gitlab -f
```

Look for:
- `==> /var/log/gitlab/gitlab-rails/production.log <==`
- `gitlab Reconfigured!` - GitLab is ready!

---

## ✅ Solutions

### Solution 1: Wait for GitLab to Initialize

**If pod shows `PodInitializing` or `Running` but not `Ready`:**

```bash
# Monitor progress
kubectl get pods -n gitlab -w

# Or check logs
kubectl logs -n gitlab -l app=gitlab -f
```

**Wait 5-10 minutes** for GitLab to:
- Initialize PostgreSQL database
- Configure Redis
- Set up repositories structure
- Run initial migrations

### Solution 2: Start Port-Forward

**Once GitLab is Ready:**

```bash
cd /Users/eric/Documents/Scripts/infrastructure/gitlab

# Use automated script
./scripts/check-gitlab-status.sh

# Or manually
kubectl port-forward -n gitlab service/gitlab-service 8080:80
```

### Solution 3: Check GitLab Readiness

```bash
# Check if GitLab is responding (even if not "Ready" in K8s)
kubectl exec -n gitlab -l app=gitlab -- curl -I http://localhost:80/users/sign_in 2>&1 | head -5
```

---

## 🚀 Quick Fix Commands

### Check Status and Auto-Start Port-Forward

```bash
cd /Users/eric/Documents/Scripts/infrastructure/gitlab
./scripts/check-gitlab-status.sh
```

This script will:
1. Check if GitLab is ready
2. Automatically start port-forward if ready
3. Show you how to access GitLab

### Manual Port-Forward

```bash
# Start port-forward (run in terminal and leave it running)
kubectl port-forward -n gitlab service/gitlab-service 8080:80

# Then open browser to: http://localhost:8080
```

### Monitor GitLab Startup

```bash
# Watch pod status
kubectl get pods -n gitlab -w

# Watch logs
kubectl logs -n gitlab -l app=gitlab -f
```

---

## ⏱️ Expected Timeline

| Time | Status | What's Happening |
|------|--------|------------------|
| 0-2 min | Pulling image | Downloading ~1.8GB GitLab image |
| 2-5 min | Initializing | Starting containers, setting up volumes |
| 5-10 min | Configuring | Database initialization, migrations |
| 10+ min | Ready | ✅ GitLab is accessible |

---

## 🔧 Advanced Troubleshooting

### Pod Stuck in PodInitializing

```bash
# Check events
kubectl get events -n gitlab --sort-by='.lastTimestamp' | tail -20

# Check pod details
kubectl describe pod -n gitlab -l app=gitlab

# Check init container logs
kubectl logs -n gitlab -l app=gitlab -c volume-permissions
```

### Port-Forward Keeps Disconnecting

```bash
# Run in background with nohup
nohup kubectl port-forward -n gitlab service/gitlab-service 8080:80 > /tmp/gitlab-pf.log 2>&1 &

# Or use screen/tmux
screen -S gitlab-pf
kubectl port-forward -n gitlab service/gitlab-service 8080:80
# Press Ctrl+A then D to detach
```

### GitLab Pod Crashed

```bash
# Check crash logs
kubectl logs -n gitlab -l app=gitlab --previous

# Check pod events
kubectl describe pod -n gitlab -l app=gitlab

# Restart deployment
kubectl rollout restart deployment/gitlab -n gitlab
```

---

## 📊 Current Status Check

Run this to see current status:

```bash
cd /Users/eric/Documents/Scripts/infrastructure/gitlab
./scripts/check-gitlab-status.sh
```

---

**Last Updated:** November 2025



