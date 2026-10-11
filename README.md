# controller-nintendo-switch-translator
use any controller on the nintendo switch

A Raspberry Pi Pico reads a USB XInput controller (built for the Cosmic Byte
Ares) and presents it to a Nintendo Switch as a Pro Controller. The firmware is
[GP2040-CE](https://github.com/OpenStickCommunity/GP2040-CE) with a small patch
and a custom board config.

```
Ares (XInput mode) ──USB──► USB-A socket on GP0/GP1 ──► Pico ──► Pico's micro-USB ──► Switch
                            (Gamepad USB Host add-on)          (Switch Pro mode)
```

## Repository layout

| Path | What it is |
|------|------------|
| `GP2040-CE/` | Upstream firmware as a git submodule, pinned to a `main` commit (XInput host input is not in a tagged release yet). |
| `patches/` | Changes applied on top of upstream. |
| `configs/SwitchTranslator/` | Board config: USB host on GP0/GP1, host add-on on, Switch Pro output by default. |
| `scripts/build.sh` | Applies patches, installs the board config into the submodule, and builds the `.uf2`. |

### Patches

- `0001-xbox360host-accept-any-xinput-controller.patch`: upstream's XInput host
  only accepts Microsoft's own Xbox 360 pad (`045E:028E`). This accepts any
  device the XInput driver identifies as an Xbox 360-class controller, so
  third-party pads like the Ares work regardless of their VID/PID.

## Wiring

| USB-A socket | Pico pin |
|--------------|----------|
| VBUS (5V)    | VBUS (pin 40) |
| D+           | GP0 (pin 1) |
| D-           | GP1 (pin 2) |
| GND          | GND (pin 3) |

The Pico's own micro-USB port goes to the Switch dock or console. Put the Ares
in **XInput mode** (orange LED) before plugging it in.

## Building

```sh
git clone --recurse-submodules <this repo>
./scripts/build.sh
```

Needs `cmake`, `ninja` (or make), `arm-none-eabi-gcc`, `python3` and `node`/`npm`.
Set `SKIP_WEBBUILD=TRUE` to skip building the web configurator, and
`PICO_SDK_PATH` to reuse an existing pico-sdk 2.3.1 checkout. The firmware lands
in `build/GP2040-CE_<version>_SwitchTranslator.uf2`.

CI builds the same `.uf2` on every push. Download it from the workflow run's
artifacts.

## Flashing

Hold BOOTSEL on the Pico while plugging it into a computer, then copy the `.uf2`
onto the `RPI-RP2` drive.

## Usage notes

- On the Switch, enable *System Settings → Controllers and Sensors → Pro
  Controller Wired Communication*.
- **Web configurator:** a button from GP17 (S2) to GND, held while plugging in,
  boots it. Once running, holding Start + X + Y on the controller should also
  switch to it.
- **Fallback mode:** if a game misbehaves in Pro Controller mode, hold B1
  (Xbox A) while plugging in to use the classic HORI-style Switch mode.
- Button labels: GP2040-CE maps by position, so Xbox A becomes Switch B,
  and so on. Change this in the web configurator if you prefer to match labels.

## Updating GP2040-CE

```sh
git -C GP2040-CE fetch origin main && git -C GP2040-CE checkout <commit>
./scripts/apply-patches.sh   # fix up any patch that no longer applies
git add GP2040-CE patches
```
