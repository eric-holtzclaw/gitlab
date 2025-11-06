# Permission Audit - Other Pods

**Date:** November 5, 2025  
**Purpose:** Check if other pods with persistent volumes have similar permission issues

---

## Pods with Persistent Volumes

### ✅ Already Have Init Containers

1. **gitlab** (namespace: gitlab)
   - ✅ Fixed: Comprehensive permissions for PostgreSQL (999), Redis (998), GitLab Rails (1000)
   - Status: Fixed

2. **kali** (namespace: kali)
   - Has: `volume-permissions` init container
   - Status: ✅ Need to verify it's comprehensive

3. **kali-nomachine** (namespace: kali-nomachine)
   - Has: `volume-permissions` init container
   - Status: ✅ Need to verify it's comprehensive

4. **n8n** (namespace: n8n)
   - Has: `volume-permissions` init container
   - Status: ✅ Need to verify it's comprehensive

5. **supabase-core-postgresql** (namespace: supabase)
   - Has: `volume-permissions` init container
   - Status: ⚠️ PostgreSQL needs UID 999, strict permissions (700/600)

6. **supabase-storage** (namespace: supabase)
   - Has: `volume-permissions` init container
   - Status: ✅ Need to verify it's comprehensive

7. **supabase-postgresql-gmax-ios** (namespace: supabase-postgresql)
   - Has: `volume-permissions` init container
   - Status: ⚠️ PostgreSQL needs UID 999, strict permissions (700/600)

8. **supabase-postgresql-n8n** (namespace: supabase-postgresql)
   - Has: `volume-permissions` init container
   - Status: ⚠️ PostgreSQL needs UID 999, strict permissions (700/600)

9. **supabase-postgresql-nginx** (namespace: supabase-postgresql)
   - Has: `volume-permissions` init container
   - Status: ⚠️ PostgreSQL needs UID 999, strict permissions (700/600)

---

## Risk Assessment

### High Risk (PostgreSQL)

**PostgreSQL pods are most likely to have issues:**
- PostgreSQL requires strict permissions (700/600)
- PostgreSQL runs as UID 999
- Any permission mismatch causes "Permission denied" errors

**Pods at risk:**
- `supabase-core-postgresql`
- `supabase-postgresql-gmax-ios`
- `supabase-postgresql-n8n`
- `supabase-postgresql-nginx`

### Medium Risk (General Apps)

**Apps that might have issues:**
- `kali` - If it runs services as different users
- `kali-nomachine` - If it runs services as different users
- `n8n` - Usually runs as single user, but check
- `supabase-storage` - If it runs services as different users

---

## Recommendations

### 1. Check PostgreSQL Pods First

**Priority:** Check all PostgreSQL pods immediately

```bash
# Check if PostgreSQL pods are running
kubectl get pods -n supabase-postgresql
kubectl get pods -n supabase | grep postgresql

# Check logs for permission errors
kubectl logs -n supabase-postgresql <pod-name> | grep -i "permission\|denied"
```

**If errors found:**
- Update init container to fix PostgreSQL permissions:
  ```bash
  chown -R 999:999 /var/lib/postgresql/data
  chmod -R 700 /var/lib/postgresql/data  # Dirs
  chmod -R 600 /var/lib/postgresql/data  # Files
  ```

### 2. Verify Other Pods

**Check each pod's init container:**
```bash
# Get init container command
kubectl get deployment <name> -n <namespace> -o jsonpath='{.spec.template.spec.initContainers[0].command}'

# Check if it fixes permissions for all services
```

### 3. Standard Init Container Template

**For PostgreSQL pods:**
```yaml
initContainers:
- name: volume-permissions
  image: busybox:latest
  command: ['sh', '-c', 'chown -R 999:999 /var/lib/postgresql/data && chmod -R 700 /var/lib/postgresql/data && find /var/lib/postgresql/data -type f -exec chmod 600 {} \\; && echo "Permissions fixed"']
  securityContext:
    runAsUser: 0
  volumeMounts:
  - name: postgres-data
    mountPath: /var/lib/postgresql/data
```

**For general apps:**
```yaml
initContainers:
- name: volume-permissions
  image: busybox:latest
  command: ['sh', '-c', 'chown -R 1000:1000 /data && chmod -R 755 /data && echo "Permissions fixed"']
  securityContext:
    runAsUser: 0
  volumeMounts:
  - name: app-data
    mountPath: /data
```

---

## Action Items

### Immediate

- [ ] Check PostgreSQL pods for permission errors
- [ ] Verify PostgreSQL init containers use correct UID (999) and permissions (700/600)
- [ ] Fix any PostgreSQL pods with permission issues

### Short Term

- [ ] Audit all init containers for completeness
- [ ] Update init containers to match GitLab pattern (comprehensive)
- [ ] Document required UIDs for each service

### Long Term

- [ ] Create standard init container templates
- [ ] Add permission checks to monitoring
- [ ] Document permission requirements in deployment docs

---

## Checking Commands

### Check if Pod Has Permission Issues

```bash
# Check pod logs
kubectl logs -n <namespace> <pod-name> | grep -i "permission\|denied\|fatal"

# Check pod status
kubectl get pods -n <namespace> | grep <pod-name>

# Check for crashes/restarts
kubectl get pods -n <namespace> -o wide | grep <pod-name>
```

### Check Init Container

```bash
# Get init container command
kubectl get deployment <name> -n <namespace> -o jsonpath='{.spec.template.spec.initContainers[0].command}'

# Get init container logs (if pod restarted)
kubectl logs <pod-name> -n <namespace> -c volume-permissions --previous
```

---

## Summary

**Most at risk:** PostgreSQL pods (4 instances)
- Need UID 999
- Need strict permissions (700/600)
- Most likely to have issues

**Others:** Probably OK if they run as single user
- But should verify init containers are comprehensive

**Next step:** Check PostgreSQL pods first, then audit others

---

**Last Updated:** November 5, 2025  
**Status:** Audit complete, PostgreSQL pods need priority check

