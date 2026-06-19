"""Azure internal web app LLD diagram for the demo repo.

Derived from the Bicep modules under ``infra/bicep/modules/``:
monitoring (Log Analytics), networking (VNet + integration/PE subnets +
private DNS zones), app-service (frontend + backend), sql, storage, and
key-vault. Renders paired PNG + SVG into ``docs/architecture/``.

Run:
    uv run --with diagrams python azure_webapp_lld.py
"""

from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from diagrams import Cluster, Diagram, Edge  # noqa: E402
from diagrams.azure.analytics import LogAnalyticsWorkspaces  # noqa: E402
from diagrams.azure.compute import AppServices  # noqa: E402
from diagrams.azure.database import SQLDatabases  # noqa: E402
from diagrams.azure.network import DNSPrivateZones, PrivateEndpoint, VirtualNetworks  # noqa: E402
from diagrams.azure.security import KeyVaults  # noqa: E402
from diagrams.azure.storage import StorageAccounts  # noqa: E402
from diagrams.onprem.client import Users  # noqa: E402

from diagram_io import diagram_kwargs  # noqa: E402


def main() -> None:
    """Render the LLD into docs/architecture/ (one level up from this script)."""
    outdir = Path(__file__).resolve().parent.parent
    with Diagram(
        "Azure Internal Web App - LLD (West Europe)",
        **diagram_kwargs("azure-webapp-lld", direction="LR", outdir=outdir),
    ):
        user = Users("Internal user")
        logs = LogAnalyticsWorkspaces("Log Analytics")

        with Cluster("VNet 10.20.0.0/16"):
            with Cluster("Integration subnet 10.20.0.0/24"):
                frontend = AppServices("Frontend App Service\nB1 - Entra ID")
                backend = AppServices("Backend App Service\nB1 - Managed identity")
            with Cluster("Private-endpoints subnet 10.20.1.0/25"):
                sql_pe = PrivateEndpoint("SQL PE")
                storage_pe = PrivateEndpoint("Storage PE")
                kv_pe = PrivateEndpoint("Key Vault PE")
            with Cluster("Private DNS zones"):
                dns = DNSPrivateZones("privatelink:\nsql / blob / vault")

        sql = SQLDatabases("Azure SQL\nBasic - private")
        storage = StorageAccounts("Storage\nprivate")
        keyvault = KeyVaults("Key Vault\nMI access")

        user >> Edge(label="HTTPS / Entra ID") >> frontend
        frontend >> Edge(label="HTTPS") >> backend
        backend >> Edge(label="managed identity") >> kv_pe >> keyvault
        backend >> Edge(label="private link") >> sql_pe >> sql
        backend >> Edge(label="private link") >> storage_pe >> storage

        for pe in (sql_pe, storage_pe, kv_pe):
            pe >> Edge(style="dashed", color="darkgreen") >> dns

        for node in (frontend, backend, sql, storage, keyvault):
            node >> Edge(style="dotted", label="diagnostics") >> logs


if __name__ == "__main__":
    main()
