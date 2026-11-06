#!/bin/sh
# Bundles the library for haxelib and submits it.
#
#   ./release.sh      build hxmpp-<version>.zip and submit it
#   ./release.sh -n   only build the zip
#
# Only tracked files are bundled (no examples, tests or local files).
set -eu
cd "$(dirname "$0")"

version=$(sed -n 's/^[[:space:]]*"version":[[:space:]]*"\([^"]*\)".*/\1/p' haxelib.json)
zip="hxmpp-$version.zip"

if [ -n "$(git status --porcelain --untracked-files=no)" ]; then
  echo "uncommitted changes, commit or stash them first" >&2
  exit 1
fi

rm -f "$zip"
git ls-files src haxelib.json README.md LICENSE CHANGELOG.md | zip -q "$zip" -@
echo "$zip ($(unzip -l "$zip" | tail -1 | awk '{print $2}') files)"

if [ "${1:-}" = "-n" ]; then
  exit 0
fi
haxelib submit "$zip"
rm "$zip"
