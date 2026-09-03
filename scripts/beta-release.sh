#!/usr/bin/env bash
# Cut a beta release: bump the build number in the pubspec and tag it so the CI
# builds the signed beta APK and publishes it as a prerelease. The version is
# left alone, only the build number moves, so a month of beta builds off one
# version stays ordered and every tag is unique.
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

if [ -n "$(git status --porcelain)" ]; then
    echo "working tree is dirty, commit or stash first" >&2
    exit 1
fi

branch=$(git rev-parse --abbrev-ref HEAD)
if [ "$branch" != "dev" ]; then
    echo "beta releases are cut from dev, currently on $branch" >&2
    exit 1
fi

git fetch origin --tags

if [ "$(git rev-parse dev)" != "$(git rev-parse origin/dev)" ]; then
    echo "dev and origin/dev have diverged, pull or push first" >&2
    exit 1
fi

pubspec_version=$(sed -n 's/^version: *//p' pubspec.yaml | head -n 1)
current=${pubspec_version%%+*}
if [[ $pubspec_version == *+* ]]; then
    build=${pubspec_version#*+}
else
    build=0
fi

if ! [[ $current =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || ! [[ $build =~ ^[0-9]+$ ]]; then
    echo "cannot read a X.Y.Z+B version out of pubspec.yaml: $pubspec_version" >&2
    exit 1
fi

next_build=$((build + 1))
# The tag cannot carry the pubspec's + separator and stay readable in a URL, so
# the build number is joined with a dash.
tag="beta-v$current-$next_build"

if git rev-parse -q --verify "refs/tags/$tag" >/dev/null; then
    echo "$tag already exists" >&2
    echo "if an earlier run stopped after tagging, finish it with:" >&2
    echo "  git push origin dev && git push origin $tag" >&2
    exit 1
fi

previous=$(git tag --list 'beta-v*' --sort=-v:refname | head -n 1 || true)
if [ -n "$previous" ]; then
    echo "Releasing $tag, changes since $previous:"
    git --no-pager log --oneline "$previous..HEAD"
else
    echo "Releasing $tag, the first beta"
fi

if [ "$assume_yes" = false ]; then
    read -r -p "Bump pubspec to $current+$next_build, tag $tag and push? [y/N] " answer
    case $answer in
    y | Y) ;;
    *)
        echo "aborted" >&2
        exit 1
        ;;
    esac
fi

tmp=$(mktemp)
sed "s/^version: .*/version: $current+$next_build/" pubspec.yaml >"$tmp"
cat "$tmp" >pubspec.yaml
rm -f "$tmp"

git add pubspec.yaml
git commit -m "Beta release $tag"

# tag before pushing: a push that fails then leaves a state the guards above
# recognise on the next run, instead of a bump that happens twice
git tag -a "$tag" -m "$tag"
git push origin dev
git push origin "$tag"

echo
echo "$tag pushed, the CI is building the signed beta APK and the prerelease"
echo "dev is now ahead of main: run just promote again before a prod release"
