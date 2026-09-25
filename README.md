# backpack-lid

One-shot **lid-awake / backpack** mode for Hyprland laptops.

Explicitly arm → close lid → displays blank, sleep inhibited → open lid → auto-disarm.  
Next time you must arm again.

## Install

```bash
./install.sh
# ensures ~/.local/bin/backpack-lid is on PATH
```

Needs: `bash`, `systemd-inhibit`, optional `hyprctl` (DPMS).

## CLI

```bash
backpack-lid arm      # wait for one lid-close session
backpack-lid disarm   # cancel / restore
backpack-lid status   # human + JSON line
backpack-lid toggle
```

State lives in `$XDG_RUNTIME_DIR/backpack-lid/` (transient).

## Safety

- Machine stays awake in a bag: watch heat and battery.
- Does not permanently change logind config.
- Closing the lid **without** arm uses normal system lid behavior.

## Framed

Wire a Quickshell menu button to `backpack-lid toggle` / `arm` (separate from this repo).
