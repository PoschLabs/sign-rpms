# Security policy

## Reporting
Report vulnerabilities privately through GitHub's "Report a vulnerability" (private security advisory) on this repository. Do not open a public issue. <!-- TODO(architect): add a contact address if advisories are not enabled. -->

## Scope
In scope: the reusable workflow `sign.yml`, the `rpm-signer` image and the `sign-rpms` script, and the documented runner and Infisical configuration.
Out of scope: the contents of artifacts that callers submit for signing. Signing does not attest that a package is safe.

## Known limitation
The signing subkey is imported into a CI job to sign packages. A compromise of the job, the runner or an authorised caller repository can expose that subkey for the life of the job. Mitigations: offline primary key (the subkey can be revoked and replaced), ephemeral single-job runner, hardened job container, per-repository Infisical identities, short token lifetimes. See `docs/adr/`.
