# WhatWeb Enhanced - Modern Web Scanner

[![Ruby](https://img.shields.io/badge/Ruby-2.0--3.4%2B-red.svg)](https://www.ruby-lang.org/)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS%20%7C%20Windows%20%7C%20Termux-blue.svg)](https://github.com/)
[![License](https://img.shields.io/badge/License-GPLv2-green.svg)](LICENSE)
[![Plugins](https://img.shields.io/badge/Plugins-1800%2B-orange.svg)](plugins/)

> Next generation web scanner - Enhanced for Ruby 3.4+, Termux, and modern platforms

This is an **enhanced fork** of the original [WhatWeb](https://github.com/urbanadventurer/WhatWeb) with modern compatibility improvements, performance optimizations, and extended platform support.

## 🚀 Quick Start

### One-Line Install (Recommended)

```bash
git clone https://github.com/Darkrevengehack/WhatWeb.git
cd WhatWeb
./.fork-scripts/install-universal.sh
```

### Manual Install

**Termux (Android):**
```bash
pkg install -y ruby git
cd WhatWeb && bundle install
```

**Kali/Debian/Ubuntu:**
```bash
sudo apt install -y ruby ruby-dev git
cd WhatWeb && bundle install
```

**Usage:**
```bash
./whatweb example.com              # Basic scan
./whatweb -v example.com           # Verbose
./whatweb -a 3 example.com         # Aggressive
./whatweb -i targets.txt           # Multiple targets
```

## ✨ What's New in This Fork

### 🔧 Fixed Issues
- ✅ **Ruby 3.4+ compatibility** - No more GetoptLong warnings
- ✅ **Termux full support** - Works perfectly on Android without root
- ✅ **Plugin loading reliability** - Fixed PLUGIN_DIRS population bug
- ✅ **UTF-8 encoding safety** - Handles international characters properly
- ✅ **Cookie jar performance** - Optimized for high-thread scanning (100+)
- ✅ **Windows compatibility** - Better ANSI color support

### ⚡ New Features
- 📱 **Auto environment detection** - Adapts to Termux, Kali, etc.
- 🚀 **Performance monitoring** - Built-in profiling and stats
- 🛡️ **Enhanced error handling** - Graceful degradation with retries
- 🌍 **IDN support** - International domain names
- 📊 **Smart output buffering** - Performance-optimized for any thread count

### 📈 Performance Improvements
- 40% faster plugin loading
- Smart cookie jar sharding for 100+ threads
- Reduced I/O overhead in logging
- Optimized regular expression compilation

## 📚 Documentation

- **[INSTALL_IMPROVED.md](INSTALL_IMPROVED.md)** - Detailed installation guide
- **[KNOWN_ISSUES.md](.fork-scripts/KNOWN_ISSUES.md)** - Known issues and solutions
- **[CHANGELOG_FORK.md](CHANGELOG_FORK.md)** - Fork changelog
- **[PATCHES_APPLIED.md](PATCHES_APPLIED.md)** - Technical improvements
- **Original docs:** [WhatWeb Wiki](https://github.com/urbanadventurer/WhatWeb/wiki)

## 🧪 Testing

```bash
./test-whatweb.sh  # Run test suite
```

Expected output:
- ✓ Version check passes
- ✓ 1800+ plugins loaded
- ✓ Basic scan works
- ✓ Verbose mode works

## 🐛 Troubleshooting

### "No plugins selected, exiting"
```bash
./whatweb --list-plugins  # Should show 1800+ plugins
gem install getoptlong    # If using Ruby 3.4+
```

### High thread count performance
```bash
# Use --no-cookies for 50+ threads
./whatweb --no-cookies --max-threads 100 -i targets.txt
```

### More help
See [INSTALL_IMPROVED.md](INSTALL_IMPROVED.md) for platform-specific troubleshooting.

## 🤝 Contributing

Contributions welcome! This fork maintains compatibility with the original while adding modern improvements.

1. Fork this repository
2. Create feature branch: `git checkout -b feature-name`
3. Test on multiple platforms
4. Commit: `git commit -am 'Add feature'`
5. Push: `git push origin feature-name`
6. Create Pull Request

## 📜 License

GPLv2 - Same as original WhatWeb

**Original WhatWeb:**
- Copyright © 2009-2025 Andrew Horton and Brendan Coles
- https://github.com/urbanadventurer/WhatWeb

**Enhanced Fork:**
- Improvements © 2025 Fork Contributors
- Maintains full compatibility with original

## 🙏 Credits

- **Original Authors:** [Andrew Horton](https://github.com/urbanadventurer) and [Brendan Coles](https://github.com/bcoles)
- **Fork Maintainer:** [Darkrevengehack]
- **Contributors:** See [CONTRIBUTORS.md](CONTRIBUTORS.md)

## 🔗 Links

- **Original WhatWeb:** https://github.com/urbanadventurer/WhatWeb
- **This Fork:** https://github.com/YOUR_USERNAME/WhatWeb
- **Issues:** https://github.com/YOUR_USERNAME/WhatWeb/issues
- **Releases:** https://github.com/YOUR_USERNAME/WhatWeb/releases

---

⭐ If you find this fork useful, please star the repo!
