# Infisical setup

How to prepare Infisical so `sign.yml` can read the signing key. This is environment setup, not a design decision of this repository. The workflow reads the non-secret settings from Actions variables: three organisation variables and one identity ID variable per repository (ADR 0002).

## One identity per repository

Create one machine identity for each repository that signs, with **OIDC Auth** and read-only access to the same single folder of the `rpm-signing` project. Infisical does not accept a list of repositories in one claim, so identities cannot be shared between repositories. The signer reads three secrets there: `GPG_PRIVATE_KEY` (the exported signing subkey), `GPG_PASSPHRASE` and `GPG_FINGERPRINT`. Only the signing subkey is stored in Infisical; the primary key stays offline.

Identity settings (the same for every identity except `repository`):

| Setting | Value |
|---------|-------|
| Issuer | `https://token.actions.githubusercontent.com` |
| Audience | the value `sign.yml` requests (`OIDC_AUDIENCE`) |
| Claim `repository_owner` | `PoschLabs` |
| Claim `repository` | exactly one repository, for example `PoschLabs/repo-a` |
| Claim `job_workflow_ref` | exactly `PoschLabs/sign-rpm-action/.github/workflows/sign.yml@refs/tags/v1` |
| Access token TTL, max uses | short TTL, low max uses |
| Trusted IPs | the signing runner VM |

Rules:

- Do not put a list or glob alternation (`{a,b}`) in `repository`: this was tested and does not work. Use one hardcoded repository per identity.
- Do not bind on `sub`: it uses the ID-based format (`repo:PoschLabs@<id>/<repo>@<id>:ref:...`).
- Do not use `*`: it also matches `/` and `:`. Use hardcoded values only.
- Do not pin `ref` or `workflow_ref`: both belong to the caller.
- `job_workflow_ref` is what makes only this repository's reviewed workflow able to obtain the key. It must match the tag callers use (ADR 0003).

## Onboarding a repository

1. Create a machine identity for the repository with the settings above (claim `repository` = that repository) and give it read access to the signing folder.
2. In the repository, define the Actions variable `SIGN_INFISICAL_IDENTITY_ID` with that identity's ID.
3. Share the three organisation variables `SIGN_INFISICAL_URL`, `SIGN_INFISICAL_PROJECT_ID` and `SIGN_INFISICAL_SECRET_PATH` (ADR 0002) with the repository.
4. Add the repository to the signing runner group's allowed repositories.
5. In the repository, call `sign.yml@v1` with `permissions: id-token: write`.

## Removing a repository

Delete the repository's machine identity (and remove its `SIGN_INFISICAL_IDENTITY_ID` variable and its runner group entry). It can no longer log in.

## Spike facts that this guide relies on

See `docs/spike-findings.md`, Step 4: login is `POST $INFISICAL_URL/api/v1/auth/oidc-auth/login` with `identityId` and `jwt`; a repository that does not match gets 401; `job_workflow_ref` has the form `<org>/sign-rpm-action/.github/workflows/sign.yml@refs/tags/<tag>`.
