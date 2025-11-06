# Secret Management Strategy

**Date:** November 4, 2025  
**Status:** ✅ Best Practices Implemented

---

## 🎯 Secret Storage Strategy

**Hybrid Approach:** Use the right tool for the right job.

| Secret Type | Storage Location | Purpose | Access Method |
|------------|------------------|---------|---------------|
| **GitLab CI/CD Secrets** | GitLab CI/CD Variables | Pipeline execution | `$VARIABLE_NAME` in pipelines |
| **Kubernetes Runtime Secrets** | Kubernetes Secrets | Container environment | Environment variables in pods |
| **Supabase Database Secrets** | Supabase vault + K8s | Database services | K8s secrets for Supabase pods |
| **Development Source of Truth** | Local `token_vault.json` | Local management | Scripts read from here |

---

## 📁 Architecture

### 1. **Local Development: `token_vault.json`**
**Purpose:** Source of truth for all secrets (NOT committed to git)

**Location:** `token_vault.json` (in each service directory)

**Workflow:**
```bash
# Edit vault locally
vim token_vault.json

# Generate K8s secrets from vault
bash scripts/vault-to-k8s-secret.sh

# Apply to cluster
kubectl apply -f k8s/secret.yaml
```

**Benefits:**
- ✅ Single source of truth
- ✅ Not committed to git (in `.gitignore`)
- ✅ Easy to manage locally
- ✅ Scripts convert to K8s secrets automatically

---

### 2. **Kubernetes Secrets: Runtime Secrets**
**Purpose:** Secrets needed by running containers

**Generated from:** `token_vault.json` → `k8s/secret.yaml`

**Use Cases:**
- GitLab root password
- Supabase database passwords
- Database connection strings
- Application API keys
- Service-to-service authentication

**Benefits:**
- ✅ Encrypted at rest in etcd
- ✅ Accessible to pods via environment variables
- ✅ Namespace-scoped (isolation)
- ✅ Can be mounted as volumes

---

### 3. **GitLab CI/CD Variables: Pipeline Secrets**
**Purpose:** Secrets needed during CI/CD pipeline execution

**Location:** GitLab UI → Project Settings → CI/CD → Variables

**Use Cases:**
- GitHub Personal Access Token (for mirroring)
- Docker Hub credentials
- Kubernetes kubeconfig (for deployments)
- SSH keys for deployment
- External API keys (for testing)
- Deployment tokens

**How to Add:**
1. Go to: `http://localhost:8080/project/-/settings/ci_cd`
2. Expand "Variables"
3. Add variable:
   - **Key:** `GITHUB_TOKEN`
   - **Value:** `your_token_here`
   - **Type:** Variable (not File)
   - **Protect:** ✅ (only on protected branches)
   - **Mask:** ✅ (hide in logs)

**Benefits:**
- ✅ Encrypted storage in GitLab
- ✅ Masked in pipeline logs
- ✅ Protected by GitLab RBAC
- ✅ Environment-specific (can set per environment)
- ✅ Accessible to all pipeline jobs

---

### 4. **Supabase Secrets: Database-Specific**
**Purpose:** Supabase service secrets (JWT, database passwords)

**Current Approach:**
- Stored in `token_vault.json` (source of truth)
- Generated to `k8s/supabase-core/secrets.yaml`
- Applied to Kubernetes for Supabase services

**Benefits:**
- ✅ Separate from GitLab secrets
- ✅ Managed by Supabase deployment scripts
- ✅ Can be queried from K8s if needed

---

## 🔄 Workflow

### Development/Setup
1. **Edit secrets locally:**
   ```bash
   vim token_vault.json
   ```

2. **Generate K8s secrets:**
   ```bash
   # GitLab
   bash scripts/vault-to-k8s-secret.sh
   
   # Supabase
   bash scripts/vault-to-k8s-secrets.sh
   ```

3. **Apply to Kubernetes:**
   ```bash
   kubectl apply -f k8s/secret.yaml
   ```

### CI/CD Pipeline
1. **Add secrets to GitLab CI/CD Variables:**
   - GitHub token
   - Docker Hub credentials
   - K8s kubeconfig
   - SSH keys

2. **Use in `.gitlab-ci.yml`:**
   ```yaml
   variables:
     GITHUB_TOKEN: $GITHUB_TOKEN  # From CI/CD variables
   ```

---

## 📋 Service-Specific Setup

### GitLab Secrets

**Local:** `token_vault.json`
```json
{
  "gitlab": {
    "root_password": "...",
    "root_email": "admin@gitlab.local"
  }
}
```

**Kubernetes:** `k8s/secret.yaml` (generated)
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: gitlab-secrets
  namespace: gitlab
type: Opaque
stringData:
  GITLAB_ROOT_PASSWORD: "..."
  GITLAB_ROOT_EMAIL: "..."
```

**GitLab CI/CD Variables:**
- `GITHUB_TOKEN` - For repository mirroring
- `DOCKERHUB_USER` - Docker Hub username
- `DOCKERHUB_PASSWORD` - Docker Hub password (masked)
- `K8S_CONFIG` - Base64 encoded kubeconfig (masked)
- `K8S_SSH_KEY` - SSH key for K8s server (masked)

---

### Supabase Secrets

**Local:** `token_vault.json`
```json
{
  "supabase": {
    "core": {
      "jwt": {
        "secret": "..."
      },
      "database": {
        "postgres_password": "..."
      },
      "api": {
        "anon_key": "...",
        "service_role_key": "..."
      }
    },
    "apps": {
      "gmax_ios": {
        "database": {
          "name": "gmax_ios",
          "user": "...",
          "password": "..."
        }
      }
    }
  }
}
```

**Kubernetes:** `k8s/supabase-core/secrets.yaml` (generated)

---

## 🔐 Security Best Practices

### 1. **Rotation**
- Rotate secrets regularly (90 days recommended)
- Update `token_vault.json` → regenerate K8s secrets → apply

### 2. **Access Control**
- Use GitLab Protected Variables (only on protected branches)
- Limit who can view/edit CI/CD variables
- Use Kubernetes RBAC for K8s secrets

### 3. **Auditing**
- GitLab logs all CI/CD variable access
- Kubernetes audit logs for secret access
- Track secret changes in `token_vault.json` (git history, but not the file itself)

### 4. **Masking**
- Always mask sensitive values in GitLab CI/CD
- Never echo secrets in pipeline logs
- Use `--masked` flag in GitLab variables

---

## ⚠️ What NOT to Do

### ❌ Don't Store Secrets In:
- **Git repositories** (even private)
- **Docker images** (as environment variables in Dockerfile)
- **Public configuration files**
- **CI/CD pipeline files** (`.gitlab-ci.yml` directly)
- **Documentation** (committed markdown files)

### ✅ DO Store Secrets In:
- **GitLab CI/CD Variables** (encrypted, masked)
- **Kubernetes Secrets** (encrypted at rest)
- **Local `token_vault.json`** (not committed)
- **Environment variables** (injected at runtime)

---

## 🚀 Quick Reference

### Add Secret to GitLab CI/CD:
```bash
# Via API
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "key": "GITHUB_TOKEN",
    "value": "your_token",
    "masked": true,
    "protected": true
  }' \
  "http://localhost:8080/api/v4/projects/PROJECT_ID/variables"
```

### Generate K8s Secret from Vault:
```bash
bash scripts/vault-to-k8s-secret.sh
kubectl apply -f k8s/secret.yaml
```

---

## 📊 Summary

| Layer | Storage | Purpose | Access Method |
|-------|---------|---------|---------------|
| **Source of Truth** | `token_vault.json` | Local development | Scripts read from here |
| **Kubernetes** | K8s Secrets | Container runtime | Environment variables |
| **GitLab CI/CD** | GitLab Variables | Pipeline execution | `$VARIABLE_NAME` |
| **Supabase** | Supabase vault + K8s | Database services | K8s secrets |

---

**CFORD Compliance:**
- ✅ Single source of truth (`token_vault.json`)
- ✅ No duplicate secrets
- ✅ All changes tracked in scripts
- ✅ Documentation maintained in GitLab


