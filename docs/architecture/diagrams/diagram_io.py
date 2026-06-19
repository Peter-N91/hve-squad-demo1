"""Shared output helper for the demo repo architecture diagrams.

Copied from the hve-squad `python-diagrams` skill. Every generator imports
`diagram_kwargs` from here so all diagrams emit paired PNG + SVG output
with consistent naming.
"""

from __future__ import annotations

from pathlib import Path
from typing import Any

DUAL_OUTPUT_FORMATS: list[str] = ["png", "svg"]


def diagram_kwargs(
    base_name: str,
    *,
    direction: str = "LR",
    outdir: str | Path = ".",
    show: bool = False,
) -> dict[str, Any]:
    """Return keyword arguments for ``diagrams.Diagram`` that render paired PNG + SVG."""
    out = Path(outdir)
    out.mkdir(parents=True, exist_ok=True)
    return {
        "filename": str(out / base_name),
        "outformat": list(DUAL_OUTPUT_FORMATS),
        "show": show,
        "direction": direction,
    }
