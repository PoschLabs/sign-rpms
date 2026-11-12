# Phase 0 spike runbook

Throwaway experiments that confirm the assumptions behind ADRs 0001 to 0009 before any product code is written. Work top to bottom. Paste what you observe into each **Result** block, then hand the file back so the findings can go into `docs/spike-findings.md` and the affected ADRs.

Rules for the whole spike:

- Use scratch repositories only. Never use a real signing key, a real repository, or the production Infisical project.
- Never paste a JWT, access token, private key or passphrase into this file. Claims (the decoded JWT payload) are fine.
- Delete the scratch repositories, identities and keys when finished (last section).

## Setup (once)

Scratch repositories in the PoschLabs org:

| Repo | Purpose |
|------|---------|
| `PoschLabs/spike-signer` | stands in for `sign-rpm-action`; holds the reusable workflow `sign.yml` and a tag `v0.0.1` |
| `PoschLabs/spike-caller` | stands in for a consuming repo; calls `spike-signer` |
| `PoschLabs/spike-other` | a second consumer, used for negative tests |

Make `spike-signer` readable by the other two (Settings, Actions, General, Access: "Accessible from repositories in the organization") if it is private.

Needed on this machine: `gh` (authenticated with admin on the org), `curl`, `jq`, `docker`.

Variables used below (set in your shell):

```bash
export ORG=PoschLabs
export INFISICAL_URL=https://<your-infisical-host>
```

---

## Step 1. Runner group restricted to selected workflows

**Question:** Does a runner group restricted to `sign.yml` at a tag pattern accept a job from the reusable workflow, and reject a plain workflow in an allowed repo? What exact string format does `selected_workflows` take, and are wildcards in the ref allowed?

1. Create the reusable workflow in `spike-signer` at `.github/workflows/sign.yml`:

   ```yaml
   name: sign
   on: workflow_call
   permissions: {}
   jobs:
     sign:
       runs-on: { group: spike-signing, labels: [rpm-signer] }
       steps:
         - run: echo "ran on $(hostname)"
   ```

   Commit, then tag `v0.0.1`.

2. Create the runner group and give it access to `spike-caller` and `spike-other` only. Move your test runner into it, with label `rpm-signer`:

   ```bash
   gh api -X POST orgs/$ORG/actions/runner-groups \
     -f name=spike-signing -f visibility=selected
   gh api orgs/$ORG/actions/runner-groups --jq '.runner_groups[] | {id,name}'
   ```

   Note the group id as `GID`. Add the two repos (get repo ids with `gh api repos/$ORG/spike-caller --jq .id`):

   ```bash
   gh api -X PUT orgs/$ORG/actions/runner-groups/$GID/repositories/<repo-id>
   ```

   Move the runner into the group in the UI (Settings, Actions, Runners) or re-register it with `--runnergroup spike-signing`.

3. Restrict the group to the workflow. Try the exact tag first:

   ```bash
   gh api -X PATCH orgs/$ORG/actions/runner-groups/$GID \
     -F restricted_to_workflows=true \
     -f 'selected_workflows[]=PoschLabs/spike-signer/.github/workflows/sign.yml@refs/tags/v0.0.1'
   ```

4. In `spike-caller`, add `.github/workflows/call.yml` (on `workflow_dispatch`) calling `PoschLabs/spike-signer/.github/workflows/sign.yml@v0.0.1`. Run it.
   - Expect: the job runs on your runner.

5. In `spike-caller`, add `.github/workflows/plain.yml` with a plain job using `runs-on: { group: spike-signing, labels: [rpm-signer] }`. Run it.
   - Expect: the job never starts or is rejected.

6. Try wildcard patterns, one at a time, re-running `call.yml` after each, and record which are accepted by the API and which actually match:

   - `...sign.yml@refs/tags/v*`
   - `...sign.yml@refs/tags/*`
   - `...sign.yml` (no ref)

7. Tag `v0.0.2` and run `call.yml` pinned to `@v0.0.2` against the exact-tag setting from item 3.
   - Expect: rejected, which shows whether a pattern is required for upgrades.

**Result:**

```
selected_workflows format accepted:
wildcard `refs/tags/v*` accepted by API? matches at runtime?
reusable-workflow job on allowed group:
plain workflow on allowed group:
v0.0.2 against exact v0.0.1 setting:
how a rejected job appears (queued forever / error message):
```

---

## Step 2. `environment:` in a called workflow

**Question:** When a job in the called workflow declares `environment: X`, is `X` resolved in the caller's repository? What happens when the caller has no such environment?

1. In `spike-caller`, create an environment `spike-env` with an environment variable `PROBE=caller-env`. Do not add protection rules.
2. In `spike-signer`, create an environment of the same name with `PROBE=signer-env`.
3. Change `sign.yml` to:

   ```yaml
   jobs:
     sign:
       runs-on: { group: spike-signing, labels: [rpm-signer] }
       environment: spike-env
       steps:
         - run: echo "PROBE=${{ vars.PROBE }}"
   ```

   Retag (`v0.0.3`), point the settings from Step 1 at it, and run `call.yml` from `spike-caller`.
4. Repeat from `spike-other`, which has no `spike-env`.
5. Add a required reviewer to `spike-env` in `spike-caller` and run again.

**Result:**

```
PROBE value seen from spike-caller:
behaviour from spike-other (no environment):
with required reviewer: approval prompt appears in which repo's run?
```

---

## Step 3. Hardened job container and the artifact actions

**Question:** Which `--user` value and options work with a read-only root filesystem and dropped capabilities, and do `download-artifact` and `upload-artifact` still work?

1. Use a throwaway image, for example `ubuntu:24.04`, for now (the real image does not exist yet). Change `sign.yml` to:

   ```yaml
   on:
     workflow_call:
   jobs:
     sign:
       runs-on: { group: spike-signing, labels: [rpm-signer] }
       container:
         image: ubuntu:24.04
         options: >-
           --user 1001
           --cap-drop=ALL
           --security-opt=no-new-privileges
           --read-only
           --tmpfs /tmp
           --tmpfs /run/sign:mode=0700,uid=1001
       steps:
         - run: id; touch /should-fail || echo "root fs read-only ok"; touch /run/sign/x && echo "tmpfs ok"
         - uses: actions/download-artifact@<pin-by-sha>
           with: { name: spike-in, path: in }
         - run: mkdir out && cp -r in/. out/ && ls -laR out
         - uses: actions/upload-artifact@<pin-by-sha>
           with: { name: spike-out, path: out }
   ```

   Pin both actions to commit SHAs (look up the SHAs of the latest release tags).

2. In `spike-caller`, make `call.yml` first upload an artifact `spike-in` (any file), then call the workflow with `needs`.
3. Run it. If it fails, adjust and record each failure and fix. Things to try in order: `--user 1001`, `--user 1001:1001`, `--user root` with `--cap-drop=ALL`; adding `--tmpfs /github/home`; changing `HOME`.
4. Download `spike-out` from the run page and confirm it matches what you uploaded.
5. Record how the CA file would be mounted: on the runner VM, create a dummy file `/etc/spike-ca.pem` and add `--volume /etc/spike-ca.pem:/etc/ssl/certs/spike-ca.pem:ro` to the options. Confirm it is visible in the container and read-only.

**Result:**

```
working combination of options (paste the options block):
failures hit and fixes:
workspace owner/permissions seen inside the container (ls -ld $GITHUB_WORKSPACE):
artifact round trip OK?:
CA bind mount works read-only?:
does the runner need Docker-in-job features that --read-only breaks? (list):
```

---

## Step 4. Infisical API and the real OIDC token claims

**Question:** What are the exact login endpoint, secret-read endpoint, environment slug and response fields on your instance, and what is the real `job_workflow_ref` claim for a reusable workflow?

1. In your Infisical instance, create a scratch project and a secret `SPIKE_SECRET` with a multi-line value (three lines, with a trailing newline) in environment `prod` at path `/spike`. Note the project id and the environment slug shown in the UI.
2. Create a machine identity `gh-spike-caller` with the OIDC auth method:
   - Issuer: `https://token.actions.githubusercontent.com`
   - Audience: `spike-infisical` (any dedicated string)
   - Subject: leave open for now
   - Claim bindings: add `repository=PoschLabs/spike-caller` and `repository_owner=PoschLabs`
   - Access token TTL short (for example 120 s), max uses low (for example 3)
   - Add the identity to the project with read access to `/spike` only.
   Record the identity id and what the UI offers for claim matching (exact only, glob, list).
3. Change `sign.yml` so the job does this and nothing else sensitive:

   ```yaml
   permissions: { id-token: write }
   steps:
     - name: Show claims only
       run: |
         set +x
         JWT=$(curl -sS -H "Authorization: Bearer $ACTIONS_ID_TOKEN_REQUEST_TOKEN" \
           "$ACTIONS_ID_TOKEN_REQUEST_URL&audience=spike-infisical" | jq -r .value)
         echo "$JWT" | cut -d. -f2 | tr '_-' '/+' | base64 -d 2>/dev/null | jq .
   ```

   If `curl` or `jq` are missing in the container, use a job without a container for this step only. The caller must grant `id-token: write` to the call.
4. Run it from `spike-caller`. Paste the decoded claims, including `iss`, `aud`, `sub`, `repository`, `ref`, `job_workflow_ref`, `workflow_ref`, `repository_owner`, `runner_environment`.
5. Next, on this machine, log in with a token obtained inside a job (for a manual test, add a step that writes the JWT to a masked file only for this experiment, or have the job do the calls). Preferred: have the job do the calls, printing only status codes and field names:

   ```bash
   curl -sS -o resp.json -w '%{http_code}\n' -X POST "$INFISICAL_URL/api/v1/auth/oidc-auth/login" \
     --data-urlencode "identityId=$IDENTITY_ID" --data-urlencode "jwt=$JWT"
   jq 'keys' resp.json
   ```

   Then read the secret with the returned token:

   ```bash
   curl -sS -H "Authorization: Bearer $(jq -r .accessToken resp.json)" \
     "$INFISICAL_URL/api/v3/secrets/raw/SPIKE_SECRET?workspaceId=$PROJECT_ID&environment=prod&secretPath=/spike" \
     | jq 'del(.secret.secretValue)'
   ```

   Record field names, in particular where the value lives (expected `.secret.secretValue`), and whether `secretPath` and `environment` are accepted as written.
6. Confirm the multi-line value and trailing newline survive: compare `jq -j .secret.secretValue` against the original with `sha256sum` inside the job (print only the hashes).
7. Negative checks (record the HTTP status and message each time):
   - change the audience in the Infisical identity
   - run from `spike-other` (wrong `repository`)
   - request the secret outside `/spike`
   - exceed max uses
   - call from an IP outside any trusted IP list you set (add one to the identity to test)

**Result:**

```
decoded claims (no JWT):
job_workflow_ref exact value:
login endpoint + status + response keys:
secret endpoint + parameter names that worked:
env slug:
value field:
trailing newline preserved?:
claim matching offered by Infisical (exact/glob/list) for job_workflow_ref and ref:
negative checks:
```

---

## Step 5. Ed25519 RPM signatures on Rocky 9 and Fedora

**Question:** Does an RPM signed with an Ed25519 subkey by Ubuntu 24.04's `rpmsign` verify on Rocky 9 and current Fedora?

1. Work in a scratch directory on this machine (not the repo):

   ```bash
   mkdir -p ~/spike5 && cd ~/spike5
   docker run --rm -it -v "$PWD:/w" -w /w ubuntu:24.04 bash
   ```

2. Inside the container:

   ```bash
   apt-get update && apt-get install -y rpm gnupg
   command -v rpmbuild rpmsign        # both must exist; if not, also install rpm-build
   export GNUPGHOME=/w/gnupg; mkdir -m700 "$GNUPGHOME"
   gpg --batch --passphrase '' --quick-gen-key 'Spike <spike@example.invalid>' ed25519 cert never
   FPR=$(gpg --list-keys --with-colons | awk -F: '/^fpr/{print $10; exit}')
   gpg --batch --passphrase '' --quick-add-key "$FPR" ed25519 sign never
   SUBFPR=$(gpg --list-keys --with-colons | awk -F: '/^sub/{s=1} s&&/^fpr/{print $10; exit}')
   gpg --export --armor > pub.asc

   cat > t.spec <<'EOF'
   Name: spike
   Version: 1
   Release: 1
   Summary: spike
   License: MIT
   BuildArch: noarch
   %description
   spike
   %files
   EOF
   rpmbuild -bb --define "_topdir /w/rb" t.spec
   cp rb/RPMS/noarch/spike-1-1.noarch.rpm .
   rpmsign --define "_gpg_name ${SUBFPR}!" --addsign spike-1-1.noarch.rpm
   rpm --version; gpg --version | head -1
   exit
   ```

   If the spec heredoc breaks because of indentation, write the spec file with a text editor instead.

3. On the host, verify in both targets:

   ```bash
   for img in rockylinux:9 fedora:latest; do
     echo "== $img"
     docker run --rm -v "$PWD:/w" "$img" bash -c \
       'rpm --version; rpm --import /w/pub.asc && rpm -Kv /w/spike-1-1.noarch.rpm'
   done
   ```

   Expect `digests signatures OK` and a line naming the key. Anything like `NOKEY`, `BAD` or `unsupported` is a failure.
4. If either fails, repeat with `rsa4096` for both the primary and the subkey (`--quick-gen-key ... rsa4096 cert never`, `--quick-add-key "$FPR" rsa4096 sign never`) and record whether that passes on both.
5. Also test with a passphrase-protected key (use `--passphrase 'test pass phrase!'` at key creation) and sign with `--define "__gpg_sign_cmd %{__gpg} gpg --batch --no-verbose --no-armor --pinentry-mode loopback --passphrase-file /w/pass.txt --no-secmem-warning -u '%{_gpg_name}' -sbo %{__signature_filename} %{__plaintext_filename}"`. Record whether it works without a TTY.

**Result:**

```
rpm / gpg versions in ubuntu:
Ed25519 on rockylinux:9 (paste rpm -Kv output):
Ed25519 on fedora:latest:
RSA-4096 fallback needed? passes on both?:
passphrase-file signing works headless?:
```

---

## Step 6. Hand back

1. Fill in every **Result** block.
2. Tell me when done. I will turn it into `docs/spike-findings.md`, propose amendments to ADRs 0004, 0005, 0007 and 0008 as needed, and update the plan's Tasks 3, 7, 9 and 10 for anything that changed.

## Cleanup

- Delete `spike-signer`, `spike-caller`, `spike-other`.
- Delete the runner group `spike-signing` and return the runner to its normal group.
- Delete the Infisical scratch project and the `gh-spike-caller` identity.
- Delete `~/spike5`.
