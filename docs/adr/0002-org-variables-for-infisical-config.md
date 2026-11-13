# ADR 0002: Non-secret Infisical settings as organisation variables

Status: Superseded
Superseded by: ADR 0006

## Context
The workflow needs the Infisical address and where the signing key lives. Variables defined on this repository are not visible to calling workflows, because the `vars` context belongs to the caller. GitHub environments are per repository. Hardcoding the values would publish the private hostname in a public repository.

## Decision
Store the non-secret Infisical settings that are the same for every repository as GitHub organisation-level Actions variables, shared with each authorised repository: `SIGN_INFISICAL_URL`, `SIGN_INFISICAL_PROJECT_ID`, `SIGN_INFISICAL_SECRET_PATH`. The workflow reads them through `vars` and fails early with a clear message if one is missing. The variable names are listed in the README.

Each repository has its own Infisical machine identity, whose `repository` claim names that single repository. The architect tested a list of repositories in one claim and Infisical does not accept it. `SIGN_INFISICAL_IDENTITY_ID` therefore differs per repository and is an Actions variable defined on each calling repository, not an organisation variable. Which repositories may sign is decided in Infisical: a repository can sign only if it has an identity.

## Consequences
- The private hostname stays out of the public source.
- Onboarding a repository means creating its identity in Infisical, defining `SIGN_INFISICAL_IDENTITY_ID` on the repository, and sharing the three organisation variables with it.
- A repository-level variable with the same name overrides the organisation one; this is how the identity ID works, and the setup guide covers it.

## Alternatives considered
- Hardcode the values in `sign.yml`: simplest, but publishes the hostname. Not chosen.
- Per-repository environments: every repository would define its own values. Not chosen.
