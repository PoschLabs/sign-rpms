# sign-rpm-action
Securely sign and verify RPM packages in GitHub Actions using GPG signing keys stored in Infisical. Supports GitHub OIDC authentication, self-hosted runners, automated signature verification, and secure cleanup of sensitive key material. Designed for trusted release pipelines and Linux package distribution.

## Usage

A repository in the PoschLabs organisation calls the workflow after the job that builds its RPMs and uploads them as an artifact:

```yaml
jobs:
  sign:
    needs: build
    permissions:
      id-token: write
    uses: PoschLabs/sign-rpm-action/.github/workflows/sign.yml@v1
    with:
      artifact-name: unsigned-linux-packages
      # signed-artifact-name: signed-linux-packages   # default
    secrets:
      SIGN_INFISICAL_URL: ${{ secrets.SIGN_INFISICAL_URL }}
      SIGN_INFISICAL_IDENTITY_ID: ${{ secrets.SIGN_INFISICAL_IDENTITY_ID }}
      SIGN_INFISICAL_PROJECT_ID: ${{ secrets.SIGN_INFISICAL_PROJECT_ID }}
      SIGN_INFISICAL_SECRET_PATH: ${{ secrets.SIGN_INFISICAL_SECRET_PATH }}
```

The signed files are in the artifact `signed-linux-packages` (or the name given in `signed-artifact-name`). Callers must use the `v1` tag (ADR 0003).

### Secrets

The workflow reads the Infisical settings from secrets, so that they are masked in the logs of public repositories (ADR 0006). The caller passes them as in the example above. The workflow fails early, naming the secret, if one is empty.

| Secret | Level | Content |
|--------|-------|---------|
| `SIGN_INFISICAL_URL` | Organisation, shared with the repository | Address of the Infisical instance |
| `SIGN_INFISICAL_IDENTITY_ID` | Repository | ID of the repository's own machine identity |
| `SIGN_INFISICAL_PROJECT_ID` | Organisation, shared with the repository | Infisical project that holds the signing key |
| `SIGN_INFISICAL_SECRET_PATH` | Organisation, shared with the repository | Folder in that project with the three signing secrets |

## Setup

The environment the workflow needs is described in `docs/setup/`: the [signing runner](docs/setup/runner.md), the [Infisical identity](docs/setup/infisical.md) and the [signing key](docs/setup/signing-key.md). How to release a new version is in [docs/release.md](docs/release.md).

## How it works

`sign.yml` downloads the caller's artifact (nothing is checked out), signs each `*.rpm` file directly in the artifact's top directory with the signer tool, and uploads the signed files as a new artifact.

- Subdirectories are not searched. Non-RPM files and names that do not end in lowercase `.rpm` are ignored and not copied.
- The workflow fails and uploads nothing if there is no `*.rpm`, if an entry named `*.rpm` is a directory or symlink, if a file name contains a control character, or if the signer fails for any file.
- There is no limit on the number of RPMs.

## Testing

- CI lints the workflows (`actionlint`, `zizmor`) and the Dockerfile (`hadolint`), builds the image and runs a smoke test: `sign-rpms --help`, `gpg --version` and `rpmsign --version` under the job container options (ADR 0004).
- The end-to-end run is manual: call `sign.yml` from the hello-repo project on the signing runner and check the signed RPM, including the odd cases above.
- The signer's own behaviour is tested in its repository.

## Limitations

`sign.yml` has no approval gate: anyone who can push a release tag in an allowed repository can trigger signing.
