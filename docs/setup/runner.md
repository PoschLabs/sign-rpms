# Signing runner setup

How to set up the self-hosted runner that runs `sign.yml`. This is environment setup, not a design decision of this repository.

## Why a dedicated, ephemeral runner

Public-repository workflows run on a private self-hosted runner, which GitHub does not recommend for public repositories, and Docker is not a strong security boundary. A runner user with Docker access is effectively root on the VM, and a persistent runner would let a compromise survive into later jobs. So the runner is dedicated and single-use.

## Setup

1. **VM.** A dedicated VM that holds no other secrets. A host firewall allows network access only to GitHub and Infisical.
2. **Runner.** Register it with `--ephemeral` and concurrency 1, in its own runner group (the group `sign.yml` names in `runs-on`). A small supervisor (systemd unit or script) re-registers the runner after every job.
3. **Cleanup after every job.** Wipe the runner's `_work` directory and prune Docker state. Files written by the job container belong to uid 1001 and block the next job, and the runner user cannot delete them, so the wipe must run as root or in a throwaway container that removes the contents.
4. **Runner group.** Allow public repositories, and restrict the group to the selected workflow `PoschLabs/sign-rpm-action/.github/workflows/sign.yml@refs/tags/v1`. GitHub accepts no wildcards in the ref and requires one. A group can list several tags, so a new major version (`v2`) needs a new entry.
5. **Docker socket.** The runner always bind-mounts `/var/run/docker.sock` into the job container. The job user must not be able to use it: keep the socket `root:docker` mode 0660 and keep the job user (uid 1001, gid 0) out of the `docker` group. Check that `[ -w /var/run/docker.sock ]` is false inside the job container.

## What the group restriction does and does not do

- It matches the **called** reusable workflow. A plain workflow in an allowed repository stays queued forever with no error message.
- It checks only the tag name. Moving the tag changes what runs on the next job (ADR 0003).
- Infisical's `job_workflow_ref` check applies regardless (`docs/setup/infisical.md`).

Spike evidence for these points: `docs/spike-findings.md`, Steps 1 and 3.
