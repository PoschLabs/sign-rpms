# ADR 0004: Run the signing job in a hardened job container

Status: Accepted

## Context
The signing job handles key material. The signer does not check where its scratch directory (`SIGN_TMPDIR`) lives, and overwriting files with zeros does not help on a disk filesystem, so the workflow is the only place that can guarantee a safe runtime.

## Decision
`sign.yml` runs the job in the signer image through `container:` with exactly these options, and sets `SIGN_TMPDIR=/run/sign`:

```
--user 1001 --cap-drop=ALL --security-opt=no-new-privileges --read-only
--tmpfs /tmp --tmpfs /run/sign:mode=0700,uid=1001
```

Callers cannot change these options. The image is glibc-based and has a shell, because the runner runs its own Node.js inside the job container for the artifact actions.

## Consequences
- The runner always mounts `/var/run/docker.sock` into the job container, whatever the options say. The job user must not be able to write to it; this is a runner setup requirement (`docs/setup/runner.md`).
- Fewer isolation controls than a plain `docker run`.

## Alternatives considered
- A host job that runs `docker run` with stricter flags: better control, but the artifact lands on the VM directly. Not chosen.
