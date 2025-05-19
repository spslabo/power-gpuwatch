# Changelog

## [v1.0.0] - 2025-05-19
### Added
- Initial GPU activity tracker script (`power-gpuwatch.sh`)
- Automatic switching between `performance` and `power-saver` profiles
- Power usage logging using UPS (via NUT)
- Session tracking with CSV and human-readable logs
- Idle fallback to power-saver even if no session is started
- systemd user service integration

### Changed
- Renamed from `gpuwatch` to `power-gpuwatch`
- Updated paths, logging, and identifiers to reflect new name
