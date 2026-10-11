#!/usr/bin/env bash
# Build the Switch Translator firmware (.uf2) from the pinned GP2040-CE
# submodule plus this repo's patches and board config.
#
# Requirements: git, cmake, ninja or make, arm-none-eabi-gcc, python3,
# and node/npm (for the web configurator; set SKIP_WEBBUILD=TRUE to skip it).
# PICO_SDK_PATH may point at an existing pico-sdk 2.3.1 checkout; otherwise
# one is cloned into .deps/.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GP="$ROOT/GP2040-CE"
BOARD="${GP2040_BOARDCONFIG:-SwitchTranslator}"
PICO_SDK_VERSION="2.3.1"

git -C "$ROOT" submodule update --init --recursive GP2040-CE

"$ROOT/scripts/apply-patches.sh"

# Board configs must live inside the GP2040-CE tree for its CMake to find them.
rm -rf "$GP/configs/SwitchTranslator"
cp -r "$ROOT/configs/SwitchTranslator" "$GP/configs/SwitchTranslator"

if [[ -z "${PICO_SDK_PATH:-}" ]]; then
    PICO_SDK_PATH="$ROOT/.deps/pico-sdk"
    if [[ ! -d "$PICO_SDK_PATH" ]]; then
        git clone --depth 1 --branch "$PICO_SDK_VERSION" \
            https://github.com/raspberrypi/pico-sdk.git "$PICO_SDK_PATH"
        git -C "$PICO_SDK_PATH" submodule update --init --depth 1
    fi
fi
export PICO_SDK_PATH

GENERATOR=()
command -v ninja >/dev/null && GENERATOR=(-G Ninja)

GP2040_BOARDCONFIG="$BOARD" cmake -S "$GP" -B "$ROOT/build" "${GENERATOR[@]}" \
    -DCMAKE_BUILD_TYPE=Release
GP2040_BOARDCONFIG="$BOARD" cmake --build "$ROOT/build" --parallel

ls -1 "$ROOT"/build/GP2040-CE_*_"$BOARD".uf2
