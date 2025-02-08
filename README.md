# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Added
- **New Driver Updater Menu:** Integrated an enhanced menu system with options for driver updates, background execution, and configuration management.
- **Update Logging:** Added a logging function to record every driver update event with timestamps.
- **Configuration Options:** Included settings for Light Mode and Dark Mode along with file and directory management (e.g., deleting logs, data folders).

### Changed
- **Elevated Privileges:** Improved the mechanism for elevating the script’s privileges using PowerShell.
- **User Interface:** Refined the menu interface and added color configuration for a better user experience.

### Fixed
- **Logging Issues:** Resolved problems with log file updates and ensured consistent timestamping for log entries.
- **Password Verification:** Corrected minor issues with the debug password verification process.

---

## [5.0.1] - 2025-02-08

### Added
- **Initial Release:** 
  - Basic driver update functionality using `pnputil`.
  - A modular menu system with clear separation of functions.
  - Support for background execution and periodic updates.
  - A dedicated update log to track driver installation events.
  - Debug mode with advanced options for testing and troubleshooting.
