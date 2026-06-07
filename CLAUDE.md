# infrastructure/gitlab

*(CLAUDE.md auto-created to record internal docs-mcp pointer; expand with project specifics as needed.)*

## Internal docs search via docs-mcp

This and other internal repos are indexed at **docs-mcp** (LB IP 192.168.2.56,
registered globally in Claude Code under `~/.claude.json` at user scope).

Two MCP tools are exposed and available in every Claude Code session:

```
docs-mcp.search_docs(query="...", repo="infrastructure/gitlab")   # scoped to this repo
docs-mcp.search_docs(query="...")                       # cross-repo
docs-mcp.list_indexed_repos()                           # check what's indexed
```

**When to use docs-mcp:** *conceptual* questions like "how do we deploy X",
"what's the pattern for Y across our repos", "find the runbook for Z
incident". Returns `{repo, path, chunk, score, gitlab_url}` ranked by
semantic similarity. Score > 0.6 is strong; chunks are prefixed with the
document's H1 title for free topic context.

**When NOT to use docs-mcp:** *locational* questions ("where is foo
defined", "what file has bar") — use Read / grep instead. *External library
reference* (Kubernetes / Cilium / FastAPI / Qdrant / etc.) — use **Context7**,
also globally registered.

Service runbook: `infrastructure/kubespray-bcs-staging/docs/operations/docs-mcp.md`
Source repo: `infrastructure/docs-mcp`
