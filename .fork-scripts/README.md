# Fork Enhancement Scripts

This directory contains scripts used to enhance and maintain this WhatWeb fork.

## Scripts

### Installation & Setup
- **install-universal.sh** - Universal installer for all platforms
- **setup-improved-fork.sh** - Complete fork setup and organization

### Migration & Fixes
- **migrate-to-modern.sh** - Migrate existing WhatWeb to modern version
- **apply-patches.sh** - Apply all enhancement patches
- **emergency-fix.sh** - Emergency plugin loading fix
- **fix-plugin-loading.sh** - Diagnostic tool for plugin issues

### Documentation
- **KNOWN_ISSUES.md** - Comprehensive list of known issues and solutions

## Usage

Most users should just run:
```bash
./install-universal.sh
```

For developers maintaining the fork:
```bash
./setup-improved-fork.sh  # Complete setup
./apply-patches.sh        # Apply patches only
```

## For Original WhatWeb Users

If you're migrating from the original WhatWeb:
```bash
./migrate-to-modern.sh
```
