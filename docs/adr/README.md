# Architecture Decision Records

Decisions are recorded one per file, numbered in order. Status is `Proposed`, `Accepted`, `Superseded by NNNN` or `Rejected`. Only the human architect moves a record to `Accepted`.

| ADR | Title | Status |
|-----|-------|--------|
| [0001](0001-reusable-workflow-and-signer-image.md) | Reusable workflow plus digest-pinned signer image | Accepted |
| [0002](0002-org-variables-for-infisical-config.md) | Non-secret Infisical settings as organisation variables | Superseded by 0006 |
| [0003](0003-workflow-version-pinning.md) | Callers pin the workflow by the `v1` tag | Accepted |
| [0004](0004-job-container-mode.md) | Run the signing job in a hardened job container | Accepted |
| [0005](0005-signer-image.md) | Signer image | Accepted |
| [0006](0006-org-secrets-for-infisical-config.md) | Infisical settings as secrets (supersedes 0002) | Accepted |

Template: Context, Decision, Consequences, Alternatives considered. Items marked "(assistant's call)" were not decided by the architect.
