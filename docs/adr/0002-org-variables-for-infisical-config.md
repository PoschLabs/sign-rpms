# ADR 0002: Non-secret Infisical settings as organisation variables

Status: Accepted. Contains one unverified assumption, see Decision.

## Context
The workflow needs the Infisical address and where the signing key lives. Variables defined on this repository are not visible to calling workflows, because the `vars` context belongs to the caller. GitHub environments are per repository. Hardcoding the values would publish the private hostname in a public repository.

## Decision
Store the non-secret Infisical settings as GitHub organisation-level Actions variables, shared with each authorised repository. The workflow reads them through `vars` and fails early with a clear message if one is missing. The variable names are listed in the README.

One Infisical machine identity serves the whole organisation, so its ID is one of these variables. Which repositories may sign is decided in Infisical: the identity's `repository` claim lists the allowed repositories.

**Unverified:** that Infisical accepts a list of values in one claim (for example glob alternation `PoschLabs/{repo-a,repo-b}`). The documentation shows glob alternation but the spike only tested a single value. If a list does not work, this ADR changes to one identity per repository with a repository-to-identity lookup, and the lookup becomes a second variable.

## Consequences
- The private hostname stays out of the public source.
- Onboarding a repository means sharing the variables with it and adding it to the identity's claim.
- A repository-level variable with the same name overrides the organisation one; this is covered in the setup guide.

## Alternatives considered
- Hardcode the values in `sign.yml`: simplest, but publishes the hostname. Not chosen.
- Per-repository environments: every repository would define its own values. Not chosen.
