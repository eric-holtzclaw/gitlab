# GitLab MCP Setup - Complete Step-by-Step Guide

**Date:** December 19, 2024  
**Purpose:** Complete instructions to set up GitLab MCP on ANY machine from scratch

---

## ⚠️ IMPORTANT: This Guide is for Setting Up MCP on a NEW Machine

If you're setting up MCP on a different machine, follow these steps exactly.

---

## Prerequisites

1. **Cursor IDE installed** on the machine
2. **GitLab Personal Access Token** (see Step 1)
3. **GitLab URL** (http://10.0.0.16:8080 for this setup)
4. **Terminal/Command Line access**

---

## Step 1: Get Your GitLab Personal Access Token

### Option A: If You Have Access to GitLab Web UI

1. **Open GitLab in browser:**
   ```
   http://10.0.0.16:8080
   ```

2. **Login** with your credentials

3. **Go to User Settings:**
   - Click your avatar (top right)
   - Click "Preferences" or "Edit Profile"
   - Click "Access Tokens" in left sidebar

4. **Create New Token:**
   - **Token name:** `Cursor AI MCP`
   - **Expiration date:** Set as needed (or leave blank for no expiration)
   - **Select scopes:** Check ALL of these:
     - ✅ `api` (Full API access)
     - ✅ `read_repository` (Read repository)
     - ✅ `write_repository` (Write repository)
     - ✅ `read_registry` (Read container registry)
     - ✅ `write_registry` (Write container registry)
   - Click **"Create personal access token"**

5. **COPY THE TOKEN IMMEDIATELY:**
   - It will look like: `glpat-XXXXXXXXXXXXXXXXXXXXXXXX`
   - **You can only see it once!** Save it somewhere safe.

### Option B: If You Have the Token Already

If you already have a token, use it. The token format is:
```
glpat-XXXXXXXXXXXXXXXXXXXXXXXX
```

**For this setup, the token is:**
```
glpat-ZzivPXWqEwyhXgu2Igqh_286MQp1OjEH.01.0w01ltav7
```

---

## Step 2: Create the MCP Configuration File

### On macOS/Linux:

1. **Open Terminal**

2. **Create the `.cursor` directory if it doesn't exist:**
   ```bash
   mkdir -p ~/.cursor
   ```

3. **Create the `mcp.json` file:**
   ```bash
   nano ~/.cursor/mcp.json
   ```
   
   Or use your preferred editor:
   ```bash
   vim ~/.cursor/mcp.json
   # or
   code ~/.cursor/mcp.json
   ```

4. **Paste this EXACT content** (replace `YOUR_TOKEN_HERE` with your actual token):

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
           "GITLAB_PERSONAL_ACCESS_TOKEN": "YOUR_TOKEN_HERE",
           "GITLAB_API_URL": "http://10.0.0.16:8080/api/v4",
           "GITLAB_READ_ONLY_MODE": "false"
         }
       }
     }
   }
   ```

5. **Replace `YOUR_TOKEN_HERE` with your actual token:**
   
   Example (with the actual token):
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

6. **Save the file:**
   - In nano: Press `Ctrl+X`, then `Y`, then `Enter`
   - In vim: Press `Esc`, type `:wq`, press `Enter`
   - In VS Code: Press `Cmd+S` (Mac) or `Ctrl+S` (Windows/Linux)

### On Windows:

1. **Open PowerShell or Command Prompt**

2. **Create the `.cursor` directory:**
   ```powershell
   mkdir $env:USERPROFILE\.cursor
   ```

3. **Create the `mcp.json` file:**
   ```powershell
   notepad $env:USERPROFILE\.cursor\mcp.json
   ```

4. **Paste the same JSON content** (replace `YOUR_TOKEN_HERE` with your actual token)

5. **Save the file**

---

## Step 3: Verify the File Was Created Correctly

### On macOS/Linux:

```bash
# Check if file exists
ls -la ~/.cursor/mcp.json

# Verify JSON is valid
cat ~/.cursor/mcp.json | python3 -m json.tool
```

**Expected output:** Should show the JSON without errors

### On Windows:

```powershell
# Check if file exists
Test-Path $env:USERPROFILE\.cursor\mcp.json

# View file content
Get-Content $env:USERPROFILE\.cursor\mcp.json
```

---

## Step 4: Verify Token Works

### Test GitLab API Access:

```bash
# Replace YOUR_TOKEN with your actual token
curl -H "PRIVATE-TOKEN: YOUR_TOKEN" \
  http://10.0.0.16:8080/api/v4/version
```

**Expected output:**
```json
{
  "version": "18.6.2",
  "revision": "...",
  ...
}
```

**If you get an error:**
- Check the token is correct
- Check GitLab is accessible at `http://10.0.0.16:8080`
- Verify token hasn't expired

---

## Step 5: Restart Cursor IDE

**IMPORTANT:** Cursor must be completely restarted to load the MCP configuration.

### macOS:
1. **Quit Cursor completely:**
   - Press `Cmd+Q` or
   - Right-click Cursor icon in dock → Quit

2. **Reopen Cursor**

### Windows:
1. **Close Cursor completely:**
   - Close all Cursor windows
   - Check Task Manager to ensure no Cursor processes are running

2. **Reopen Cursor**

### Linux:
1. **Quit Cursor completely:**
   - Close all windows
   - Kill any remaining processes: `pkill -f cursor`

2. **Reopen Cursor**

---

## Step 6: Verify MCP is Loaded

### Method 1: Check MCP Logs in Cursor

1. **Open Cursor**
2. **Open Output Panel:**
   - macOS: `Cmd+Shift+U`
   - Windows/Linux: `Ctrl+Shift+U`

3. **Select "MCP Logs" from dropdown**

4. **Look for:**
   - `gitlab-mcp-free` server loading
   - No error messages
   - Connection successful messages

### Method 2: Test MCP in Cursor AI Chat

1. **Open Cursor AI Chat:**
   - macOS: `Cmd+L`
   - Windows/Linux: `Ctrl+L`

2. **Type this command:**
   ```
   List all GitLab projects
   ```

3. **Expected result:**
   - Should return a list of projects
   - Should include projects like `open-source-development/kali`, `infrastructure/gitlab`, etc.

**If it doesn't work:**
- Check MCP logs for errors
- Verify `mcp.json` file is correct
- Make sure Cursor was fully restarted
- Check token is valid

---

## Step 7: Test MCP Tools

### Test 1: List Projects

**In Cursor AI:**
```
Show me all GitLab projects
```

**Expected:** List of projects

### Test 2: Read a File

**In Cursor AI:**
```
Read the README.md file from the open-source-development/kali project
```

**Expected:** File contents

### Test 3: Get Project Details

**In Cursor AI:**
```
Show me the details of the infrastructure/gitlab project
```

**Expected:** Project information

---

## Troubleshooting

### Problem: MCP Server Not Loading

**Symptoms:**
- MCP logs show errors
- Cursor AI can't access GitLab

**Solutions:**

1. **Check file location:**
   ```bash
   # macOS/Linux
   ls -la ~/.cursor/mcp.json
   
   # Windows
   Test-Path $env:USERPROFILE\.cursor\mcp.json
   ```

2. **Verify JSON is valid:**
   ```bash
   # macOS/Linux
   cat ~/.cursor/mcp.json | python3 -m json.tool
   
   # Windows (if Python installed)
   python -m json.tool $env:USERPROFILE\.cursor\mcp.json
   ```

3. **Check for syntax errors:**
   - Make sure all quotes are correct
   - Make sure there are no trailing commas
   - Make sure brackets match

4. **Verify token:**
   ```bash
   curl -H "PRIVATE-TOKEN: YOUR_TOKEN" \
     http://10.0.0.16:8080/api/v4/version
   ```

### Problem: "401 Unauthorized" Error

**Cause:** Invalid or expired token

**Solution:**
1. Generate a new token in GitLab (Step 1)
2. Update `mcp.json` with new token
3. Restart Cursor

### Problem: "Connection Refused" Error

**Cause:** GitLab not accessible or wrong URL

**Solution:**
1. Test GitLab access:
   ```bash
   curl http://10.0.0.16:8080/api/v4/version
   ```

2. If it fails:
   - Check GitLab is running
   - Verify the IP address is correct
   - Check network connectivity

### Problem: MCP Tools Not Available in Cursor AI

**Cause:** Cursor didn't load MCP config

**Solution:**
1. **Completely quit Cursor:**
   - Make sure no Cursor processes are running
   - Check Activity Monitor (Mac) or Task Manager (Windows)

2. **Verify `mcp.json` exists and is correct**

3. **Restart Cursor**

4. **Check MCP logs again**

### Problem: "npx: command not found"

**Cause:** Node.js/npm not installed

**Solution:**
1. **Install Node.js:**
   ```bash
   # macOS
   brew install node
   
   # Windows
   # Download from: https://nodejs.org/
   
   # Linux
   sudo apt install nodejs npm
   ```

2. **Verify installation:**
   ```bash
   node --version
   npm --version
   npx --version
   ```

3. **Restart Cursor**

---

## Complete Example: Full Setup on New Machine

### Scenario: Setting up MCP on a brand new Mac

```bash
# Step 1: Create directory
mkdir -p ~/.cursor

# Step 2: Create mcp.json (replace YOUR_TOKEN with actual token)
cat > ~/.cursor/mcp.json << 'EOF'
{
  "mcpServers": {
    "gitlab-mcp-free": {
      "command": "npx",
      "args": [
        "-y",
        "@zereight/mcp-gitlab"
      ],
      "env": {
        "GITLAB_PERSONAL_ACCESS_TOKEN": "YOUR_TOKEN_HERE",
        "GITLAB_API_URL": "http://10.0.0.16:8080/api/v4",
        "GITLAB_READ_ONLY_MODE": "false"
      }
    }
  }
}
EOF

# Step 3: Replace token (use your actual token)
sed -i '' 's/YOUR_TOKEN_HERE/glpat-ZzivPXWqEwyhXgu2Igqh_286MQp1OjEH.01.0w01ltav7/g' ~/.cursor/mcp.json

# Step 4: Verify file
cat ~/.cursor/mcp.json | python3 -m json.tool

# Step 5: Test token
curl -H "PRIVATE-TOKEN: glpat-ZzivPXWqEwyhXgu2Igqh_286MQp1OjEH.01.0w01ltav7" \
  http://10.0.0.16:8080/api/v4/version

# Step 6: Restart Cursor (manually)
echo "Now quit and restart Cursor IDE"
```

---

## File Locations Reference

### macOS/Linux:
- **MCP Config:** `~/.cursor/mcp.json`
- **Full Path:** `/Users/USERNAME/.cursor/mcp.json` (Mac) or `/home/USERNAME/.cursor/mcp.json` (Linux)

### Windows:
- **MCP Config:** `%USERPROFILE%\.cursor\mcp.json`
- **Full Path:** `C:\Users\USERNAME\.cursor\mcp.json`

---

## Quick Reference: Complete mcp.json Template

**Copy this and replace `YOUR_TOKEN_HERE` with your actual token:**

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
        "GITLAB_PERSONAL_ACCESS_TOKEN": "YOUR_TOKEN_HERE",
        "GITLAB_API_URL": "http://10.0.0.16:8080/api/v4",
        "GITLAB_READ_ONLY_MODE": "false"
      }
    }
  }
}
```

**For this specific GitLab instance, use:**
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

---

## Verification Checklist

Before using MCP, verify:

- [ ] `mcp.json` file exists in correct location
- [ ] JSON syntax is valid (no errors when parsing)
- [ ] Token is correct and not expired
- [ ] GitLab API is accessible (`curl` test works)
- [ ] Node.js/npm/npx installed (for `npx` command)
- [ ] Cursor IDE fully restarted after creating config
- [ ] MCP logs show no errors
- [ ] Cursor AI can list GitLab projects

---

## Next Steps After Setup

Once MCP is working:

1. **Test basic operations:**
   ```
   "List all GitLab projects"
   ```

2. **Read a file:**
   ```
   "Read the README.md from open-source-development/kali"
   ```

3. **Start automating:**
   ```
   "Show me the .gitlab-ci.yml from the kali project"
   ```

---

**Last Updated:** December 19, 2024  
**Status:** ✅ Complete Setup Guide - Works on Any Machine


