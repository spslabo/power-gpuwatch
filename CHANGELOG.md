## 2025-06-05

- Fixed issue with missing bracket ([`07677a9`](https://github.com/spslabo/power-gpuwatch/commit/07677a976d35aef50f16b743d3bf4bffc6b91c2c) by spslabo)

## 2025-06-05

- Merge pull request #6 from spslabo/f7h3rc-codex/find-and-fix-important-bug ([`b9c53d0`](https://github.com/spslabo/power-gpuwatch/commit/b9c53d0f565821945d0b139b1948ddf86c8b3c3b) by spslabo)

## 2025-06-05

- Merge pull request #5 from spslabo/3s6aqy-codex/find-and-fix-important-bug ([`2122899`](https://github.com/spslabo/power-gpuwatch/commit/212289965e92f37920510245e92a8802bfab745d) by spslabo)

## 2025-06-05

- Merge pull request #4 from spslabo/codex/find-and-fix-important-bug ([`45e0921`](https://github.com/spslabo/power-gpuwatch/commit/45e09216e6d6163f1f76f2df13b504e7fc5c5d65) by spslabo)

## 2025-06-04

- Merge pull request #3 from spslabo/codex/update-script-to-reduce-logging-verbosity ([`52daa34`](https://github.com/spslabo/power-gpuwatch/commit/52daa34e9bf0016d1cb9011b1c026916bbbc444c) by spslabo)

## 2025-05-20

- docs: trigger changelog workflow ([`4e17ee1`](https://github.com/spslabo/power-gpuwatch/commit/4e17ee1005045892dae83b441703d54720133bc4) by spslabo)

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
