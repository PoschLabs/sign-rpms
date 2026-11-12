# ADR 0001: Reusable workflow plus digest-pinned signer image

Status: Accepted

## Context
Public PoschLabs repositories need their RPMs signed with keys held in a private Infisical instance. The signing logic, runner and container must be controlled by this repository, not by callers.

## Decision
`.github/workflows/sign.yml` is a reusable workflow. It runs on the signing runner group in the image `ghcr.io/poschlabs/rpm-signer`, referenced by `@sha256:` digest. It downloads the caller's artifact, signs each top-level `*.rpm` with the signer tool, and uploads the signed files as a new artifact.

Inputs: `artifact-name` (required) and `signed-artifact-name` (default `signed-linux-packages`). Callers grant `id-token: write` and pass no secrets.

## Consequences
- Callers cannot change the signing code, runner or Infisical target.
- Callers must be in the PoschLabs organisation, because a called workflow can only use the caller organisation's self-hosted runners.
- The workflow and image must be public, because public repositories cannot call a private workflow. Security must not depend on their secrecy.
- Signing does not attest that the contents of a package are safe.

## Alternatives considered
- Composite action: runs in the caller's job, so the caller controls the runner and neighbouring steps. Rejected.
- Private signing service (the key never leaves the private network): strongest, but new infrastructure. Deferred as a future hardening path.
