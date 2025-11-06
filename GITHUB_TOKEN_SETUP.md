# GitHub Token Setup for Mirroring

## Quick Steps

### 1. Create GitHub Personal Access Token

1. **Go to:** https://github.com/settings/tokens
2. **Click:** "Generate new token (classic)"
3. **Fill in:**
   - **Note:** `GitLab Mirroring`
   - **Expiration:** Choose your preference (or no expiration)
   - **Scopes:** Check `repo` (Full control of private repositories)
4. **Click:** "Generate token"
5. **Copy the token immediately** (you won't see it again!)

### 2. Set Token and Run Mirroring Setup

```bash
cd /Users/ericholtzclaw/Scripts/browser/GitLab

# Set your token (replace YOUR_TOKEN with the token you copied)
export GITHUB_TOKEN=YOUR_TOKEN

# Run the mirroring setup
bash scripts/setup-github-mirroring.sh
```

### 3. Verify Mirroring

After setup, check each repository:
- http://localhost:8080/infrastructure/core/-/settings/repository#js-push-mirrors
- http://localhost:8080/infrastructure/supabase/-/settings/repository#js-push-mirrors
- http://localhost:8080/infrastructure/nginx/-/settings/repository#js-push-mirrors

---

## What Will Be Mirrored

1. **infrastructure/core** → github.com/eric-holtzclaw/core.git
2. **infrastructure/supabase** → github.com/eric-holtzclaw/supabase.git
3. **infrastructure/nginx** → github.com/eric-holtzclaw/Nginx.git

---

## Ready?

Once you have your GitHub token, just run:
```bash
export GITHUB_TOKEN=your_token_here
bash scripts/setup-github-mirroring.sh
```


