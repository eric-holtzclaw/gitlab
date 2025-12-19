# Cursor AI GitLab Automation Playbook

**Date:** December 19, 2024  
**Purpose:** Guide for using Cursor AI with GitLab MCP for full CI/CD automation

---

## Overview

This playbook demonstrates how Cursor AI can use the GitLab MCP server to automate CI/CD pipelines, manage repositories, handle deployments, and perform Kubernetes operations.

---

## Prerequisites

✅ **MCP Server Configured:** `~/.cursor/mcp.json` with GitLab MCP  
✅ **GitLab Instance:** `http://10.0.0.16:8080` (static IP)  
✅ **Token:** Active PAT with full API access  
✅ **Mode:** Full automation enabled (`GITLAB_READ_ONLY_MODE: false`)

---

## Common Automation Scenarios

### 1. Pipeline Management

#### Scenario: Update CI/CD Pipeline Configuration

**User Request:**
> "Update the .gitlab-ci.yml file to add a new test stage before the build stage"

**Cursor AI Actions:**
1. Read current `.gitlab-ci.yml` file using MCP
2. Parse YAML structure
3. Add new test stage
4. Update file via MCP API
5. Commit changes
6. Trigger pipeline run

**MCP Tools Used:**
- `get_file_contents` - Read current pipeline config
- `create_or_update_file` - Update pipeline file
- `create_merge_request` - Create MR for review (optional)

**Example:**
```yaml
# AI reads current config
# AI adds new stage:
stages:
  - lint      # NEW: Added by AI
  - test
  - build
  - deploy

lint:
  stage: lint
  image: node:latest
  script:
    - npm run lint
```

#### Scenario: Trigger Pipeline for Deployment

**User Request:**
> "Trigger a deployment pipeline for the web-server project"

**Cursor AI Actions:**
1. Check current pipeline status
2. Create/update deployment branch if needed
3. Trigger pipeline via commit or API
4. Monitor pipeline execution
5. Report deployment status

**MCP Tools Used:**
- `get_project` - Get project details
- `create_branch` - Create deployment branch
- `create_or_update_file` - Update deployment config
- Monitor via project API calls

---

### 2. Container Image Management

#### Scenario: Update Container Image Tag for Deployment

**User Request:**
> "Update the web-server deployment to use the latest container image tag"

**Cursor AI Actions:**
1. Query container registry for latest image
2. Read current deployment manifest
3. Update image tag in deployment file
4. Update `.gitlab-ci.yml` if needed
5. Commit and trigger deployment

**MCP Tools Used:**
- `get_file_contents` - Read deployment manifests
- `create_or_update_file` - Update image tags
- `create_branch` - Create feature branch
- `create_merge_request` - Create MR for deployment

**Example Workflow:**
```bash
# AI identifies current image tag
image: registry.example.com/web-server:v1.2.3

# AI finds latest tag from registry
latest: registry.example.com/web-server:v1.2.5

# AI updates deployment
image: registry.example.com/web-server:v1.2.5
```

#### Scenario: Build and Push New Container Image

**User Request:**
> "Build a new container image for the web-server with the latest code changes"

**Cursor AI Actions:**
1. Check for code changes
2. Update `.gitlab-ci.yml` build stage if needed
3. Trigger build pipeline
4. Monitor build progress
5. Tag image appropriately
6. Push to registry

**MCP Tools Used:**
- `get_file_contents` - Read CI/CD config
- `create_or_update_file` - Update build configuration
- Monitor pipeline via project API

---

### 3. Kubernetes Deployment Automation

#### Scenario: Deploy to Kubernetes

**User Request:**
> "Deploy the latest web-server build to Kubernetes production"

**Cursor AI Actions:**
1. Check latest successful build
2. Verify container image exists
3. Update K8s deployment manifest with new image tag
4. Trigger deployment pipeline
5. Monitor deployment status
6. Verify deployment health

**MCP Tools Used:**
- `get_file_contents` - Read K8s manifests
- `create_or_update_file` - Update deployment files
- `create_branch` - Create deployment branch
- Monitor via pipeline status

**Example:**
```yaml
# AI updates deployment.yaml
spec:
  template:
    spec:
      containers:
      - name: web-server
        image: 10.0.0.16:5000/web-server:abc123def  # Updated by AI
```

#### Scenario: Rollback Deployment

**User Request:**
> "Rollback the web-server deployment to the previous version"

**Cursor AI Actions:**
1. Find previous successful deployment
2. Identify previous image tag
3. Update deployment manifest
4. Trigger rollback pipeline
5. Verify rollback success

**MCP Tools Used:**
- `get_file_contents` - Read deployment history
- `create_or_update_file` - Update to previous version
- Monitor deployment status

---

### 4. Feature Branch Workflow

#### Scenario: Create Feature Branch and Setup

**User Request:**
> "Create a feature branch for updating the deployment configuration"

**Cursor AI Actions:**
1. Create new branch from main
2. Read current deployment config
3. Make requested changes
4. Update files
5. Create merge request
6. Set up CI/CD for feature branch

**MCP Tools Used:**
- `create_branch` - Create feature branch
- `get_file_contents` - Read current configs
- `create_or_update_file` - Make changes
- `create_merge_request` - Create MR

**Example:**
```bash
# AI creates branch
Branch: feature/update-deployment-config

# AI updates files
- k8s/deployment.yaml (updated)
- .gitlab-ci.yml (updated if needed)

# AI creates MR
Title: "Update deployment configuration"
Description: "Updated deployment config with new resource limits"
```

---

### 5. Issue and Project Management

#### Scenario: Create Issue for Bug Fix

**User Request:**
> "Create an issue for the deployment failure we just saw"

**Cursor AI Actions:**
1. Analyze deployment logs
2. Create issue with relevant details
3. Link to failed pipeline
4. Add appropriate labels
5. Assign to relevant team member

**MCP Tools Used:**
- `create_issue` - Create new issue
- `update_issue` - Add details and labels
- Link to pipeline/merge request

**Example:**
```markdown
# Issue created by AI
Title: "Deployment failure in web-server pipeline"
Description: "Pipeline failed at deploy stage. Error: Image pull failed"
Labels: ["bug", "deployment", "critical"]
```

#### Scenario: Link Issue to Merge Request

**User Request:**
> "Link issue #5 to the current merge request"

**Cursor AI Actions:**
1. Get current merge request
2. Update MR description with issue reference
3. Add closing keyword if applicable

**MCP Tools Used:**
- `get_merge_request` - Get MR details
- `update_merge_request` - Add issue reference

---

### 6. Multi-Project Operations

#### Scenario: Update Multiple Projects

**User Request:**
> "Update the deployment script in all infrastructure projects"

**Cursor AI Actions:**
1. List all infrastructure projects
2. For each project:
   - Read current deployment script
   - Apply updates
   - Create branch
   - Create merge request
3. Report summary

**MCP Tools Used:**
- `list_projects` - Get all projects
- `get_file_contents` - Read scripts
- `create_or_update_file` - Update scripts
- `create_branch` - Create update branches
- `create_merge_request` - Create MRs

---

## Advanced Automation Patterns

### Pattern 1: Automated Deployment Pipeline

**Trigger:** New code pushed to main branch

**AI Workflow:**
1. Detect new commits
2. Check if tests pass
3. Build container image
4. Tag image with commit SHA
5. Update K8s deployment
6. Deploy to staging
7. Run smoke tests
8. Deploy to production (if tests pass)
9. Monitor deployment health

**MCP Tools Chain:**
```
get_file_contents → create_or_update_file → 
monitor pipeline → get_file_contents (K8s) → 
create_or_update_file (K8s) → monitor deployment
```

### Pattern 2: Automated Rollback

**Trigger:** Deployment health check fails

**AI Workflow:**
1. Detect deployment failure
2. Find previous successful deployment
3. Get previous image tag
4. Update deployment manifest
5. Trigger rollback pipeline
6. Verify rollback success
7. Create issue documenting failure

**MCP Tools Chain:**
```
monitor deployment → get_file_contents (history) → 
create_or_update_file (rollback) → create_issue
```

### Pattern 3: Dependency Update Automation

**Trigger:** Security vulnerability detected

**AI Workflow:**
1. Identify vulnerable dependency
2. Find all projects using it
3. For each project:
   - Create update branch
   - Update dependency version
   - Update CI/CD if needed
   - Run tests
   - Create merge request
4. Track all updates

**MCP Tools Chain:**
```
list_projects → get_file_contents (package files) → 
create_branch → create_or_update_file → 
create_merge_request
```

---

## MCP Tool Reference

### Project Operations
```javascript
// List all projects
list_projects({ per_page: 20 })

// Get project details
get_project({ project_id: "root/web-server" })

// Create new project
create_project({ 
  name: "new-project",
  visibility: "private" 
})
```

### Repository Operations
```javascript
// Get repository tree
get_repository_tree({ 
  project_id: "root/web-server",
  ref: "main" 
})

// Read file
get_file_contents({ 
  project_id: "root/web-server",
  file_path: ".gitlab-ci.yml",
  ref: "main" 
})

// Update file
create_or_update_file({
  project_id: "root/web-server",
  file_path: ".gitlab-ci.yml",
  content: "# Updated by AI",
  commit_message: "Update CI/CD config"
})
```

### Branch Operations
```javascript
// Create branch
create_branch({
  project_id: "root/web-server",
  branch: "feature/ai-update",
  ref: "main"
})

// Get branch diffs
get_branch_diffs({
  project_id: "root/web-server",
  from: "main",
  to: "feature/ai-update"
})
```

### Merge Request Operations
```javascript
// Create MR
create_merge_request({
  project_id: "root/web-server",
  title: "AI Automated Update",
  source_branch: "feature/ai-update",
  target_branch: "main",
  description: "Automated update by Cursor AI"
})

// List MRs
list_merge_requests({
  project_id: "root/web-server",
  state: "opened"
})
```

### Issue Operations
```javascript
// Create issue
create_issue({
  project_id: "root/web-server",
  title: "Deployment Issue",
  description: "Issue description"
})

// Update issue
update_issue({
  project_id: "root/web-server",
  issue_iid: "5",
  labels: ["bug", "deployment"]
})
```

---

## Best Practices

### 1. Always Use Feature Branches
- Create branches for all changes
- Never commit directly to main
- Use merge requests for review

### 2. Monitor Pipeline Status
- Check pipeline status before deployments
- Verify tests pass before merging
- Monitor deployment health

### 3. Document Changes
- Use descriptive commit messages
- Add detailed MR descriptions
- Link related issues

### 4. Error Handling
- Check for errors after each operation
- Verify file updates succeeded
- Confirm pipeline triggers worked

### 5. Security
- Never commit secrets
- Use CI/CD variables for sensitive data
- Review changes before merging

---

## Example Prompts for Cursor AI

### Pipeline Management
- "Update the build stage to use Node.js 20"
- "Add a security scan stage to the pipeline"
- "Trigger a deployment pipeline for web-server"
- "Check the status of the latest pipeline"

### Container Management
- "Update the container image tag to the latest build"
- "Build a new container image for the web-server"
- "List all container images in the registry"

### Kubernetes Operations
- "Deploy the latest web-server build to Kubernetes"
- "Rollback the web-server deployment"
- "Update the resource limits in the deployment"
- "Check the status of the Kubernetes deployment"

### Repository Operations
- "Create a feature branch for updating the deployment script"
- "Update the .gitlab-ci.yml file to add a new stage"
- "Read the deployment.yaml file from the repository"
- "Create a merge request for the current changes"

### Project Management
- "Create an issue for the deployment failure"
- "List all open merge requests"
- "Update issue #5 with the fix details"
- "Create a new project for the health-app"

---

## Troubleshooting

### MCP Tools Not Responding
1. Check MCP server status in Cursor
2. Verify GitLab API is accessible
3. Check token is still active
4. Review MCP logs in Cursor

### Pipeline Not Triggering
1. Verify file was committed
2. Check branch protection rules
3. Verify CI/CD is enabled
4. Check pipeline configuration syntax

### Deployment Failures
1. Check container image exists
2. Verify K8s credentials
3. Check resource limits
4. Review deployment logs

---

## Integration with Existing Workflows

### Current CI/CD Setup
- **Stages:** test, build, deploy
- **K8s Target:** eric@10.0.0.10
- **Registry:** 10.0.0.16:5000
- **Deployment Scripts:** In core repository

### MCP Enhancement
- AI can update pipeline configs
- AI can trigger deployments
- AI can monitor pipeline status
- AI can handle rollbacks

---

## Summary

Cursor AI with GitLab MCP enables:
- ✅ Full CI/CD pipeline automation
- ✅ Container image management
- ✅ Kubernetes deployment automation
- ✅ Repository and branch management
- ✅ Issue and project management
- ✅ Multi-project operations

**Status:** ✅ Ready for Production Use

---

**Last Updated:** December 19, 2024  
**Version:** 1.0

