#!/usr/bin/env bash
# Apply patches/*.patch to the GP2040-CE submodule. Safe to re-run: patches
# that are already applied are skipped.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GP="$ROOT/GP2040-CE"

for patch in "$ROOT"/patches/*.patch; do
    name="$(basename "$patch")"
    if git -C "$GP" apply --reverse --check "$patch" 2>/dev/null; then
        echo "already applied: $name"
    else
        git -C "$GP" apply "$patch"
        echo "applied: $name"
    fi
done
