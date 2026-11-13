# ADR 0006: Infisical settings as secrets

Status: Accepted
Supersedes: ADR 0002

## Context
ADR 0002 stores the Infisical settings as Actions variables to keep the private hostname out of the public repository. Variables are not masked, and GitHub prints a step's environment in the step log, so in a public repository the hostname, identity ID, project ID and secret path are readable in the logs. Secrets are masked.

In a reusable workflow, `vars` comes from the caller's context, but `secrets` reach the called workflow only if the caller passes them.

Infisical does not accept a list of repositories in one identity claim, so each repository needs its own machine identity.

## Decision
Store the four settings as GitHub Actions secrets with the names the variables have today:

| Secret | Level |
|--------|-------|
| `SIGN_INFISICAL_URL` | organisation, shared with each authorised repository |
| `SIGN_INFISICAL_PROJECT_ID` | organisation, shared with each authorised repository |
| `SIGN_INFISICAL_SECRET_PATH` | organisation, shared with each authorised repository |
| `SIGN_INFISICAL_IDENTITY_ID` | repository: that repository's own machine identity |

Each repository has one machine identity whose `repository` claim names only that repository. Which repositories may sign is decided by which identities exist.

`sign.yml` declares the four secrets under `on.workflow_call.secrets` (`required: true`), reads them through `secrets`, and passes the signer the same environment variables as now. The signer does not change. Callers map the secrets explicitly, with the same block in every repository:

    secrets:
      SIGN_INFISICAL_URL: ${{ secrets.SIGN_INFISICAL_URL }}
      SIGN_INFISICAL_IDENTITY_ID: ${{ secrets.SIGN_INFISICAL_IDENTITY_ID }}
      SIGN_INFISICAL_PROJECT_ID: ${{ secrets.SIGN_INFISICAL_PROJECT_ID }}
      SIGN_INFISICAL_SECRET_PATH: ${{ secrets.SIGN_INFISICAL_SECRET_PATH }}

The early check stays: the workflow fails, naming the secret, if one is empty.

(assistant's call: explicit mapping instead of `secrets: inherit`, and a per-repository identity secret instead of a repository-to-identity lookup.)

## Consequences
- The settings are masked in logs of public repositories. A short value such as a `/rpm` secret path would also mask unrelated log text, so error messages name the secret, never its value.
- The caller contract changes: every caller needs the `secrets:` block. Callers already on `@v1` break until they add it. The architect decides whether this goes into `v1` or a new major version, which needs the additions described in ADR 0003.
- Onboarding a repository: create its identity in Infisical (`repository` claim, plus the `job_workflow_ref` restriction), set `SIGN_INFISICAL_IDENTITY_ID` on the repository, and share the three organisation secrets with it. Removing a repository means deleting its identity.
- A repository-level secret overrides an organisation secret of the same name, as with variables. Infisical still decides what an identity may read.
- Secret values cannot be read back from GitHub, so keep them in Infisical or the architect's records.

## Alternatives considered
- Keep variables (ADR 0002): no caller change, but the values appear in public logs. Not chosen.
- Make only `SIGN_INFISICAL_URL` a secret: it alone exposes the hostname, so fewer masking side effects, but two kinds of settings and the same caller change. Not chosen; the architect may prefer it.
- `secrets: inherit`: shorter caller code, but passes every caller secret to the workflow. Not chosen.
- Repository-to-identity lookup in one organisation secret: callers need no per-repository secret, but every repository receives every identity ID and onboarding edits a secret that cannot be read back. Not chosen.
