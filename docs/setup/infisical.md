# Infisical setup

How to prepare Infisical so `sign.yml` can read the signing key. This is environment setup, not a design decision of this repository. The workflow reads the non-secret settings from organisation variables (ADR 0002).

## One identity for the whole organisation

Create one machine identity with **OIDC Auth** and read-only access to a single folder of the `rpm-signing` project. The signer reads three secrets there: `GPG_PRIVATE_KEY` (the exported signing subkey), `GPG_PASSPHRASE` and `GPG_FINGERPRINT`. Only the signing subkey is stored in Infisical; the primary key stays offline.

Identity settings:

| Setting | Value |
|---------|-------|
| Issuer | `https://token.actions.githubusercontent.com` |
| Audience | the value `sign.yml` requests (`OIDC_AUDIENCE`) |
| Claim `repository_owner` | `PoschLabs` |
| Claim `repository` | the list of repositories allowed to sign, for example `PoschLabs/{repo-a,repo-b}` |
| Claim `job_workflow_ref` | exactly `PoschLabs/sign-rpm-action/.github/workflows/sign.yml@refs/tags/v1` |
| Access token TTL, max uses | short TTL, low max uses |
| Trusted IPs | the signing runner VM |

Rules:

- **Unverified:** that one claim can hold a list of repositories. The Infisical documentation shows glob alternation (`{a,b}`) but this has not been tested. Test it before relying on it: a listed repository must log in (200), an unlisted one must get 401. If a list does not work, ADR 0002 changes to one identity per repository.
- Do not bind on `sub`: it uses the ID-based format (`repo:PoschLabs@<id>/<repo>@<id>:ref:...`).
- Do not use `*`: it also matches `/` and `:`. Use hardcoded values and brace lists only.
- Do not pin `ref` or `workflow_ref`: both belong to the caller.
- `job_workflow_ref` is what makes only this repository's reviewed workflow able to obtain the key. It must match the tag callers use (ADR 0003).

## Onboarding a repository

1. Add the repository to the identity's `repository` claim.
2. Share the organisation variables (ADR 0002) with the repository.
3. Add the repository to the signing runner group's allowed repositories.
4. In the repository, call `sign.yml@v1` with `permissions: id-token: write`.

## Removing a repository

Remove it from the identity's `repository` claim. It can no longer log in.

## Spike facts that this guide relies on

See `docs/spike-findings.md`, Step 4: login is `POST $INFISICAL_URL/api/v1/auth/oidc-auth/login` with `identityId` and `jwt`; a repository that does not match gets 401; `job_workflow_ref` has the form `<org>/sign-rpm-action/.github/workflows/sign.yml@refs/tags/<tag>`.
