# Releasing

This repository releases two things: the signer image (`ghcr.io/poschlabs/rpm-signer`) and the workflow, which callers use through the moving tag `v1` (ADR 0003). The workflow runs the image by digest, so a new image reaches callers only when `sign.yml` is updated and `v1` is moved.

## 1. Update the signer (only when upgrading it)

Change `SIGNER_VERSION` and `SIGNER_SHA256` together at the top of `.github/workflows/build-image.yml` in a pull request. Take the checksum from the signer release (`checksums.txt`). The pull request builds the image, smoke-tests it and scans it. The build also fails unless the checksum and the signer's build attestation verify.

## 2. Publish the image

1. After the change is on `main`, run **Build image** from the Actions tab on `main`.
2. When it succeeds, copy the digest from the job summary (`ghcr.io/poschlabs/rpm-signer@sha256:...`).
3. The first time only: set the `rpm-signer` package to public in the package settings (ADR 0001). Otherwise the runner cannot pull it.

## 3. Update the workflow

Open a pull request that sets that digest as `container.image` in `.github/workflows/sign.yml`. Lint must pass. Review it as the change that decides which code receives the signing key.

## 4. Test, then move `v1`

1. Create a pre-release tag (for example `v0.1.0`) on the merged commit. The runner group and the Infisical `job_workflow_ref` accept exact tags only, so add that tag temporarily to both (`docs/setup/runner.md`, `docs/setup/infisical.md`).
2. From the hello-repo project, call `sign.yml` at that tag with: one RPM, several RPMs, an artifact without an RPM, a directory and a symlink named `*.rpm`, a non-RPM file, a subdirectory, a file name starting with `-`, a file name with a control character and a file that is not an RPM. Check that the signed RPMs verify, that each failure case fails without uploading anything, and that a repository that is not in the Infisical claim is refused.
3. If everything passes, move `v1` to the tested commit, remove the temporary tag entries and call `@v1` from hello-repo once more. Only admins can move `v*` tags (tag ruleset).
