# Changelog

All notable changes to Focus Session Watcher will be documented in this file.

## [1.0.0] - 2025-12-03

### Added
- Initial release of Focus Session Watcher
- Core watcher script with 2-second polling
- Idle detection via ioreg (HID devices)
- 25-minute Pomodoro session timer (configurable)
- LaunchAgent for automatic startup
- Daily log rotation with CSV export
- Shortcuts app integration for alerts
- Session status file (MM:SS format)
- JSON state tracking
- Helper scripts for status, logs, and management
- Comprehensive documentation (README, USAGE, TROUBLESHOOTING)
- Installation and uninstallation scripts
- MIT License

### Features
- ✅ Automatic focus sessions
- ✅ Real-time session countdown
- ✅ Smart notifications via Shortcuts
- ✅ Screen auto-lock after sessions
- ✅ Activity-based session tracking
- ✅ Idle detection and session reset
- ✅ Daily CSV analytics
- ✅ Log archival and compression
- ✅ Zero external dependencies
- ✅ Minimal resource usage

### Performance
- CPU: ~0% (2-second poll interval)
- Memory: 1-2 MB resident
- Disk: ~100 KB per day of logs
- Battery: Negligible impact

---

## [Future Releases]

### Planned Features
- [ ] Multi-account support
- [ ] Dark mode for status display
- [ ] Time-of-day presets
- [ ] Week/month/year analytics
- [ ] Integration with calendar apps
- [ ] Custom alert sounds
- [ ] Statistics dashboard
- [ ] Cloud sync of logs
- [ ] Mobile app for tracking
- [ ] Team collaboration features

### Under Consideration
- Support for other break-tracking methods
- Integration with focus/do not disturb modes
- Custom break reminders
- Productivity reports
- Browser extension for status display

---

For detailed version history and commits, see the [GitHub Releases](https://github.com/yourusername/focus-session-installer/releases) page.
