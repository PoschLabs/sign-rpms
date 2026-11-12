# Phase 0 spike findings

Note: ADR numbers in this file refer to the earlier ADR set, which was reorganised on 2026-11-11 (current set: `docs/adr/README.md`; setup guides: `docs/setup/`).

Date: 2026-11-03. Source: `docs/spike-raw-logs.md` (job logs and shell transcripts from the runbook, `docs/spike-runbook.md`). Runner: `lysithea`, runner 2.338.2, Docker API 1.56, group `spike-signing`.

Legend: **Confirmed** = observed in the logs. **Inferred** = follows from the logs but was not directly tested. **Open** = not tested or not recorded.

## Summary of what changes

| # | Finding | Affects |
|---|---------|---------|
| 1 | Wildcards in `selected_workflows` refs are not usable. A ref must exist (tag, branch or full SHA). | ADR 0003, 0005, 0006; Tasks 9, 10, 12 |
| 2 | The runner group matches the **called** reusable workflow. A plain workflow in an allowed repo queues forever with no error. | ADR 0005 (assumption confirmed) |
| 3 | `environment:` in a called workflow resolves in the **caller's** repo. A missing environment is not an error (variable is empty). | ADR 0007 |
| 4 | The hardened container options work with `--user 1001`. | ADR 0008, Task 7 |
| 5 | The runner still bind-mounts `/var/run/docker.sock` into the job container, despite ADR 0008 saying it must not be mounted. **Confirmed not usable** by the job user (`srw-rw---- root:982`, job is `uid=1001 gid=0`). | ADR 0008, Task 9 |
| 6 | Workspace files written by the container (uid 1001) persist and block the next job; the host runner user could not remove them (needed `sudo`). | ADR 0005, Task 10 |
| 7 | A moved tag is picked up immediately: `v0.0.2` resolved to three different commits across runs. | ADR 0006 |
| 8 | Infisical endpoints, parameters and response fields are confirmed. `job_workflow_ref` is `...sign.yml@refs/tags/<tag>`. | Tasks 3, 9, 11 |
| 9 | Step 5 (Ed25519 on Rocky 9/Fedora) was not run. Decision: RSA-4096 is the default. | ADR 0004, Tasks 2, 7 |

## Step 1. Runner group restricted to selected workflows

| Question | Result |
|----------|--------|
| `selected_workflows` format | `PoschLabs/spike-signer/.github/workflows/sign.yml@refs/tags/v0.0.1`. **Confirmed** to work (reusable-workflow job ran). The setting is an array, so several entries should be possible (**Open**, not tested). |
| Reusable-workflow job on allowed group | **Confirmed** runs. The runner log shows `Uses: PoschLabs/spike-signer/.github/workflows/sign.yml@refs/tags/v0.0.1 (<sha>)`. |
| Plain workflow on allowed group | **Confirmed** rejected silently: the job stays queued ("waiting for an agent") and never runs. There is no error message. |
| `@refs/tags/v*` | Rejected: `Specified ref, tag, or SHA "refs/tags/v*" was not found for workflow ...` |
| `@refs/tags/*` | Rejected with the same "not found" error. |
| No ref | Rejected: `must be pinned to a ref, tag, or full SHA`. |
| v0.0.2 against exact v0.0.1 setting | **Open** (not recorded). Step 3 ran at `v0.0.2`, so the setting was evidently updated to it. |

Interpretation: the error text is a ref-existence check, so wildcard strings are treated as a literal ref name. Each allowed tag must be listed explicitly. The message says a full SHA is also accepted, but whether a SHA entry matches a job that was called by tag is **Open**.

## Step 2. `environment:` in a called workflow

| Question | Result |
|----------|--------|
| `vars.PROBE` from `spike-caller` | `caller-env`. **Confirmed**: the environment resolves in the caller's repo, not `spike-signer`. |
| From `spike-other` (no `spike-env`) | `PROBE=` (empty). **Confirmed**: the job ran; no error. It is **Open** whether GitHub created an empty `spike-env` in `spike-other` as a side effect; check that repo's Settings, Environments. |
| Required reviewer | **Open** (not run). |

## Step 3. Hardened job container and artifact actions

Working options (first run, no failures, no adjustments needed):

```
container:
  image: ubuntu:24.04
  options: >-
    --user 1001
    --cap-drop=ALL
    --security-opt=no-new-privileges
    --read-only
    --tmpfs /tmp
    --tmpfs /run/sign:mode=0700,uid=1001
    --volume /etc/spike-ca.pem:/etc/ssl/certs/spike-ca.pem:ro
```

- `id` inside the container: `uid=1001 gid=0(root) groups=0(root)`. Root fs is read-only, `/run/sign` tmpfs is writable. **Confirmed**.
- `actions/download-artifact@v8` and `actions/upload-artifact@v7` (SHAs `9000827...`, `cf430e0...`) worked, and the round trip matched ("spike-out File OK, matches content"). **Confirmed**. `--tmpfs /github/home` and `HOME` changes were not needed.
- Workspace: `/__w/spike-caller/spike-caller` is bind-mounted; files the job creates are owned by `1001:root`. `ls -ld $GITHUB_WORKSPACE` was not recorded (**Open**).
- CA bind mount: file is present and readable. The write attempt failed with `Permission denied`, which would also happen for any root-owned file under uid 1001, so the read-only (`:ro`) property is **not conclusively proven**. A `mount | grep spike-ca` or writing as root would settle it. Low risk because uid 1001 cannot write the file either way.

Problems found:

1. **Docker socket is mounted.** The `docker create` line the runner generates includes `-v /var/run/docker.sock:/var/run/docker.sock` (plus `_work`, `_temp`, `_actions`, `_tool`, `externals:ro`). `--cap-drop` and `no-new-privileges` do not remove it. Whether the job can use it depends on the socket's group on the host versus the container's groups (`gid=0` only here). **Confirmed not usable**: inside the container the socket is `srw-rw---- 1 0 982` (root, host `docker` group gid 982), the job is `uid=1001 gid=0 groups=0`, and `[ -w /var/run/docker.sock ]` is false ("OK: job user cannot write to the Docker socket"). This holds only while the host socket stays `root:docker` mode 0660 and the job user is not in gid 982. (An earlier attempt using `docker ps` was inconclusive because `ubuntu:24.04` has no Docker CLI.)
2. **Second run failed** with `mkdir: cannot create directory 'out': File exists`. The workspace is not cleaned between jobs when there is no checkout, and the leftover `out/` is owned by uid 1001, so it had to be removed with `sudo rm -rf` on the host. A third run then passed.

## Step 4. Infisical and OIDC claims

Decoded claims (from `spike-caller`, via `sign.yml@v0.0.3`, audience `spike-infisical`):

```
iss                https://token.actions.githubusercontent.com
aud                spike-infisical
sub                repo:PoschLabs@317321754/spike-caller@1443868501:ref:refs/heads/main
repository         PoschLabs/spike-caller
repository_owner   PoschLabs
ref                refs/heads/main
job_workflow_ref   PoschLabs/spike-signer/.github/workflows/sign.yml@refs/tags/v0.0.3
workflow_ref       PoschLabs/spike-caller/.github/workflows/call.yml@refs/heads/main
runner_environment self-hosted
```

- `job_workflow_ref` is the **called** workflow with the tag ref spelled out, so an Infisical match on it is straightforward.
- `ref` and `workflow_ref` belong to the **caller**. This run was from `main`, so the `ref=refs/tags/v*` binding in ADR 0003 was not exercised (**Open**).
- `sub` uses the immutable-ID format (`repo:<org>@<id>/<repo>@<id>:...`). Do not build identity matching on name-based `sub` patterns; use the `repository` claim as planned.
- Login: `POST $INFISICAL_URL/api/v1/auth/oidc-auth/login` with `identityId` and `jwt` form fields returned `200`; keys `accessToken`, `accessTokenMaxTTL`, `expiresIn`, `tokenType`. **Confirmed**.
- Secret read: `GET /api/v3/secrets/raw/SPIKE_SECRET?workspaceId=<project>&environment=prod&secretPath=/spike` with `Authorization: Bearer <accessToken>`. Value is at `.secret.secretValue`. Environment slug `prod`. **Confirmed**.
- Negative check from `spike-other`: login returned `401`. **Confirmed** (error body not recorded).
- Not recorded (**Open**): trailing-newline hash comparison (the printed value does not show whether the newline survived), exact `job_workflow_ref` matching in Infisical (expected to work like `repository`), wrong audience, path outside `/spike`, max uses, trusted IP.
- Note: login and read were run from a shell on `lysithea` (the runner VM) with a JWT, not inside the job. No trusted-IP list was set, so IP enforcement was not exercised.

## Step 5. Ed25519 RPM signatures

Not run. Decision (architect): RSA-4096 is the working default, so the Ed25519 gate is dropped for now. The related headless-passphrase signing check (item 5 of the runbook step) was also not run. That path (loopback pinentry with `--passphrase-file`) is covered by the unit tests in Tasks 4 to 6, which run on Ubuntu 24.04 and must pass before relying on it. The Rocky 9 and Fedora `rpm -K` check stays as a gate in Task 7, now with an RSA key.

## Other observations

- Tag `v0.0.2` resolved to `8cdf3c1...`, then `edc447e...`, then `77dd8e5...` in three consecutive runs, so a force-moved tag takes effect on the next run with no other control stopping it. The runner group only checks the tag *name*.
- Both `GITHUB_TOKEN` permission lists were minimal (`Metadata: read`, plus `Contents: read` in Step 3).

## Decisions after review (architect, 2026-11-03)

- The runner group lists `refs/tags/v1` (moving major tag); multiple tags per group are known to work.
- Infisical identities bind `repository`, `repository_owner` (verified) and `job_workflow_ref` as the exact `...sign.yml@refs/tags/v1`. `ref` is not pinned; `workflow_ref` is the caller's and is not used.
- Trailing-newline survival and Infisical's glob/list matching modes are no longer blocking; the Task 3 tests still check the newline.

## Open items worth closing (cheap)

1. Step 1: does a full-SHA `selected_workflows` entry match a job called by tag? (optional)
2. Step 3: `ls -ld $GITHUB_WORKSPACE`; `mount | grep spike-ca`.
3. Step 4: set a trusted-IP list to the runner VM and confirm in-job logins pass and others fail.
4. Step 2: check whether `spike-other` gained an empty `spike-env`.
