# Kubernetes Manifests

This directory contains all Kubernetes manifests for deploying GitLab CE.

---

## 📋 Manifest Files

### Core Resources (apply in this order)

1. **`namespace.yaml`**
   - Creates the `gitlab` namespace
   - Apply first

2. **`pv-local.yaml`**
   - Creates PersistentVolume for GitLab data
   - 50GB storage (GitLab requires more than N8N)
   - Uses hostPath for single-node clusters

3. **`pvc.yaml`**
   - Creates PersistentVolumeClaim for GitLab data
   - 50GB storage (expandable)
   - Required for repository/data persistence

4. **`configmap.yaml`**
   - GitLab configuration (non-sensitive)
   - Omnibus configuration
   - Can be safely committed

5. **`secret.yaml`**
   - **DO NOT COMMIT** (in .gitignore)
   - Contains root password and email
   - Generated from token vault (optional)

6. **`deployment.yaml`**
   - Main GitLab deployment
   - Uses official `gitlab/gitlab-ce:latest` image
   - Resource limits based on server specs

7. **`service.yaml`**
   - ClusterIP service (internal only)
   - Exposes GitLab on ports 80, 443, 2222

---

## 🚀 Quick Deploy

```bash
# Automated (recommended)
./scripts/deploy-gitlab.sh

# Or manual
kubectl apply -f namespace.yaml
kubectl apply -f pv-local.yaml
kubectl apply -f pvc.yaml
kubectl apply -f configmap.yaml
kubectl apply -f secret.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

---

## 📊 Resource Requirements

Based on server hardware analysis:

- **Memory:** 4Gi request, 8Gi limit
- **CPU:** 2000m request, 4000m limit
- **Storage:** 50Gi PVC (GitLab requires more storage)

**Server has:** 24 cores, 131GB RAM - ✅ Plenty of capacity

**Note:** GitLab is resource-intensive. Initial startup takes 5-10 minutes.

---

## 🔧 Customization

### Change GitLab Version

Edit `deployment.yaml`:
```yaml
image: gitlab/gitlab-ce:16.0.0  # Specific version
```

### Adjust Resource Limits

Edit `deployment.yaml`:
```yaml
resources:
  requests:
    memory: "8Gi"    # Increase if needed
    cpu: "4000m"
  limits:
    memory: "16Gi"
    cpu: "8000m"
```

### Change Storage Size

Edit `pvc.yaml` and `pv-local.yaml`:
```yaml
resources:
  requests:
    storage: 100Gi  # Increase from 50Gi
```

### Configure External URL

Edit `configmap.yaml`:
```yaml
GITLAB_OMNIBUS_CONFIG: |
  external_url 'https://gitlab.yourdomain.com'
  # Add SSL certificate configuration
```

---

## 🔍 Verification

```bash
# Check all resources
kubectl get all -n gitlab

# Check pods
kubectl get pods -n gitlab

# Check storage
kubectl get pvc -n gitlab
kubectl get pv

# Check service
kubectl get svc -n gitlab

# View logs
kubectl logs -n gitlab deployment/gitlab -f

# Get GitLab root password (if stored in secret)
kubectl get secret gitlab-secrets -n gitlab -o jsonpath='{.data.GITLAB_ROOT_PASSWORD}' | base64 -d
```

---

## 🌐 Accessing GitLab

### Port Forward (Temporary)

```bash
# HTTP/HTTPS
kubectl port-forward -n gitlab service/gitlab-service 8080:80

# SSH (for Git operations)
kubectl port-forward -n gitlab service/gitlab-service 2222:2222
```

Then access:
- Web UI: http://localhost:8080
- Git SSH: `git@localhost:2222:username/repo.git`

### LoadBalancer (Permanent)

Edit `service.yaml`:
```yaml
spec:
  type: LoadBalancer
```

Then access via LoadBalancer IP.

---

## 🔐 Security Notes

1. **Change Default Password**: Immediately change root password after first login
2. **Use Strong Passwords**: Update `secret.yaml` with strong password
3. **SSL/TLS**: For production, configure SSL certificates
4. **Firewall**: GitLab is behind firewall (10.0.0.1) - access via SASE VPN

---

## 📚 Additional Resources

- [GitLab Documentation](https://docs.gitlab.com/)
- [GitLab Docker Image](https://hub.docker.com/r/gitlab/gitlab-ce)
- [GitLab Omnibus Configuration](https://docs.gitlab.com/omnibus/settings/configuration.html)

---

**Last Updated:** November 2025



