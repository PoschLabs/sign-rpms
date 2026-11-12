#!/usr/bin/env bash
# Smoke test for the signer image (requirements IMG-3, IMG-6, TST-2).
#
# Usage: image/smoke-test.sh <image>
#
# Runs the image with the same container options as sign.yml (WF-10) and
# checks that the signer and the tools it runs start, that the user is
# uid 1001 and that no setuid/setgid file exists.
set -euo pipefail

image="${1:?usage: smoke-test.sh <image>}"

options=(
  --rm
  --user 1001
  --cap-drop=ALL
  --security-opt=no-new-privileges
  --read-only
  --tmpfs /tmp
  '--tmpfs=/run/sign:mode=0700,uid=1001'
)

failures=0

# run_in_image <command...>: run a command inside the image.
run_in_image() {
  docker run "${options[@]}" "${image}" "$@"
}

# check <description> <command...>: pass if the command succeeds in the image.
check() {
  local description="$1"
  shift
  if run_in_image "$@" >/dev/null 2>&1; then
    echo "ok   - ${description}"
  else
    echo "FAIL - ${description}"
    failures=$((failures + 1))
  fi
}

# check_output <description> <expected> <command...>: pass if the command
# runs successfully and its stdout equals expected. A command that cannot run
# at all (no container, missing tool) is a failure, never an empty result.
check_output() {
  local description="$1" expected="$2" actual
  shift 2
  if ! actual="$(run_in_image "$@" 2>/dev/null)"; then
    echo "FAIL - ${description} (command failed)"
    failures=$((failures + 1))
  elif [ "${actual}" = "${expected}" ]; then
    echo "ok   - ${description}"
  else
    echo "FAIL - ${description} (expected '${expected}', got '${actual}')"
    failures=$((failures + 1))
  fi
}

check "sign-rpms --help runs" sign-rpms --help
check "gpg runs" gpg --version
check "gpgconf runs" gpgconf --version
check "rpm runs" rpm --version
check "rpmsign runs" rpmsign --version
check "a shell is present" sh -c 'true'

check "GPG compatibility symlink exists" sh -c 'test -L /usr/bin/gpg2 && test -x /usr/bin/gpg2'
check "GPG2 executable runs" /usr/bin/gpg2 --version

# Expansion is intentionally deferred to the shell inside the container.
# shellcheck disable=SC2016
check \
  "RPM-configured GPG executable runs" \
  sh -c '
    gpg_path="$(rpm --eval "%{__gpg}")"
    "$gpg_path" --version
  '

check_output "runs as uid 1001" 1001 id -u

# find exits non-zero on directories uid 1001 cannot read; that must not fail
# the check, so the exit status of find is ignored inside the container.
check_output "no setuid or setgid files" "" \
  sh -c 'find / -xdev -type f -perm /6000 2>/dev/null; true'

if [ "${failures}" -ne 0 ]; then
  echo "${failures} check(s) failed" >&2
  exit 1
fi
echo "all checks passed"
