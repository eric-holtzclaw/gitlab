# GitLab MCP Setup for CI/CD Automation

**Date:** December 19, 2024  
**Status:** ✅ **CONFIGURED** - Full Automation Enabled

---

## Overview

Model Context Protocol (MCP) integration with self-hosted GitLab enables Cursor AI to perform full CI/CD automation including pipeline management, container builds, and Kubernetes deployments.

---

## Configuration

### MCP Server Configuration

**Location:** `~/.cursor/mcp.json`

**GitLab MCP Server:**
```json
{
  "mcpServers": {
    "gitlab-mcp-free": {
      "command": "npx",
      "args": [
        "-y",
        "@zereight/mcp-gitlab"
      ],
      "env": {
        "GITLAB_PERSONAL_ACCESS_TOKEN": "glpat-ZzivPXWqEwyhXgu2Igqh_286MQp1OjEH.01.0w01ltav7",
        "GITLAB_API_URL": "http://10.0.0.16:8080/api/v4",
        "GITLAB_READ_ONLY_MODE": "false"
      }
    }
  }
}
```

### Key Configuration Details

- **Package:** `@zereight/mcp-gitlab` (free community MCP server)
- **GitLab Instance:** `10.0.0.16:8080` (static IP, no port-forward needed)
- **API Endpoint:** `http://10.0.0.16:8080/api/v4`
- **Mode:** Full automation (`GITLAB_READ_ONLY_MODE: false`)
- **Token:** Master GitLab PAT with full API access

### Token Information

- **Token ID:** 14
- **Name:** Master-Working-Token-20251206-192804
- **Scopes:** `api`, `read_repository`, `write_repository`
- **Status:** Active
- **Expires:** 2026-12-06
- **User:** root (administrator)
- **Last Used:** 2025-12-19

---

## MCP Capabilities Enabled

With full automation mode enabled, Cursor AI can perform:

### 1. Pipeline Management

- **Create/Update Pipelines:**
  - Create new `.gitlab-ci.yml` files
  - Update existing pipeline configurations
  - Modify pipeline stages and jobs
  - Add/remove pipeline variables

- **Pipeline Operations:**
  - Trigger pipeline runs
  - Monitor pipeline status
  - Cancel running pipelines
  - Retry failed pipelines
  - View pipeline logs and artifacts

### 2. Repository Operations

- **Branch Management:**
  - Create feature branches
  - Delete branches
  - List all branches
  - Check branch protection rules

- **Merge Requests:**
  - Create merge requests
  - Update MR descriptions
  - Approve/merge MRs
  - Review MR changes
  - Link issues to MRs

- **Code Management:**
  - Read repository files
  - Create/update files via API
  - Commit changes
  - View commit history
  - Manage project settings

### 3. Container Registry Operations

- **Image Management:**
  - List container images
  - View image tags
  - Delete old images
  - View registry usage

- **Build & Push:**
  - Trigger image builds via CI/CD
  - Tag images for deployments
  - Push to GitLab registry (`10.0.0.16:5000`)

### 4. Kubernetes Integration

- **Deployment Management:**
  - Update K8s deployment manifests
  - Trigger deployments via CI/CD pipelines
  - Monitor deployment status
  - Rollback deployments if needed

- **Integration Points:**
  - GitLab CI/CD → K8s deployment scripts
  - Container registry → K8s image pulls
  - Pipeline triggers → K8s updates

### 5. Issue & Project Management

- **Issues:**
  - Create/update issues
  - Link issues to merge requests
  - Close/resolve issues
  - Add labels and milestones

- **Projects:**
  - Manage project settings
  - Configure CI/CD variables
  - Set up webhooks
  - Manage project members

---

## Common CI/CD Automation Tasks

### Example 1: Create Feature Branch and Pipeline

**Task:** "Create a feature branch for updating the web server deployment"

**MCP Actions:**
1. Create branch: `feature/update-web-server`
2. Update `.gitlab-ci.yml` with new deployment steps
3. Create merge request
4. Trigger pipeline

### Example 2: Update Container Image Tag

**Task:** "Update the container image tag for the health-app deployment"

**MCP Actions:**
1. Read current deployment manifest
2. Update image tag in `.gitlab-ci.yml`
3. Commit changes
4. Trigger pipeline to build and deploy new image

### Example 3: Deploy to Kubernetes

**Task:** "Deploy the latest build to Kubernetes production"

**MCP Actions:**
1. Check latest pipeline status
2. Verify build succeeded
3. Trigger deployment job
4. Monitor deployment status
5. Verify deployment success

### Example 4: Rollback Deployment

**Task:** "Rollback the last deployment due to issues"

**MCP Actions:**
1. Find previous successful deployment
2. Update deployment manifest with previous image tag
3. Trigger deployment pipeline
4. Verify rollback success

---

## Security Considerations

### Token Security

- **Current Setup:**
  - Token stored in `~/.cursor/mcp.json` (local file)
  - Token has full API access (root user)
  - Token expires: 2026-12-06

- **Best Practices:**
  - Monitor token usage via GitLab audit logs
  - Consider creating dedicated user with scoped permissions
  - Rotate token periodically
  - Use separate token for MCP if needed

### Read-Only Mode

**Starting in Read-Only Mode:**
```json
"GITLAB_READ_ONLY_MODE": "true"
```

**Benefits:**
- Safe testing of MCP integration
- Prevents accidental changes
- Allows verification of MCP capabilities

**Switching to Full Automation:**
```json
"GITLAB_READ_ONLY_MODE": "false"
```

**What Changes:**
- Enables write operations (create/update/delete)
- Allows pipeline triggers
- Enables merge request creation
- Allows branch creation/deletion

### Access Control

- **Current:** Root user token (full access to all projects)
- **Recommendation:** Create dedicated user with project-specific permissions
- **Audit:** Review GitLab audit logs regularly for MCP actions

---

## Testing Checklist

### Initial Setup Verification

- [x] MCP server configuration added to `~/.cursor/mcp.json`
- [x] Token verified and active
- [x] GitLab API accessible at `10.0.0.16:8080/api/v4`
- [x] Token has required scopes (api, read_repository, write_repository)

### Functionality Testing

- [ ] MCP server loads without errors in Cursor
- [ ] Can list GitLab projects via MCP
- [ ] Can read pipeline configurations
- [ ] Can create test branch via MCP
- [ ] Can update `.gitlab-ci.yml` via MCP
- [ ] Can trigger pipeline via MCP
- [ ] Can monitor pipeline status
- [ ] Can create merge request
- [ ] Can access container registry info

### CI/CD Integration Testing

- [ ] Can create new pipeline configuration
- [ ] Can update existing pipeline
- [ ] Can trigger build pipeline
- [ ] Can trigger deployment pipeline
- [ ] Can monitor deployment status
- [ ] Can rollback deployment

---

## Troubleshooting

### MCP Server Not Loading

**Symptoms:** MCP server doesn't appear in Cursor

**Solutions:**
1. Verify `~/.cursor/mcp.json` syntax is valid JSON
2. Check that `npx` is available: `which npx`
3. Restart Cursor completely
4. Check Cursor logs for MCP errors

### Authentication Errors

**Symptoms:** 401 Unauthorized errors

**Solutions:**
1. Verify token is still active: Check GitLab UI → Access Tokens
2. Verify token hasn't expired
3. Check `GITLAB_API_URL` is correct: `http://10.0.0.16:8080/api/v4`
4. Verify network access to `10.0.0.16:8080`

### Read-Only Mode Issues

**Symptoms:** Cannot perform write operations

**Solutions:**
1. Check `GITLAB_READ_ONLY_MODE` setting
2. Verify token has `write_repository` scope
3. Check project permissions for token user

### Network Connectivity

**Symptoms:** Cannot reach GitLab API

**Solutions:**
1. Verify GitLab service is running: `kubectl get pods -n gitlab`
2. Test API access: `curl http://10.0.0.16:8080/api/v4/version`
3. Check firewall rules
4. Verify static IP is correct: `10.0.0.16`

---

## Integration with Existing CI/CD

### Current Pipeline Structure

Your GitLab CI/CD pipelines use:
- **Stages:** test, build, deploy
- **K8s Integration:** Deployment scripts in core repo
- **Container Registry:** GitLab registry at `10.0.0.16:5000`
- **Deployment Target:** Kubernetes cluster at `eric@10.0.0.10`

### MCP-Enhanced Workflows

**Automated Pipeline Updates:**
- MCP can update `.gitlab-ci.yml` based on project changes
- Automatically adjust build steps for new dependencies
- Update deployment targets for new environments

**Container Image Management:**
- Automatically tag images with commit SHA
- Clean up old images from registry
- Update K8s deployments with new image tags

**Deployment Automation:**
- Trigger deployments on successful builds
- Monitor deployment health
- Automatic rollback on deployment failure

---

## Next Steps

### Immediate Actions

1. **Restart Cursor** to load MCP server
2. **Test Basic Operations:**
   - Query project list
   - Read existing pipeline configs
   - Check pipeline status

### Automation Development

1. **Create Common Workflows:**
   - Feature branch creation workflow
   - Container image update workflow
   - Deployment trigger workflow

2. **Integrate with K8s:**
   - Connect pipeline triggers to K8s deployments
   - Monitor deployment status
   - Handle rollbacks automatically

3. **Enhance CI/CD Templates:**
   - Update `.gitlab-ci.yml.example` with MCP-friendly structure
   - Add MCP automation comments
   - Include K8s deployment steps

---

## References

- **GitLab MCP Package:** `@zereight/mcp-gitlab`
- **GitLab API Docs:** http://10.0.0.16:8080/help/api/README.md
- **MCP Documentation:** https://modelcontextprotocol.io
- **GitLab Instance:** http://10.0.0.16:8080
- **Container Registry:** `10.0.0.16:5000`

---

## Support

For issues or questions:
1. Check GitLab audit logs for MCP actions
2. Review Cursor MCP logs
3. Verify token permissions in GitLab UI
4. Test API access directly with curl

---

**Last Updated:** December 19, 2024  
**Configuration Status:** ✅ Active - Full Automation Enabled



