# GitLab MCP Quick Start Guide

**For Cursor AI Users**  
**Status:** ✅ Configured and Working

---

## What is GitLab MCP?

Model Context Protocol (MCP) lets Cursor AI directly interact with your GitLab instance. Instead of manually using the web UI or API, you can just ask Cursor to:
- List projects
- Create merge requests
- Read/update files
- Manage issues
- Trigger pipelines
- And much more!

---

## Is It Configured?

✅ **Yes!** Your GitLab MCP is already set up and working.

**Configuration Location:** `~/.cursor/mcp.json`

**GitLab Instance:** `http://10.0.0.16:8080`  
**Status:** ✅ Operational

---

## How to Use It

### 1. Just Ask Cursor!

Simply ask Cursor to do GitLab operations in natural language:

```
"List all my GitLab projects"
"Show me the kali project details"
"Create a merge request for the feature branch"
"Read the .gitlab-ci.yml file from infrastructure/gitlab"
"List all open issues in the kali project"
```

### 2. Common Commands

#### **Project Management**
```
"List all GitLab projects"
"Show me details for infrastructure/gitlab"
"Create a new project called 'my-app'"
```

#### **Repository Operations**
```
"Read the README.md from infrastructure/gitlab"
"Show me the file tree for the kali project"
"Create a new branch called feature/new-feature in kali"
```

#### **Merge Requests**
```
"List all open merge requests"
"Create a merge request from feature-branch to main in kali"
"Show me the diff for merge request #5"
"Merge merge request #3"
```

#### **Issues**
```
"List all open issues in kali"
"Create an issue titled 'Fix bug' in kali"
"Show me issue #10 details"
"Close issue #5"
```

#### **CI/CD**
```
"Trigger a pipeline for the main branch in kali"
"Show me the latest pipeline status"
"List all pipelines for infrastructure/gitlab"
```

---

## Examples

### Example 1: List Projects
**You say:**
> "Show me all my GitLab projects"

**Cursor does:**
- Calls `list_projects` via MCP
- Returns list of all projects with details

### Example 2: Read a File
**You say:**
> "Read the .gitlab-ci.yml file from infrastructure/gitlab"

**Cursor does:**
- Calls `get_file_contents` via MCP
- Returns file content
- Can even suggest edits!

### Example 3: Create Merge Request
**You say:**
> "Create a merge request from feature/new-ui to main in the kali project"

**Cursor does:**
- Calls `create_merge_request` via MCP
- Creates the MR with your specifications
- Returns MR details

### Example 4: Update CI/CD Config
**You say:**
> "Add a new test stage to the .gitlab-ci.yml in infrastructure/gitlab"

**Cursor does:**
- Reads current `.gitlab-ci.yml`
- Updates it with new stage
- Uses `create_or_update_file` to save changes
- Can create MR or commit directly

---

## Available MCP Tools

### Project Operations
- `list_projects` - List all projects
- `get_project` - Get project details
- `create_project` - Create new project
- `update_project` - Update project settings

### Repository Operations
- `get_repository_tree` - List files/directories
- `get_file_contents` - Read file content
- `create_or_update_file` - Create/update files
- `create_branch` - Create new branch
- `get_branch_diffs` - Show branch differences

### Merge Requests
- `list_merge_requests` - List MRs
- `get_merge_request` - Get MR details
- `create_merge_request` - Create MR
- `update_merge_request` - Update MR
- `merge_merge_request` - Merge MR
- `get_merge_request_diffs` - Show MR diffs

### Issues
- `list_issues` - List issues
- `get_issue` - Get issue details
- `create_issue` - Create issue
- `update_issue` - Update issue
- `delete_issue` - Delete issue

### Labels & Milestones
- `list_labels` - List project labels
- `create_label` - Create label
- `update_label` - Update label

---

## Tips & Tricks

### 1. Be Specific
✅ **Good:** "Create a merge request from feature/auth to main in infrastructure/gitlab"  
❌ **Vague:** "Create a merge request"

### 2. Use Project Paths
Use the full path: `infrastructure/gitlab` or `root/kali`

### 3. Combine Operations
```
"Read the .gitlab-ci.yml, add a deploy stage, and create a merge request"
```

### 4. Ask for Status
```
"What's the status of merge request #5?"
"Show me all failed pipelines"
```

---

## Troubleshooting

### MCP Not Working?

1. **Check Cursor MCP Status:**
   - Open Cursor Output panel (Cmd+Shift+U)
   - Select "MCP Logs"
   - Look for "gitlab-mcp-free"

2. **Verify Configuration:**
   ```bash
   cat ~/.cursor/mcp.json | python3 -m json.tool
   ```

3. **Test GitLab API:**
   ```bash
   curl -H "PRIVATE-TOKEN: YOUR_TOKEN" \
     "http://10.0.0.16:8080/api/v4/version"
   ```

### Common Issues

**"500 Internal Server Error"**
- Usually temporary
- Try again in a few seconds
- Check GitLab pod status: `kubectl get pods -n gitlab`

**"Project not found"**
- Use full path: `infrastructure/gitlab` not just `gitlab`
- Check project exists: "List all projects"

**"Permission denied"**
- Token may have expired
- Check token in `token_vault.json`
- Verify token has required scopes

---

## Quick Reference

### Project Paths
- `infrastructure/gitlab` - This repo
- `root/kali` - Kali project
- `root/web-server` - Web server project
- `applications/health-app` - Health app

### Common Workflows

**Create Feature Branch:**
```
"Create a branch called feature/new-feature in infrastructure/gitlab"
```

**Update CI/CD:**
```
"Read .gitlab-ci.yml from infrastructure/gitlab, add a test stage, and save it"
```

**Create MR:**
```
"Create a merge request from feature/new-feature to main in infrastructure/gitlab with title 'Add new feature'"
```

**Check Pipeline:**
```
"Show me the latest pipeline for infrastructure/gitlab"
```

---

## Advanced Usage

### Multi-Step Operations
Cursor can chain operations:
```
"Read the README, update it with new instructions, create a branch, commit the changes, and create a merge request"
```

### Conditional Logic
```
"If there are open issues in kali, show me the details"
```

### Data Analysis
```
"List all projects and show me which ones have the most open issues"
```

---

## Security Notes

- ✅ MCP uses your Personal Access Token
- ✅ Token stored in `~/.cursor/mcp.json`
- ✅ Token has `api`, `read_repository`, `write_repository` scopes
- ✅ Token expires: 2026-12-06
- ⚠️ Token has full access - use responsibly

---

## Need Help?

1. **Check MCP Logs:** Cmd+Shift+U → MCP Logs
2. **Test API Directly:** Use curl commands above
3. **Review Documentation:** See `MCP_GITLAB_SETUP.md` for details
4. **Check GitLab Status:** `kubectl get pods -n gitlab`

---

**Ready to use!** Just start asking Cursor to do GitLab operations in natural language. 🚀

