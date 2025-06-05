#!/bin/bash

# power-gpuwatch.sh - GPU-aware power management for Linux desktops
# GitHub: https://github.com/spslabo/power-gpuwatch
# Author: spslabo

# --- Configurable Settings ---
UPS_NAME="cpsups"
UPS_LOAD_CMD="upsc $UPS_NAME ups.load"
UPS_RPOWER_CMD="upsc $UPS_NAME ups.realpower.nominal"
GPU_BUSY_FILE="/sys/class/drm/card1/device/gpu_busy_percent"
RATE_PER_KWH=0.11
LOG_DIR="$HOME/.local/share/power-gpuwatch"
CSV_LOG="$LOG_DIR/power-gpuwatch-sessions.csv"
TXT_LOG="$LOG_DIR/power-gpuwatch.log"
GPU_USAGE_THRESHOLD=30      # % load to trigger performance mode
GPU_IDLE_THRESHOLD=15       # % load to trigger power-saver mode after timeout
START_TRIGGER_DURATION=30   # seconds of sustained high GPU usage
END_TRIGGER_DURATION=120    # seconds of sustained low GPU usage
POLL_INTERVAL=10
STARTUP_DELAY=15            # seconds before first check

# --- Setup ---
mkdir -p "$LOG_DIR"

# Verify required commands are available
missing=false
for cmd in bc upsc powerprofilesctl notify-send; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Error: required command '$cmd' not found." >&2
        missing=true
    fi
done
if $missing; then
    exit 1
fi

# --- Utility Functions ---
now() { date '+%Y-%m-%d %H:%M:%S'; }
now_unix() { date +%s; }
get_gpu_busy() {
    value=$(cat "$GPU_BUSY_FILE" 2>/dev/null)
    if [[ ! "$value" =~ ^[0-9]+$ ]]; then
        # Only warn once until a valid reading is seen again
        if ! $invalid_gpu_warning_logged; then
            log "Warning: Invalid or missing GPU usage reading."
            invalid_gpu_warning_logged=true
        fi
        echo 0
    else
        invalid_gpu_warning_logged=false
        echo "$value"
    fi
}
get_watts() {
    load=$(eval "$UPS_LOAD_CMD" 2>/dev/null)
    nominal=$(eval "$UPS_RPOWER_CMD" 2>/dev/null)

    if [[ -z "$load" || -z "$nominal" || "$load" == "NULL" || "$nominal" == "NULL" ]]; then
        log "Error: Unable to read UPS power data. Skipping this sample."
        echo ""
        return
    fi

    echo "scale=2; $nominal * $load / 100" | bc
}
log() {
    echo "[$(now)] $1" >> "$TXT_LOG"
    [[ "$1" =~ ^(Warning|Error) ]] && logger -t power-gpuwatch "$1"
}
notify() {
    notify-send "Power GPUWatch" "$1"
}

# Verify that required commands are functional
check_dependencies_running() {
    # Verify notify-send first so we can send alerts for other failures
    if ! notify-send --version >/dev/null 2>&1; then
        log "Error: 'notify-send' command failed to run."
        logger -t power-gpuwatch "notify-send command not functional"
        exit 1
    fi

    if ! echo 1 | bc >/dev/null 2>&1; then
        log "Error: 'bc' command failed to execute."
        notify "power-gpuwatch: 'bc' failed. Exiting."
        exit 1
    fi

    if ! eval "$UPS_LOAD_CMD" >/dev/null 2>&1; then
        log "Error: Unable to communicate with UPS using upsc."
        notify "power-gpuwatch: UPS unreachable. Exiting."
        exit 1
    fi

    if ! powerprofilesctl get >/dev/null 2>&1; then
        log "Error: 'powerprofilesctl' command failed."
        notify "power-gpuwatch: powerprofilesctl failure. Exiting."
        exit 1
    fi
}

# --- Initialize ---
check_dependencies_running
logger -t power-gpuwatch "Started power-gpuwatch.sh with ${STARTUP_DELAY}s startup delay."
log "Started power-gpuwatch.sh with ${STARTUP_DELAY}s startup delay."
sleep $STARTUP_DELAY
session_active=false
high_gpu_counter=0
idle_gpu_counter=0
invalid_gpu_warning_logged=false
last_power_mode=""

while true; do
    gpu_busy=$(get_gpu_busy)
    # Check for performance trigger
    if ! $session_active && (( gpu_busy > GPU_USAGE_THRESHOLD )); then
        high_gpu_counter=$((high_gpu_counter + POLL_INTERVAL))
    else
        high_gpu_counter=0
    fi

    # Track idle time for both session and non-session states
    if (( gpu_busy < GPU_IDLE_THRESHOLD )); then
        idle_gpu_counter=$((idle_gpu_counter + POLL_INTERVAL))
    else
        idle_gpu_counter=0
    fi

    # --- Start session ---
    if ! $session_active && (( high_gpu_counter >= START_TRIGGER_DURATION )); then
        session_active=true
        session_start_time=$(now_unix)
        session_start_stamp=$(now)
        session_start_watts=$(get_watts)
        powerprofilesctl set performance
        last_power_mode="performance"
        notify "GPU session started. Performance mode enabled."
        log "Session started: GPU usage above threshold (${GPU_USAGE_THRESHOLD}%)."
    fi

    # --- End session ---
    if $session_active && (( idle_gpu_counter >= END_TRIGGER_DURATION )); then
        session_active=false
        session_end_time=$(now_unix)
        session_end_stamp=$(now)
        session_end_watts=$(get_watts)

        if [[ -z "$session_start_watts" || -z "$session_end_watts" ]]; then
            log "Warning: Skipping session logging due to missing wattage readings."
            powerprofilesctl set power-saver
            notify "GPU session ended. Power-saver mode. (UPS data unavailable)"
            last_power_mode="power-saver"
            continue
        fi

        duration=$(echo "scale=4; ($session_end_time - $session_start_time) / 3600" | bc)
        avg_watts=$(echo "scale=2; ($session_start_watts + $session_end_watts) / 2" | bc)
        kwh=$(echo "scale=4; $avg_watts * $duration / 1000" | bc)
        cost=$(echo "scale=2; $kwh * $RATE_PER_KWH" | bc)

        powerprofilesctl set power-saver
        last_power_mode="power-saver"
        notify "GPU session ended. Power-saver mode. Used ${kwh} kWh = \$${cost}"
        log "Session ended: ${kwh} kWh used, \$${cost}."

        if [ ! -f "$CSV_LOG" ]; then
            echo "Start Time,End Time,Duration (hrs),Avg Watts,kWh,Cost" > "$CSV_LOG"
        fi
        echo "$session_start_stamp,$session_end_stamp,$duration,$avg_watts,$kwh,$cost" >> "$CSV_LOG"
    fi

    # --- Power-saver fallback if no session ever triggered ---
    if ! $session_active && (( idle_gpu_counter >= END_TRIGGER_DURATION )) && [[ "$last_power_mode" != "power-saver" ]]; then
        powerprofilesctl set power-saver
        notify "GPU idle. Power-saver mode enabled (no session started)."
        log "Fallback: GPU idle for ${END_TRIGGER_DURATION}s. Power-saver mode enabled."
        last_power_mode="power-saver"
    fi

    sleep $POLL_INTERVAL
done
