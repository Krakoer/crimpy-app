#!/usr/bin/env bash
# Runs a command without the repository variables git exports to its hooks.
# In a worktree, git points GIT_DIR at this repository. The Flutter SDK runs git
# in its own checkout to find its version, so it would read this repository's
# history instead, take itself for version 0.0.0-unknown, and rewrite the
# version cache every other project on the machine shares.
set -euo pipefail
# shellcheck disable=SC2046
unset $(git rev-parse --local-env-vars)
exec "$@"
