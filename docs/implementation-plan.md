# Implementation plan

Implements `docs/requirements.md` under ADRs 0001 to 0005. Work test first (`AGENTS.md`): each task starts with the check that fails, then the code that makes it pass. Requirement IDs show what each task satisfies.

Rules that apply to every task:
- Pin every GitHub Action by full commit SHA with the release tag in a comment (SEC-4). Resolve the SHA when writing the file (`git ls-remote https://github.com/<owner>/<repo> 'refs/tags/<tag>*'`, use the peeled `^{}` commit for annotated tags). Never copy a SHA from memory.
- No secrets in files, logs or arguments (SEC-1). TLS verification is never disabled (SEC-5).
- CI for this repository runs only on GitHub-hosted runners (SEC-8).

## Order

1. Lint workflow
2. Image and its smoke test
3. Build and publish workflow
4. `sign.yml`
5. Documentation
6. Repository and organisation settings (manual)
7. End-to-end run and release

Tasks 1 to 3 use only GitHub-hosted runners and can be reviewed in pull requests. Task 4 needs the image digest from the first publish in task 3.

## 1. Lint workflow (TST-1, SEC-4)

- Add `.github/workflows/ci.yml`: on `pull_request` and `push`, `permissions: contents: read`, a job on `ubuntu-latest` running `actionlint`, `zizmor` and `hadolint`, each pinned (action by SHA, or the tool binary downloaded with a pinned version and checked sha256).
- Test first: open the PR with the workflow but without the other files; it must pass on an empty set, then fail when a deliberately unpinned action is added in a scratch commit. Remove the scratch commit.
- Done when: all three linters run and a bad workflow fails the job.

## 2. Image and smoke test (IMG-1, IMG-3, IMG-6, TST-2)

- Test first: write `image/smoke-test.sh`. It takes an image name and, under the WF-10 container options, runs `sign-rpms --help`, `gpg --version`, `rpmsign --version`, checks `id -u` is 1001, that no setuid or setgid file exists (`find / -xdev -perm /6000`). It fails while no image exists.
- Write `image/Dockerfile`:
  - `FROM ubuntu:24.04@sha256:<current digest>` (look the digest up, do not reuse the old one).
  - `apt-get install -y --no-install-recommends rpm gnupg`, then remove apt lists. No TLS options changed.
  - `COPY` the verified tarball contents (`sign-rpms` only) to `/usr/local/bin/sign-rpms`, mode 0755.
  - Create user `signer` uid 1001, strip setuid and setgid bits, `USER signer`, `ENV SIGN_TMPDIR=/run/sign`.
- Done when: `image/smoke-test.sh <image>` passes and `hadolint` is clean.

## 3. Build and publish workflow (IMG-2, IMG-4, IMG-5) — done

- `.github/workflows/build-image.yml` has `SIGNER_VERSION` and `SIGNER_SHA256` at the top (IMG-2).
- `.github/actions/fetch-signer/action.yml` (local composite action, used by both jobs) downloads the signer release over HTTPS, checks the sha256, runs `gh attestation verify` (repository, signer workflow `release.yml` and source ref `refs/tags/<version>`) and installs `sign-rpms` into `image/`. It fails on any mismatch.
- Job `test` (all events, `contents: read`): fetch signer, build with Buildx and load, run `image/smoke-test.sh`, scan with Grype (`anchore/scan-action`, fail on high or critical findings that have a fix).
- Job `publish` (only `workflow_dispatch`, after `test`, `packages: write`): log in to ghcr.io, build and push `ghcr.io/poschlabs/rpm-signer:<commit sha>` with BuildKit provenance (`mode=max`) and an SBOM, then smoke-test and scan the pushed digest and print it in the job summary.

Deviations from the first draft of this plan (rulings):
- Publishing is by manual dispatch only, not by version tag: a `v*` tag push would also fire for the caller-facing tags (`v1`).
- Provenance and the SBOM are BuildKit attestations stored with the image, so the publish job needs only `packages: write`, not `id-token` or `attestations`.
- The scanner is Grype, not Trivy (my choice).
- The local composite action is referenced as `./.github/actions/fetch-signer` with an inline zizmor ignore. The self-repository form `$/...` (zizmor suggests it) is not used until confirmed generally available.
- After the first publish the package must be made public in the GitHub package settings (ADR 0001: the image is public), or the runner cannot pull it.

Checked locally: both linters are clean; the fetch script ran against the real v0.1.0 release (good checksum installs a working binary, wrong checksum fails and installs nothing; attestation verified offline from a downloaded bundle, and fails for the wrong repository or a changed file). Not checked: the Docker steps, the smoke test on the real image, the scan and the push, none of which can run here. The first CI run is their test.

## 4. `sign.yml` (WF-1 to WF-10, SEC-1 to SEC-3, SEC-6) — written; the image digest is still a placeholder

- Test first: the linters from task 1 are the check. Add the file and make `actionlint` and `zizmor` pass, including shellcheck on the `run:` steps.
- Write `.github/workflows/sign.yml`:
  - `on: workflow_call` with `artifact-name` (required) and `signed-artifact-name` (default `signed-linux-packages`); top-level `permissions: id-token: write` only.
  - `runs-on: group: signing, labels: [rpm-signer]`; `container.image` is the digest from task 3; `container.options` exactly as in WF-10.
  - `defaults.run.shell: bash`. `env` carries the four `SIGN_*` org variables as `INFISICAL_*`, `OIDC_AUDIENCE` from `SIGN_INFISICAL_URL`, `SIGN_TMPDIR=/run/sign`, and per-run `IN_DIR` and `OUT_DIR` under `runner.temp` (include `run_id` and `run_attempt`).
  - Step 1, check variables: fail with the variable name if one is empty (WF-8).
  - Step 2, `actions/download-artifact` into `IN_DIR` (WF-3).
  - Step 3, sign: iterate over entries directly under `IN_DIR` (`find "$IN_DIR" -mindepth 1 -maxdepth 1 -name '*.rpm' -print0`), fail if an entry is not a regular file or is a symlink, fail if there are none, then for each: `sign-rpms -o "$OUT_DIR/$name" "./$name"` run from `IN_DIR` (WF-4, WF-6, WF-7). Any non-zero exit stops the step.
  - Step 4, `actions/upload-artifact` of `OUT_DIR` with `if-no-files-found: error` (WF-5). Because step 3 fails first, nothing is uploaded on failure.
  - Also reject file names with a control character (a name could otherwise inject workflow commands into the log through the signer's own output).
  - Step 5, check the Docker socket is not writable (`[ -w /var/run/docker.sock ]` must be false) and fail otherwise (SEC-6). Put it before the signing step.
- Done when: both linters pass and the file matches WF-1 to WF-10.

## 5. Documentation (DOC-1, DOC-3) — done

- README: add the organisation variable names (WF-8) and a caller example (`uses: PoschLabs/sign-rpm-action/.github/workflows/sign.yml@v1`, `permissions: id-token: write`, `with: artifact-name: ...`).
- Add `docs/release.md` with the procedure of DOC-3: bump `SIGNER_VERSION` and `SIGNER_SHA256`, run the build workflow, open the pull request that updates the digest in `sign.yml`, run the manual test (task 7), then move the `v1` tag.
- Done when: a reader can onboard a repository and cut a release from the docs alone.

## 6. Repository and organisation settings (manual, SEC-7, WF-8)

Not code. Follow `docs/setup/`: organisation variables shared with the repositories, the runner group restricted to `sign.yml@refs/tags/v1`, the Infisical identity and its claims, the signing key secrets, and the tag ruleset for `v*` tags on this repository (SEC-7). Record that each is done in the pull request that releases `v1`.

## 7. End-to-end run and release (TST-3)

1. Publish the image (task 3) and set its digest in `sign.yml` (task 4) in a pull request; merge after lint and smoke pass.
2. Tag a pre-release (for example `v0.1.0`) and add it to the runner group and the Infisical `job_workflow_ref` as exact tags, as a temporary entry.
3. From the hello-repo project call that tag with: one RPM, several RPMs, an artifact with no RPM, a directory and a symlink named `*.rpm`, a non-RPM file, a subdirectory, a file name starting with `-`, and a failing signer call (for example a file that is not an RPM). Verify the signed RPMs, and that a repository not in the Infisical list is refused.
4. If all pass, create `v1`, remove the temporary tag entries and call `@v1` from hello-repo once more.

## Risks to watch

- The Infisical claim list is untested (ADR 0002); step 7.3 is its first test. If it fails, ADR 0002 and WF-8 change before `v1`.
- The signer v0.1.0 tarball's contents were checked (`sign-rpms`, `LICENSE`, `README.md`), but the attestation verification command has not been run against it yet; task 3 will show whether the attestation matches the tarball.
- Workspace files written by the container (uid 1001) can block the next job; the runner cleanup in `docs/setup/runner.md` must be in place before step 7.3.
