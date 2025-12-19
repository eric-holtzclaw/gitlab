# Fix GitLab URL Generation Issue

**Date:** November 5, 2025  
**Issue:** Clicking URLs in GitLab redirects to `http://gitlab.local/root` instead of working URLs

---

## Problem

GitLab is configured with `external_url 'http://gitlab.local'` but is only accessible via `localhost:8080` (port-forward).

When you click links inside GitLab, it generates URLs using `gitlab.local`:
- `http://gitlab.local/root`
- `http://gitlab.local/open-source-development/google-workspace-forensics-investigator`

These URLs don't work because:
1. `gitlab.local` might not resolve (if `/etc/hosts` entry missing)
2. Even if it resolves, GitLab is on port 8080, not port 80
3. Port-forward is on `localhost:8080`, not `gitlab.local:80`

---

## Solution

Update `external_url` in GitLab configuration to match the actual access method: `localhost:8080`

### Step 1: Update ConfigMap

The configmap has been updated:
```yaml
external_url 'http://localhost:8080'
```

**File:** `GitLab/k8s/configmap.yaml`

### Step 2: Apply Configuration

```bash
cd /Users/eric/Documents/Scripts/infrastructure/gitlab
kubectl apply -f k8s/configmap.yaml
```

### Step 3: Restart GitLab

```bash
kubectl rollout restart deployment/gitlab -n gitlab
```

### Step 4: Wait for Restart

GitLab takes 5-10 minutes to fully restart. Monitor with:

```bash
# Watch pod status
kubectl get pods -n gitlab -w

# Check logs
kubectl logs -n gitlab -l app=gitlab -f
```

Wait until you see:
- Pod status: `Running` and `Ready`
- Logs show: `gitlab Reconfigured!`

### Step 5: Verify Fix

1. Access GitLab: http://localhost:8080
2. Click any link (project, user, etc.)
3. URL should now be: `http://localhost:8080/...` instead of `http://gitlab.local/...`

---

## Alternative: Keep gitlab.local but Fix Port

If you prefer to keep using `gitlab.local`:

### Option 1: Update external_url with Port

```yaml
external_url 'http://gitlab.local:8080'
```

**Note:** This might cause issues because GitLab expects port 80 for HTTP.

### Option 2: Use gitlab.local with /etc/hosts

1. Ensure `/etc/hosts` has:
   ```
   127.0.0.1 gitlab.local
   ```

2. Access GitLab via: `http://gitlab.local:8080`

3. But GitLab will still generate URLs with `gitlab.local:80` (which won't work)

**Recommendation:** Use `localhost:8080` for `external_url` (as updated above)

---

## Impact After Fix

**Before:**
- URLs in GitLab: `http://gitlab.local/root`
- Clone URLs: `http://gitlab.local/group/repo.git`
- These don't work

**After:**
- URLs in GitLab: `http://localhost:8080/root`
- Clone URLs: `http://localhost:8080/group/repo.git`
- These work correctly

---

## Reverting /etc/hosts Entry

If you added `127.0.0.1 gitlab.local` to `/etc/hosts`, you can remove it after this fix:

**macOS/Linux:**
```bash
sudo sed -i '' '/gitlab.local/d' /etc/hosts
```

**Windows:**
- Edit `C:\Windows\System32\drivers\etc\hosts` and remove the `gitlab.local` line

---

## Notes

- The `/etc/hosts` entry for `gitlab.local` was only needed because `external_url` was set to `gitlab.local`
- With `external_url` set to `localhost:8080`, the `/etc/hosts` entry is no longer needed
- All GitLab-generated URLs will now use `localhost:8080`
- SSH URLs will still work: `ssh://git@localhost:2222/group/repo.git`

---

**Last Updated:** November 5, 2025  
**Status:** ConfigMap updated, ready to apply and restart GitLab

