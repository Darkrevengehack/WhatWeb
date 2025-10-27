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
