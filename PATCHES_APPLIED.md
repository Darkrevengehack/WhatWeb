# WhatWeb Patches Applied

## Summary
This document lists all patches that have been applied to this WhatWeb installation.

### Applied Patches:
1. ✅ URI.escape deprecation fix (Ruby 3.0+)
2. ✅ Encoding safety improvements
3. ✅ Cookie jar performance optimization
4. ✅ Windows compatibility layer
5. ✅ IDN (International Domain Names) support
6. ✅ Enhanced error handling
7. ✅ Performance monitoring

### New Files Created:
- `lib/uri_helper.rb` - URI encoding helpers
- `lib/encoding_helper.rb` - UTF-8 safety
- `lib/windows_compat.rb` - Windows support
- `lib/idn_helper.rb` - International domains
- `lib/error_handler.rb` - Better error handling
- `lib/performance_monitor.rb` - Performance tracking

### Modified Files:
- `lib/whatweb.rb` - Added new helper requires
- `lib/simple_cookie_jar.rb` - Sharding support (appended)

### Backup Files:
All modified files have backups with timestamp suffix:
- `filename.backup-YYYYMMDD-HHMMSS`

### Testing:
Run tests with:
```bash
./whatweb --version
./whatweb -v example.com
./whatweb --debug -vv example.com
```

### Rollback:
To rollback any changes:
```bash
# Find backup files
ls -la lib/*.backup*

# Restore specific file
cp lib/whatweb.rb.backup-YYYYMMDD-HHMMSS lib/whatweb.rb
```

Generated: $(date)
