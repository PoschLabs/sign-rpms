# Requirements

This repository provides a reusable GitHub Actions workflow that signs RPMs, and the container image the workflow runs in. Its only outputs are the image (`ghcr.io/poschlabs/rpm-signer`) and the workflow (called by tag, `@v1`). It publishes no source tarball, RPM, DEB or other release asset.

The signing application is a separate project, `PoschLabs/gha-infisical-rpm-signer` (the signer). Its behaviour, exit codes and tests belong to that project. Environment setup (runner, Infisical identity, signing key) is documented in `docs/setup/`.

Each requirement names the ADR that decides it and how it is checked: **lint** (CI linters), **smoke** (CI image build and smoke test), **manual** (end-to-end run from the hello-repo project) or **review** (pull-request review).

## Workflow

| ID | Requirement | ADR | Check |
|----|-------------|-----|-------|
| WF-1 | `.github/workflows/sign.yml` is a reusable workflow (`workflow_call`) with the inputs `artifact-name` (required) and `signed-artifact-name` (default `signed-linux-packages`), and the four secrets of WF-8. | 0001, 0006 | lint, manual |
| WF-2 | The job runs on the signing runner group, in the signer image referenced by `@sha256:` digest. | 0001 | lint |
| WF-3 | The workflow downloads the named artifact with `actions/download-artifact`. Nothing is checked out. | 0001 | manual |
| WF-4 | The workflow signs every `*.rpm` file directly in the artifact's top directory, one signer call per file, in one job, passing each file as `./<name>` and writing the result under the original name with the signer's `-o` option. There is no limit on the number of files. | 0001 | manual |
| WF-5 | The signed files are uploaded as one artifact named by `signed-artifact-name`. | 0001 | manual |
| WF-6 | The workflow fails with a clear message, and uploads nothing, if: there is no `*.rpm` in the top directory; an entry named `*.rpm` is a directory or symlink; a file name contains a control character (so a name cannot inject workflow commands into the log); or the signer fails for any file. | 0001 | manual |
| WF-7 | Subdirectories and their contents, non-RPM files and names that do not end in lowercase `.rpm` are ignored and not copied. | 0001 | manual |
| WF-8 | The workflow declares the secrets `SIGN_INFISICAL_URL`, `SIGN_INFISICAL_IDENTITY_ID`, `SIGN_INFISICAL_PROJECT_ID` and `SIGN_INFISICAL_SECRET_PATH` as required and fails early, naming the secret, if one is empty. The identity ID is a secret of the calling repository (one machine identity per repository); the other three are organisation secrets. | 0006 | lint, manual |
| WF-9 | The workflow passes the signer its settings only as environment variables: `INFISICAL_URL`, `INFISICAL_IDENTITY_ID`, `INFISICAL_PROJECT_ID`, `INFISICAL_SECRET_PATH`, `OIDC_AUDIENCE` (set from `SIGN_INFISICAL_URL`, as in the earlier workflow) and `SIGN_TMPDIR=/run/sign`. The four settings come from `secrets`. | 0004, 0006 | lint |
| WF-10 | The job container uses exactly these options: `--user 1001 --cap-drop=ALL --security-opt=no-new-privileges --read-only --tmpfs /tmp --tmpfs /run/sign:mode=0700,uid=1001`. | 0004 | lint |

## Security

| ID | Requirement | ADR | Check |
|----|-------------|-----|-------|
| SEC-1 | No secret is printed, logged, committed or passed as a command-line argument. The only credentials in the job are the runner's OIDC request variables, which the signer reads from the environment. The Infisical settings are secrets and are masked (ADR 0006). | 0001, 0006 | lint, review |
| SEC-2 | The workflow's `permissions` are `id-token: write` and nothing else. | 0001 | lint |
| SEC-3 | No workflow input selects the runner, image, signer arguments, Infisical target or OIDC audience. | 0001 | lint |
| SEC-4 | Every action is pinned by full commit SHA with the release tag in a comment. | AGENTS.md | lint |
| SEC-5 | TLS certificate verification is never disabled: not in the image build, the workflow or the signer's connection to Infisical. | 0005 | review |
| SEC-6 | The job user cannot write to `/var/run/docker.sock`. | 0004 | manual |
| SEC-7 | A tag ruleset on this repository restricts creating, moving and deleting `v*` tags to admins. Callers use `@v1`. | 0003 | review |
| SEC-8 | CI for this public repository runs only on GitHub-hosted runners, never on the signing runner group. | AGENTS.md | review |

## Image and build

| ID | Requirement | ADR | Check |
|----|-------------|-----|-------|
| IMG-1 | The image is built from Ubuntu 24.04 pinned by digest. `rpm` and `gnupg` are installed with apt from the Ubuntu archive. The build installs nothing else. | 0005 | review |
| IMG-2 | The signer binary comes from the `linux_amd64` release tarball of a pinned signer release tag. The tag and the tarball's sha256 are two variables, `SIGNER_VERSION` and `SIGNER_SHA256`, at the top of the build workflow. The build fails unless the tarball's sha256 and its GitHub build attestation verify against the signer repository. The check runs in the build workflow on a GitHub-hosted runner. | 0005 | review |
| IMG-3 | The binary is installed as `/usr/local/bin/sign-rpms`. The image runs as uid 1001, has no setuid or setgid files and contains no secrets. | 0005 | smoke |
| IMG-4 | The published image carries build provenance and an SBOM, is vulnerability-scanned, and is consumed by `sign.yml` by digest only. | 0001, 0005 | review |
| IMG-5 | Upgrading the signer or the base image digest is a reviewed pull request. | 0005 | review |
| IMG-6 | The image is glibc-based and has a shell. | 0004, 0005 | smoke |

## Testing

| ID | Requirement | ADR | Check |
|----|-------------|-----|-------|
| TST-1 | CI lints the workflows with `actionlint` and `zizmor`, the Dockerfile with `hadolint` and the smoke-test script with `shellcheck`. | — | lint |
| TST-2 | CI builds the image and runs `sign-rpms --help`, `gpg --version` and `rpmsign --version` inside it under the WF-10 container options. | 0004, 0005 | smoke |
| TST-3 | Before the `v1` tag moves to a new release, the architect runs `sign.yml` from the hello-repo project on the signing runner and checks the signed RPM, including the cases in WF-6 and WF-7 and SEC-6. The run also verifies one identity per repository (ADR 0006): a repository signs with its own identity ID and is refused with another repository's. | — | manual |

The signer's own behaviour (exit codes, cleanup, masking, the Infisical contract) is tested in the signer repository and is not repeated here.

## Documentation

| ID | Requirement |
|----|-------------|
| DOC-1 | The README describes how the workflow behaves (WF-4 to WF-7), how it is tested, its limitations, a caller example and the secrets from WF-8, including the caller's `secrets:` block. |
| DOC-2 | `docs/setup/` holds the setup guides for the runner, the Infisical identity (including onboarding and removing a repository) and the signing key. |
| DOC-3 | The release procedure is written down: bump the signer pin, build and publish the image, open the pull request that updates the digest in `sign.yml`, run TST-3, then move `v1`. |
