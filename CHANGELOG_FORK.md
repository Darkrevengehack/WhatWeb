# Changelog - WhatWeb Enhanced Fork

## [Enhanced-v1.0] - 2025-10-27

### Added
- Universal installer for all platforms (install-universal.sh)
- Automatic environment detection (Termux, Kali, etc)
- Performance monitoring module
- Enhanced error handling system
- URI helper for Ruby 3.0+ compatibility
- Encoding safety helpers
- Windows compatibility layer
- IDN (International Domain Names) support

### Fixed
- Ruby 3.4+ GetoptLong deprecation (#CRITICAL)
- Plugin loading in Termux
- UTF-8 encoding errors
- Cookie jar performance with high thread counts
- Gemfile duplicate dependencies
- PLUGIN_DIRS population bug

### Improved  
- Output buffering for better performance
- Message system with proper logging levels
- Documentation and README
- Error messages and debugging

### Performance
- Smart output buffering based on thread count
- Cookie jar sharding for 100+ threads
- Reduced I/O overhead in logging

## Original WhatWeb
See main CHANGELOG.md for original version history
