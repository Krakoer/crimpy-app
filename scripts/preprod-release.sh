#!/usr/bin/env bash
# Promote dev to main, the branch a production tag is cut from.
set -euo pipefail

cd "$(dirname "$0")/.."

assume_yes=false
if [ $# -gt 0 ]; then
    if [ "$1" = "-y" ] && [ $# -eq 1 ]; then
        assume_yes=true
    else
        echo "usage: $0 [-y]" >&2
        exit 1
    fi
fi

git fetch origin

if ! git rev-parse -q --verify origin/main >/dev/null; then
    echo "origin/main does not exist" >&2
    exit 1
fi

if git merge-base --is-ancestor origin/dev origin/main; then
    echo "origin/main already contains origin/dev, nothing to promote"
    exit 0
fi

if ! git merge-base --is-ancestor origin/main origin/dev; then
    echo "origin/main holds commits origin/dev does not, promote by hand" >&2
    exit 1
fi

echo "Promoting to main:"
git --no-pager log --oneline origin/main..origin/dev

if [ "$assume_yes" = false ]; then
    read -r -p "Push these to main? [y/N] " answer
    case $answer in
    y | Y) ;;
    *)
        echo "aborted" >&2
        exit 1
        ;;
    esac
fi

git push origin origin/dev:refs/heads/main

version=$(sed -n 's/^version: *//p' pubspec.yaml | head -n 1)
suggested="beta-v${version/+/-}"

echo
echo "main updated, the CI is running analyze and tests on it"
echo
echo "to hand testers a build, push a beta tag and let the CI build it:"
echo "  git tag -a $suggested -m $suggested && git push origin $suggested"
echo
echo "that builds the beta flavor obfuscated, uploads its symbols to Sentry and"
echo "publishes it as a prerelease. A local --debug build reports nothing to"
echo "Sentry and installs over the testers app, so do not hand one out."
