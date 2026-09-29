#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
IDENTITY="Tinycast Self-Signed"
APP="build/DerivedData/Build/Products/Release/Tinycast.app"

if ! security find-identity -p codesigning | grep -q "$IDENTITY"; then
    echo "✗ '$IDENTITY' code-signing identity not found (docs/signing.md §1)." >&2
    exit 1
fi

git checkout -q -- Tinycast.xcodeproj
if [ -n "$(git status --porcelain)" ]; then
    echo "✗ Uncommitted changes. Commit or discard them first." >&2
    exit 1
fi

git fetch -q upstream --tags
latest="$(git tag -l 'v*' --sort=-v:refname | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | head -1)"

if git merge-base --is-ancestor "$latest" HEAD; then
    echo "▸ Already on $latest"
    [ "${1:-}" = "--rebuild" ] || exit 0
else
    echo "▸ Merging $latest"
    if ! git merge -q --no-edit -m "Merge upstream $latest" "$latest"; then
        if [ -n "$(git diff --name-only --diff-filter=U)" ]; then
            echo "✗ Conflicts merging $latest. Resolve them, commit, then run with --rebuild." >&2
            exit 1
        fi
        git commit -q --no-edit
    fi
fi

xcodegen generate --quiet
mkdir -p build
./Scripts/fork-test.sh > build/fork-test.log 2>&1 || { cat build/fork-test.log; exit 1; }

echo "▸ Building"
xcodebuild -quiet -project Tinycast.xcodeproj -scheme Tinycast -configuration Release \
    -derivedDataPath build/DerivedData \
    CODE_SIGN_STYLE=Manual CODE_SIGN_IDENTITY="$IDENTITY" OTHER_CODE_SIGN_FLAGS="--timestamp=none" \
    build

echo "▸ Installing"
osascript -e 'quit app "Tinycast"' 2>/dev/null || true
for _ in $(seq 50); do pgrep -qx Tinycast || break; sleep 0.2; done
ditto "$APP" /Applications/Tinycast.app
open /Applications/Tinycast.app
if [ -d /Applications/Raycast.app ]; then swift Scripts/fork-keep-raycast-links.swift; fi

git checkout -q -- Tinycast.xcodeproj
git push -q origin HEAD:fork
echo "✓ Tinycast $latest with fork patches installed"
