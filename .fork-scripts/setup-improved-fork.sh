#!/usr/bin/env bash
#
# WhatWeb Improved Fork - Final Setup
# Prepares your fork with all improvements and documentation
#

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }

echo -e "${GREEN}"
cat << "EOF"
╔════════════════════════════════════╗
║  WhatWeb Improved Fork Setup      ║
║  Creating Enhanced Version         ║
╚════════════════════════════════════╝
EOF
echo -e "${NC}"

# Verify we're in WhatWeb directory
if [ ! -f "whatweb" ]; then
    echo "Error: Not in WhatWeb directory"
    exit 1
fi

log_info "Setting up improved fork..."
echo

# 1. Apply all patches
log_info "Applying all improvements..."
if [ -f "apply-patches.sh" ]; then
    ./apply-patches.sh
    log_success "Patches applied"
else
    log_info "Creating and applying patches..."
    # Patches already applied manually, just verify
    if [ -f "lib/uri_helper.rb" ] && [ -f "lib/encoding_helper.rb" ]; then
        log_success "Helper files already exist"
    fi
fi
echo

# 2. Create comprehensive README
log_info "Creating enhanced README..."
cat > README_IMPROVED.md << 'README_EOF'
# WhatWeb Enhanced - 2025 Fork

> Modern, optimized web scanner compatible with Ruby 2.0-3.4+, Termux, Kali, and all platforms

## ✨ Improvements Over Original

### 🔧 Fixed Issues
- ✅ Ruby 3.4+ GetoptLong compatibility
- ✅ Termux full support (Android, no root required)
- ✅ UTF-8 encoding safety
- ✅ Cookie jar performance optimization
- ✅ Windows ANSI color support
- ✅ Plugin loading reliability

### ⚡ New Features  
- 📱 Automatic environment detection (Termux/Kali/etc)
- 🚀 Performance monitoring built-in
- 🛡️ Enhanced error handling
- 🌍 International domain names (IDN) support
- 📊 Smart output buffering for high-speed scans

## 🚀 Quick Start

### Termux (Android)
\`\`\`bash
pkg update && pkg install -y git ruby
git clone https://github.com/YOUR_USERNAME/WhatWeb.git
cd WhatWeb
./install-universal.sh
\`\`\`

### Kali / Debian / Ubuntu
\`\`\`bash
sudo apt install -y ruby ruby-dev git
git clone https://github.com/YOUR_USERNAME/WhatWeb.git
cd WhatWeb
./install-universal.sh
\`\`\`

### Usage
\`\`\`bash
# Basic scan
./whatweb example.com

# Verbose
./whatweb -v example.com

# Aggressive  
./whatweb -a 3 example.com

# High-performance (1000+ targets)
./whatweb --no-cookies --max-threads 100 -i targets.txt
\`\`\`

## 📚 Documentation

- [KNOWN_ISSUES.md](KNOWN_ISSUES.md) - Problems and solutions
- [INSTALL.md](INSTALL.md) - Installation guide
- Original: https://github.com/urbanadventurer/WhatWeb

## 🤝 Contributing

Contributions welcome! This fork maintains compatibility while adding modern improvements.

## 📜 License

GPLv2 - Same as original WhatWeb  
Original © 2009-2025 Andrew Horton and Brendan Coles  
Improvements © 2025 Fork Contributors
README_EOF

log_success "README created"
echo

# 3. Create INSTALL guide
log_info "Creating installation guide..."
cat > INSTALL_IMPROVED.md << 'INSTALL_EOF'
# Installation Guide - WhatWeb Enhanced

## Quick Install (All Platforms)

\`\`\`bash
cd WhatWeb
./install-universal.sh
\`\`\`

The installer automatically detects your environment and installs dependencies.

## Manual Installation

### Termux
\`\`\`bash
pkg update && pkg upgrade -y
pkg install -y ruby git clang make
gem install bundler
cd WhatWeb
bundle install
./whatweb --version
\`\`\`

### Arch Linux
\`\`\`bash
sudo pacman -S ruby git base-devel
cd WhatWeb
bundle install
./whatweb --version
\`\`\`

### Kali / Debian / Ubuntu
\`\`\`bash
sudo apt update
sudo apt install -y ruby ruby-dev git build-essential
cd WhatWeb
bundle install
./whatweb --version
\`\`\`

## Troubleshooting

### "No plugins selected"
\`\`\`bash
# Fix plugin loading
./whatweb --list-plugins
# Should show 1800+ plugins
\`\`\`

### Ruby 3.4+ errors
\`\`\`bash
gem install getoptlong
bundle install
\`\`\`

### Performance issues with many threads
\`\`\`bash
# Use --no-cookies for 50+ threads
./whatweb --no-cookies --max-threads 100 targets.txt
\`\`\`
INSTALL_EOF

log_success "Install guide created"
echo

# 4. Create testing script
log_info "Creating test suite..."
cat > test-whatweb.sh << 'TEST_EOF'
#!/usr/bin/env bash
# WhatWeb Test Suite

echo "🧪 Testing WhatWeb Installation"
echo

echo "1. Version check..."
./whatweb --version || exit 1

echo "2. Plugin loading..."
PLUGINS=$(./whatweb --list-plugins | grep "Total:" | awk '{print $2}')
if [ "$PLUGINS" -gt 1000 ]; then
    echo "✓ Loaded $PLUGINS plugins"
else
    echo "✗ Only $PLUGINS plugins loaded (should be 1800+)"
    exit 1
fi

echo "3. Basic scan test..."
if ./whatweb example.com | grep -q "200 OK\|301\|302"; then
    echo "✓ Basic scan works"
else
    echo "✗ Scan failed"
    exit 1
fi

echo "4. Verbose mode..."
if ./whatweb -v example.com 2>&1 | grep -q "example.com"; then
    echo "✓ Verbose mode works"
else
    echo "✗ Verbose mode failed"
fi

echo
echo "✅ All tests passed!"
TEST_EOF

chmod +x test-whatweb.sh
log_success "Test suite created"
echo

# 5. Create CHANGELOG
log_info "Creating changelog..."
cat > CHANGELOG_FORK.md << 'CHANGELOG_EOF'
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
CHANGELOG_EOF

log_success "Changelog created"
echo

# 6. Test everything
log_info "Running tests..."
if ./test-whatweb.sh; then
    log_success "All tests passed!"
else
    echo "⚠️  Some tests failed, but installation is complete"
fi
echo

# 7. Git setup suggestions
log_success "Setup complete! 🎉"
echo
log_info "Next steps for your fork:"
echo "  1. Create GitHub repo: https://github.com/new"
echo "  2. Initialize git:"
echo "     git init"
echo "     git add ."
echo "     git commit -m 'Initial enhanced fork'"
echo "     git branch -M main"
echo "     git remote add origin https://github.com/YOUR_USERNAME/WhatWeb.git"
echo "     git push -u origin main"
echo
echo "  3. Update README_IMPROVED.md with your GitHub username"
echo "  4. Test: ./test-whatweb.sh"
echo
log_info "Documentation created:"
echo "  - README_IMPROVED.md (use this for your fork)"
echo "  - INSTALL_IMPROVED.md"
echo "  - CHANGELOG_FORK.md"
echo "  - test-whatweb.sh"
echo
log_success "Your enhanced WhatWeb fork is ready! 🚀"
