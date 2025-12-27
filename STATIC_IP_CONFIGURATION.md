# GitLab Static IP Configuration

**Date:** December 19, 2024  
**Status:** ✅ **ACTIVE** - Static IPs Now in Use

---

## 🌐 Static IP Configuration

GitLab and other services are now configured with **static IP addresses** using LoadBalancer services. This eliminates the need for port-forwarding and provides direct network access.

---

## 📋 Services with Static IPs (LoadBalancer)

| Service | Static IP | Ports | Purpose |
|---------|-----------|-------|---------|
| **gitlab-service** | **10.0.0.16** | 8080 (Web UI), 443 (HTTPS), 2222 (SSH), 5000 (Registry) | GitLab |
| kong-service | 10.0.0.14 | 80, 443 | Next.js Web Server |
| kali-service | 10.0.0.18 | 4000, 3389 (RDP), 22 (SSH) | Kali Linux |
| supabase-studio | 10.0.0.15 | 3000 | Supabase Studio UI |
| supabase-kong | 10.0.0.19 | 80, 443 | Supabase API Gateway |
| kubernetes-dashboard | 10.0.0.23 | 443 | K8s Dashboard |
| monitoring-grafana | 10.0.0.20 | 80 | Grafana Monitoring |
| monitoring-kube-prometheus-prometheus | 10.0.0.21 | 9090, 8080 | Prometheus |
| monitoring-kube-prometheus-alertmanager | 10.0.0.22 | 9093, 8080 | Alertmanager |
| n8n-service | 10.0.0.17 | 80 | N8N Automation |

---

## 🎯 GitLab Access (Static IP)

### **Primary Access Method: Static IP**

**GitLab Service:** `10.0.0.16`

**Access URLs:**
- **Web UI:** http://10.0.0.16:8080
- **HTTPS:** https://10.0.0.16:443
- **SSH:** `ssh://git@10.0.0.16:2222/group/repo.git`
- **Registry:** `10.0.0.16:5000`
- **API:** http://10.0.0.16:8080/api/v4

**Git Operations:**
```bash
# HTTP with token
git remote set-url origin "http://oauth2:${GITLAB_TOKEN}@10.0.0.16:8080/infrastructure/gitlab.git"

# SSH
git remote set-url origin "ssh://git@10.0.0.16:2222/infrastructure/gitlab.git"
```

**API Access:**
```bash
curl -H "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "http://10.0.0.16:8080/api/v4/version"
```

---

## ⚠️ Migration from Port-Forward

### **Old Method (Deprecated):**
- ❌ Port-forward required: `kubectl port-forward -n gitlab service/gitlab-service 8080:80`
- ❌ Access via: `http://localhost:8080`
- ❌ SSH via: `ssh://git@localhost:2222`

### **New Method (Current):**
- ✅ Direct access via static IP: `10.0.0.16`
- ✅ No port-forward needed
- ✅ Accessible from any machine on the network
- ✅ Persistent IP address

---

## 🔧 Configuration Details

### GitLab Service Configuration

**Service Type:** LoadBalancer  
**Static IP:** 10.0.0.16  
**Namespace:** gitlab

**Ports:**
- **8080** → GitLab Web UI (HTTP)
- **443** → GitLab HTTPS
- **2222** → GitLab SSH
- **5000** → GitLab Container Registry

**Pod IP:** 10.20.0.168 (internal cluster IP)

---

## 📝 Updated API Token

**New Master Token (from core repo):**
- **Token:** `glpat-ZzivPXWqEwyhXgu2Igqh_286MQp1OjEH.01.0w01ltav7`
- **Source:** `/Users/eric/Documents/Scripts/infrastructure/core/k8s-devops/k8s/web-server/push-with-vault.sh`
- **Updated:** December 19, 2024
- **Status:** ✅ Verified working with static IP

**Token Location:**
- `token_vault.json` - Updated with new token and static IP
- Core repo scripts - Using static IP `10.0.0.16:8080`

---

## 🔄 Internal Services (ClusterIP)

These services are only accessible within the Kubernetes cluster:

| Service | Cluster IP | Port | Purpose |
|---------|------------|------|---------|
| supabase-auth | 10.233.36.198 | 9999 | Supabase Auth |
| supabase-rest | 10.233.5.226 | 3000 | Supabase REST API |
| supabase-storage | 10.233.7.91 | 5000 | Supabase Storage |
| supabase-realtime | 10.233.50.213 | 4000 | Supabase Realtime |
| supabase-meta | 10.233.58.118 | 8080 | Supabase Meta |
| supabase-core-postgresql | 10.233.11.239 | 5432 | Supabase PostgreSQL |
| python-automation-service | 10.233.54.225 | 80 | Python Automation |
| nginx-service | 10.233.49.154 | 80 | Nginx |
| admin-proxy | 10.233.27.242 | 8080 | Admin Proxy |
| oauth-redirect | 10.233.45.223 | 80 | OAuth Redirect |
| web-server | 10.233.21.134 | 80 | Web Server (ClusterIP) |

---

## 🗄️ PostgreSQL Databases (ClusterIP)

| Service | Cluster IP | Port | Purpose |
|---------|------------|------|---------|
| supabase-postgresql-gmax-ios | 10.233.20.118 | 5432 | GMax iOS DB |
| supabase-postgresql-n8n | 10.233.21.141 | 5432 | N8N DB |
| supabase-postgresql-nginx | 10.233.55.16 | 5432 | Nginx DB |

---

## 📍 Pod IPs (Selected Active Pods)

| Pod | IP | Port | Status |
|-----|----|----|--------|
| kong-deployment-7c45884cc7-l66gj | 10.20.0.31 | 8000 | Running |
| kong-deployment-7c45884cc7-zm5g5 | 10.20.0.222 | 8000 | Running |
| **gitlab-6d868c85f7-5xktl** | **10.20.0.168** | **8080, 443, 2222, 5000** | **Running** |
| supabase-kong-76f8f49b7b-5bhqf | 10.20.0.11 | 80, 443 | Running |
| supabase-studio-59d8775b7c-q9h87 | 10.20.0.148 | 3000 | Running |
| n8n-6cf6569b95-4499g | 10.20.0.146 | 80 | Running |
| kali-75bb9fbb78-7psnq | 10.20.0.122 | 4000, 3389, 22 | Running |

---

## ✅ Benefits of Static IPs

1. **No Port-Forward Required**
   - Direct network access
   - No need to run `kubectl port-forward`
   - Accessible from any machine on the network

2. **Persistent Access**
   - IP address doesn't change
   - Reliable for automation and scripts
   - No need to update URLs

3. **Network-Wide Access**
   - Accessible from any device on the network
   - Not limited to localhost
   - Better for team collaboration

4. **Production-Ready**
   - Standard LoadBalancer configuration
   - Proper external access
   - Scalable architecture

---

## 🔗 Quick Reference

### GitLab Access
- **Web UI:** http://10.0.0.16:8080
- **API:** http://10.0.0.16:8080/api/v4
- **SSH:** `ssh://git@10.0.0.16:2222/group/repo.git`
- **Registry:** `10.0.0.16:5000`

### Other Services
- **Kong:** http://10.0.0.14
- **Supabase Studio:** http://10.0.0.15:3000
- **N8N:** http://10.0.0.17
- **Kali:** http://10.0.0.18:4000
- **Grafana:** http://10.0.0.20
- **Prometheus:** http://10.0.0.21:9090
- **K8s Dashboard:** https://10.0.0.23:443

---

## 📝 Documentation Updates Required

The following files should be updated to reflect static IP usage:
- ✅ `token_vault.json` - Updated with new token and static IP
- ⏳ `README.md` - Update access URLs
- ⏳ All scripts using `localhost:8080` → `10.0.0.16:8080`
- ⏳ Documentation referencing port-forward → static IP

---

**Last Updated:** December 19, 2024  
**Status:** ✅ Static IPs Active and Verified



