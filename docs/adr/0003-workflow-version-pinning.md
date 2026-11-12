# ADR 0003: Callers pin the workflow by the `v1` tag

Status: Accepted

## Context
Infisical and the runner group both pin the exact tag in the called workflow's reference, `PoschLabs/sign-rpm-action/.github/workflows/sign.yml@refs/tags/v1` (the `job_workflow_ref` claim and the runner group's allowed workflow). A caller that pins a commit SHA, or uses a branch, produces a different reference, and Infisical or the runner group rejects it.

## Decision
Callers use `uses: PoschLabs/sign-rpm-action/.github/workflows/sign.yml@v1`. The major tag `v1` moves with each release. A tag ruleset on this repository restricts creating, moving and deleting `v*` tags to admins. The image digest inside `sign.yml` changes only through reviewed pull requests.

## Consequences
- Whoever can move `v1` decides which code receives the signing key on the next run, so the tag ruleset and tight admin access are part of the security model. The runner group checks only the tag name.
- Releases reach callers automatically through the moving tag.
- Callers cannot pin a SHA or an exact `vX.Y.Z` tag unless that tag is added to the runner group and to Infisical's `job_workflow_ref`. A new major version (`v2`) needs the same additions.

## Alternatives considered
- Allow SHA pinning by matching `job_workflow_ref` loosely or using `job_workflow_sha`: more caller control, but it weakens the identity restriction. Not chosen.
