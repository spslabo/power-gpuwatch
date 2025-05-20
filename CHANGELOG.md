## 2025-05-20

- chore: add auto-changelog workflow ([`17f9eaf`](https://github.com/spslabo/power-gpuwatch/commit/17f9eafc953ddcfe4e213cf4de1637f44e7fb59e) by spslabo)

# Changelog

## [v1.0.1] - 2025-05-19
### Changed
- Renamed all references of `gpuwatch` to `power-gpuwatch` (script, logs, notify-send, systemd tags)
- Updated file paths and logger tag to use `power-gpuwatch`
- Renamed the script file from `gpuwatch.sh` to `power-gpuwatch.sh`
- Removed `"CAD"` label from log output and desktop notifications
- Replaced `"CAD"` column header in CSV output with `"Cost"`

---

## [v1.0.0] - 2025-05-19
### Added
- Initial GPU activity tracking script with `gpuwatch.sh`
- Automatic switching between `performance` and `power-saver` profiles based on GPU usage
- Power usage monitoring and cost calculation using NUT UPS data
- Session logging to both CSV and human-readable logs
- Idle fallback to `power-saver` even if no session was ever started
- systemd user service integration for background operation
