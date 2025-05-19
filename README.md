# power-gpuwatch: GPU-Aware power mode switcher

**power-gpuwatch** is a lightweight Bash script that tracks GPU usage in real time and switches power profiles accordingly. It helps reduce idle power consumption on Linux desktops by toggling between `performance` and `power-saver` modes based on GPU activity.

---

## 📦 Dependencies
- `bash`
- `powerprofilesctl` (from `power-profiles-daemon`)
- `notify-send` (via `libnotify`)
- `upsc` (part of the NUT UPS client)

Ensure the following packages are installed:
```bash
sudo pacman -S power-profiles-daemon libnotify nut
```

---

## Configuration Walkthrough
Edit the `power-gpuwatch.sh` file to adjust thresholds and timers:

```bash
GPU_USAGE_THRESHOLD=30        # % to trigger performance mode
GPU_IDLE_THRESHOLD=15         # % to trigger power-saver mode
START_TRIGGER_DURATION=30     # sustained high usage to start session (seconds)
END_TRIGGER_DURATION=120      # sustained idle usage to end session (seconds)
RATE_PER_KWH=0.11             # cost per kWh for tracking electricity cost
UPS_NAME="xxxxx"             # name of your UPS in NUT (use `upsc` to check)
```

---

## Sample Logs

Text log:
```
[2025-05-19 01:20:36] Started power-gpuwatch.sh with 15s startup delay.
[2025-05-19 01:22:41] Fallback: GPU idle for 120s. Power-saver mode enabled.
```

CSV log:
```
Start Time,End Time,Duration (hrs),Avg Watts,kWh,Cost
2025-05-19 14:01:32,2025-05-19 15:23:00,1.3583,154.35,0.2092,0.02
```

---

## Setting Up as a systemd User Service

### 1. Create the service file
Save to: `~/.config/systemd/user/power-gpuwatch.service`

```ini
[Unit]
Description=GPU Power Tracker (auto session logger)
After=graphical-session.target

[Service]
ExecStart=%h/.local/bin/power-gpuwatch.sh
Restart=always
RestartSec=10
Environment=DISPLAY=:0
Environment=XDG_RUNTIME_DIR=/run/user/%U

[Install]
WantedBy=default.target
```

### 2. Enable and start the service
```bash
systemctl --user daemon-reload
systemctl --user enable --now power-gpuwatch.service
```

### 3. View logs
```bash
journalctl --user -u power-gpuwatch.service -f
```

---

## GitHub
https://github.com/spslabo/power-gpuwatch

