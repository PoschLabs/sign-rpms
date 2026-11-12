# Signing key setup

How the signing key is prepared for `sign.yml`. This is environment setup, not a design decision of this repository. The signer reads the key from Infisical (see `docs/setup/infisical.md`).

## Key model

PoschLabs publishes one public key for its package repositories, so one organisation-wide key signs everything.

- Signing uses an **RSA-4096 signing subkey** with an expiry. The primary key is also RSA-4096 and certify-only.
- RSA with SHA-256 signatures is accepted by every rpm release on the target distributions (Rocky Linux 9, current Fedora), including older ones such as RHEL 8. Ed25519 is not used because older rpm releases do not verify it.
- The **primary key stays offline**: passphrase-protected backups on encrypted offline media in two separate places, plus an offline revocation certificate. A hardware token (YubiKey or Nitrokey) holding the primary key is preferred. The primary key is never stored in Infisical.

## Initial setup

1. Create the RSA-4096 primary key (certify only) and one RSA-4096 signing subkey with an expiry, on an offline machine.
2. Back up the primary key and create the revocation certificate. Store both offline.
3. Export only the subkey: `gpg --export-secret-subkeys`.
4. Store three secrets in the Infisical folder the identity can read:

   | Secret | Content |
   |--------|---------|
   | `GPG_PRIVATE_KEY` | the exported signing subkey |
   | `GPG_PASSPHRASE` | its passphrase |
   | `GPG_FINGERPRINT` | the fingerprint of the signing subkey |

5. Publish the public key where clients fetch it.

## Risk to know

Every repository allowed to sign can cause the shared subkey to be used, and a compromised job can expose it for the life of the job. Because the primary key is offline, the subkey can be revoked and replaced without changing the key clients trust.
