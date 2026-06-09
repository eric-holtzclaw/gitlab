# infrastructure/gitlab

*(CLAUDE.md auto-created to record internal docs-mcp pointer; expand with project specifics as needed.)*

## Internal docs search via docs-mcp — READ FIRST

> **For agents:** Before exploring with grep/Read/Bash, query docs-mcp for
> existing patterns, runbooks, and prior decisions across all 38 internal
> repos. The `bcs-using-docs-mcp` skill is mandatory for any "how do we do
> X here" question. Skill triggers automatically — invoke it.

Two MCP tools, available in every Claude Code session globally:

```
docs-mcp.search_docs(query="...", repo="infrastructure/gitlab")   # scoped to this repo
docs-mcp.search_docs(query="...")                       # cross-repo
docs-mcp.list_indexed_repos()                           # confirm coverage
```

**Use docs-mcp for:** "how do we deploy X", "find the runbook for Y",
"what pattern do we use for Z". Returns `{repo, path, chunk, score, gitlab_url}`.

**Use grep/Read for:** "where is `foo` defined", locational searches in
the current repo only.

**Use Context7 for:** external library docs (Kubernetes, FastAPI, etc.) —
also globally registered.

For credentials/auth on gitlab.lan or OpenBao, invoke the `bcs-openbao-auth`
and `bcs-gitlab-api` skills instead of re-deriving the patterns.

Source repo: `infrastructure/docs-mcp` · Runbook: `infrastructure/kubespray-bcs-staging/docs/operations/docs-mcp.md`
