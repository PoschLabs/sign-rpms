# ADR 0005: Signer image

Status: Accepted

## Context
The signing job runs in a container image built from this repository. The signing application is a separate project, `PoschLabs/gha-infisical-rpm-signer` (the signer), which publishes release binaries with build attestations. The signer runs `gpg`, `gpgconf`, `rpmsign` and `rpm`.

## Decision
- Base: Ubuntu 24.04 pinned by digest. Install `rpm` and `gnupg` from the Ubuntu archive with apt, which verifies package signatures. The build installs nothing else and applies the archive's pending updates (`apt-get upgrade`), so the image does not carry vulnerabilities that already have a fix in Ubuntu's update pocket.
- Signer: the build takes the signer's `linux_amd64` release tarball for a pinned release tag, and fails unless its sha256 and its GitHub build attestation verify against the signer repository. The verified `sign-rpms` binary is installed at `/usr/local/bin/sign-rpms`. This runs in the build workflow on a GitHub-hosted runner, not inside the Dockerfile.
- Runtime: user uid 1001, setuid and setgid bits removed, no secrets in the image.
- TLS certificate verification is never disabled, in the build or at runtime.
- Publishing: the image goes to `ghcr.io/poschlabs/rpm-signer` with build provenance, an SBOM and a vulnerability scan, and is consumed by digest (ADR 0001).
- Upgrading the signer or the base image digest is a reviewed pull request.

## Consequences
- The image has no logic of ours: signing behaviour is entirely the signer's.
- The build depends on the signer's releases and attestations.
- Rebuilding can pull newer apt packages; the digest identifies exactly what ran.

## Alternatives considered
- Alpine or distroless: the job container must be glibc-based with a shell (ADR 0004).
- A dated apt snapshot: pinned rebuilds, but it forced TLS verification off during the build and needs date bumps. Not needed, since the image is pinned by digest.
- Installing `ca-certificates`: not needed for the signer or the artifact actions.
- Building the signer from source in the Dockerfile: duplicates the signer's CI and toolchain. Not chosen.
- Signing the image with cosign: not chosen; the digest pin and build provenance are enough, since `sign.yml` is the only consumer.
