# Signer image (ADR 0005). The build context is the image/ directory; the build
# workflow places the verified signer binary there as `sign-rpms` (sha256 and
# build attestation are checked before the build, not in this file).
FROM ubuntu:24.04@sha256:fe81560990fae86dc4743202b2cb4d3df98d0bcf949173cecef15ce1127ef852

# Package versions come from the Ubuntu archive at build time; apt verifies the
# package signatures. The image is pinned by digest where it is used (ADR 0001).
# The upgrade applies security updates published after the pinned base image,
# so the image does not carry vulnerabilities that already have a fix.
# hadolint ignore=DL3005,DL3008
RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends rpm gnupg; \
    rm -rf /var/lib/apt/lists/*; \
    useradd --uid 1001 --user-group --no-create-home --home-dir /nonexistent --shell /usr/sbin/nologin signer; \
    find / -xdev -type f -perm /6000 -exec chmod a-s {} +
RUN ln -s /usr/bin/gpg /usr/bin/gpg2

COPY --chmod=0755 sign-rpms /usr/local/bin/sign-rpms

USER 1001
