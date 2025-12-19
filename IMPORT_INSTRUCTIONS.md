# Repository Import Instructions

**Date:** November 4, 2025  
**Status:** Projects Created - Ready for Import

---

## ✅ Projects Ready for Import

All projects have been created in GitLab. Now we need to import the repository content from GitHub.

---

## 📋 Import Commands

### Infrastructure Group

#### 1. core
```bash
cd /tmp
git clone --mirror https://github.com/eric-holtzclaw/core.git core.git
cd core.git
git push --mirror http://root:ChangeMe123!@#SecurePassword@localhost:8080/infrastructure/core.git
rm -rf /tmp/core.git
```

#### 2. supabase
```bash
cd /tmp
git clone --mirror https://github.com/eric-holtzclaw/supabase.git supabase.git
cd supabase.git
git push --mirror http://root:ChangeMe123!@#SecurePassword@localhost:8080/infrastructure/supabase.git
rm -rf /tmp/supabase.git
```

#### 3. nginx
```bash
cd /tmp
git clone --mirror https://github.com/eric-holtzclaw/Nginx.git nginx.git
cd nginx.git
git push --mirror http://root:ChangeMe123!@#SecurePassword@localhost:8080/infrastructure/nginx.git
rm -rf /tmp/nginx.git
```

#### 4. gitlab
```bash
cd /tmp
git clone --mirror https://github.com/eric-holtzclaw/gitlab.git gitlab.git
cd gitlab.git
git push --mirror http://root:ChangeMe123!@#SecurePassword@localhost:8080/infrastructure/gitlab.git
rm -rf /tmp/gitlab.git
```

---

### Forensics Group

#### 5. O365-Forensics-Investigator
```bash
cd /tmp
git clone --mirror https://github.com/eric-holtzclaw/O365-Forensics-Investigator.git o365.git
cd o365.git
git push --mirror http://root:ChangeMe123!@#SecurePassword@localhost:8080/forensics/o365-forensics-investigator.git
rm -rf /tmp/o365.git
```

#### 6. Google-Workspace-Forensics-Investigator
```bash
cd /tmp
git clone --mirror https://github.com/eric-holtzclaw/Google-Workspace-Forensics-Investigator.git google-workspace.git
cd google-workspace.git
git push --mirror http://root:ChangeMe123!@#SecurePassword@localhost:8080/forensics/google-workspace-forensics-investigator.git
rm -rf /tmp/google-workspace.git
```

---

### Automation Group

#### 7. N8N
```bash
cd /tmp
git clone --mirror https://github.com/eric-holtzclaw/N8N.git n8n.git
cd n8n.git
git push --mirror http://root:ChangeMe123!@#SecurePassword@localhost:8080/automation/n8n.git
rm -rf /tmp/n8n.git
```

---

### Development Group

#### 8. kali
```bash
cd /tmp
git clone --mirror https://github.com/eric-holtzclaw/kali.git kali.git
cd kali.git
git push --mirror http://root:ChangeMe123!@#SecurePassword@localhost:8080/development/kali.git
rm -rf /tmp/kali.git
```

---

## 🚀 Automated Import Script

Use the provided script to import all repositories:

```bash
cd /Users/eric/Documents/Scripts/infrastructure/gitlab
./scripts/import-all-repos.sh
```

---

## ⚠️ Notes

1. **Skip gmaxgolfapp** - As requested, we're waiting on this one
2. **GitLab URL** - Using `localhost:8080` (port-forward must be active)
3. **Credentials** - Using root user with password from token_vault.json
4. **Mirror Mode** - Using `--mirror` to preserve all branches, tags, and history

---

## ✅ Verification

After import, verify each repository:
- Check project page in GitLab
- Verify branches and tags are present
- Check commit history

---

**Next Steps:** Run the import script or execute commands manually above.


