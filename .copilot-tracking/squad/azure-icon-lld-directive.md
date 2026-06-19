# Azure-Icon LLD Diagram Directive

Use this when re-running `/squad` so the **Squad Azure Architect** renders the
Low-Level Design as a real draw.io diagram with **Azure icons** through the
`drawio` MCP server (configured in `.vscode/mcp.json`), instead of plain Mermaid.

## Prerequisites

1. `.vscode/mcp.json` contains the `drawio` stdio server (`@drawio/mcp`).
2. In VS Code: Start the `drawio` server, trust it, set Copilot Chat to **Agent**
   mode, and enable the `drawio` tools under Configure Tools (🔧).

## Ready-to-run command

```text
/squad request="Render the Low-Level Design for the approved West Europe internal web app as a draw.io diagram with real Azure icons. Use the drawio MCP `open_drawio_xml` tool and emit draw.io mxGraphModel XML whose shapes reference Azure stencils (mxgraph.azure.* — App Service, Azure SQL Database, Storage, Key Vault, VNet/subnet, Private Endpoint, Log Analytics). Derive every node and edge from the existing Bicep modules under infra/bicep/modules/ (app-service, networking, sql, storage, key-vault, monitoring, governance). Show the VNet with the integration subnet and the private-endpoints subnet, private endpoints for SQL/Storage/Key Vault, managed-identity flows, and diagnostics to Log Analytics. Save the resulting .drawio (and a PNG/SVG export if available) under docs/architecture/."
```

## Directive the architect must follow

* Prefer the `drawio` MCP `open_drawio_xml` tool; fall back to Mermaid only if
  the server is unavailable.
* Do **not** use `open_drawio_mermaid` for the icon LLD — Mermaid has no Azure
  icon set and will produce plain boxes.
* Emit draw.io XML that references Azure stencils via `shape=mxgraph.azure.*`
  style strings so each node renders with its product icon.
* Ground every node and dependency edge in the Bicep modules under
  `infra/bicep/modules/`, not in a re-derived design.
* Persist the artifact under `docs/architecture/` (`.drawio` plus an exported
  `.png`/`.svg` when the tool supports export) so the diagram is committed, not
  only opened in a browser tab.

## Notes

* The `drawio` tool server opens the diagram in the browser draw.io editor and
  returns a `#create=` URL; save from there to land the file in the repo.
* For a fully file-based, scriptable alternative (PNG/SVG written straight to
  `docs/architecture/`), the Python `diagrams` library with `diagrams.azure.*`
  nodes via the `python-foundational` skill is the most repo-friendly path.
