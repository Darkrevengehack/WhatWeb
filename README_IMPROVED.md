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
