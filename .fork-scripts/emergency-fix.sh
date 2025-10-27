#!/usr/bin/env bash
#
# Emergency Fix for Plugin Loading Issue
# Fixes the broken lib/whatweb.rb from migration
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }

echo -e "${RED}"
cat << "EOF"
╔════════════════════════════════╗
║  EMERGENCY FIX - Plugin Load  ║
╚════════════════════════════════╝
EOF
echo -e "${NC}"

log_info "Diagnosing the issue..."

# Check current state
if grep -q "require_relative 'option_parser_wrapper'" lib/whatweb.rb; then
    log_info "Found compatibility wrapper modification"
    
    # The issue: migration script broke the require statement
    log_info "Checking if getoptlong require is broken..."
    
    if grep -q "require_relative 'option_parser_wrapper'  # Modern compatibility" lib/whatweb.rb; then
        log_error "Migration script broke the require chain!"
        log_info "Fixing now..."
        
        # Backup current broken state
        cp lib/whatweb.rb lib/whatweb.rb.broken
        
        # Fix the broken require
        # The migration added the wrapper INLINE with getoptlong, breaking it
        
        # Method 1: Restore from backup if exists
        if [ -f "lib/whatweb.rb.bak" ]; then
            log_info "Restoring from .bak file..."
            cp lib/whatweb.rb.bak lib/whatweb.rb.restored
            
            # Now properly add the wrapper support
            cat > lib/whatweb.rb.new << 'NEWFILE'
# Copyright 2009 to 2025 Andrew Horton and Brendan Coles
#
# This file is part of WhatWeb.
#
# WhatWeb is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# at your option) any later version.
#
# WhatWeb is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with WhatWeb.  If not, see <http://www.gnu.org/licenses/>.

# Debugging
# require 'profile' # debugging

# Standard Ruby
# Modern compatibility: Try getoptlong gem first, fall back to wrapper
begin
  require 'getoptlong'
rescue LoadError
  require_relative 'option_parser_wrapper'
end

require 'net/http'
require 'open-uri'
require 'cgi'
require 'thread'
require 'rbconfig' # detect environment, e.g. windows or linux
require 'resolv'
require 'resolv-replace' # asynchronous DNS
require 'open-uri'
require 'digest/md5'
require 'openssl' # required for Ruby version ~> 2.4
require 'pp'
require 'set'



# WhatWeb libs
require_relative 'whatweb/version.rb'
require_relative 'whatweb/banner.rb'
require_relative 'whatweb/scan.rb'
require_relative 'whatweb/parser.rb'
require_relative 'whatweb/redirect.rb'
require_relative 'gems.rb'
require_relative 'helper.rb'
require_relative 'target.rb'
require_relative 'plugins.rb'
require_relative 'plugin_support.rb'
require_relative 'logging.rb'
require_relative 'colour.rb'
require_relative 'version_class.rb'
require_relative 'http-status.rb'
require_relative 'extend-http.rb'

# load the lib/logging/ folder
Dir["#{File.expand_path(File.dirname(__FILE__))}/logging/*.rb"].each {|file| require file }

# Output options
$WWDEBUG = false # raise exceptions in plugins, etc
$verbose = 0 # $VERBOSE is reserved in ruby
$use_colour = 'auto'
$QUIET = false
$NO_ERRORS = false
$LOG_ERRORS = nil
$PLUGIN_TIMES = Hash.new(0)

# HTTP connection options
$USER_AGENT = "WhatWeb/#{WhatWeb::VERSION}"
$AGGRESSION = 1
$FOLLOW_REDIRECT = 'always'
$USE_PROXY = false
$PROXY_HOST = nil
$PROXY_PORT = 8080
$PROXY_USER = nil
$PROXY_PASS = nil
$HTTP_OPEN_TIMEOUT = 15
$HTTP_READ_TIMEOUT = 30
$WAIT = nil
$CUSTOM_HEADERS = {}
$BASIC_AUTH_USER = nil
$BASIC_AUTH_PASS = nil

# Ruby Version Compatability
if Gem::Version.new(RUBY_VERSION) < Gem::Version.new(2.0)
  raise('Unsupported version of Ruby. WhatWeb requires Ruby 2.0 or later.')
end

# Initialize HTTP Status class
HTTP_Status.initialize


PLUGIN_DIRS = []

# Load plugins from only one location
# Check for plugins in folders relative to the whatweb file first
# __dir__ follows symlinks
# this will work when whatweb is a symlink in /usr/bin/
$load_path_plugins = [
        File.expand_path('../', __dir__),
        "/usr/share/whatweb" # location Makefile installs into, also used in Kali
NEWFILE
            
            mv lib/whatweb.rb.new lib/whatweb.rb
            log_success "Fixed lib/whatweb.rb!"
        else
            log_error "No backup found, attempting manual fix..."
            
            # Manual fix: Remove the broken line and add proper one
            sed -i.emergency "/require_relative 'option_parser_wrapper'  # Modern compatibility/d" lib/whatweb.rb
            sed -i.emergency "/require 'getoptlong' rescue nil  # Fallback/d" lib/whatweb.rb
            
            # Add proper getoptlong require after the comments
            sed -i.emergency "/# Standard Ruby/a\\
# Modern compatibility wrapper\\
begin\\
  require 'getoptlong'\\
rescue LoadError\\
  require_relative 'option_parser_wrapper'\\
end" lib/whatweb.rb
            
            log_success "Applied manual fix"
        fi
    fi
fi

log_info "Testing fix..."

# Test if plugins load now
if ./whatweb --list-plugins 2>&1 | grep -q "Total: 0"; then
    log_error "Plugins still not loading!"
    log_info "Trying alternative fix..."
    
    # Alternative: Just use getoptlong gem directly
    log_info "Ensuring getoptlong gem is installed..."
    gem install getoptlong 2>/dev/null || true
    
    # Restore original from backup directory
    BACKUP_DIR=$(ls -td backup-* 2>/dev/null | head -1)
    if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
        log_info "Found backup: $BACKUP_DIR"
        log_info "Restoring lib/whatweb.rb from backup..."
        cp "$BACKUP_DIR/lib/whatweb.rb" lib/whatweb.rb
        log_success "Restored from backup"
    fi
else
    log_success "Plugins are loading now!"
fi

# Final test
log_info "Final test..."
PLUGIN_COUNT=$(./whatweb --list-plugins 2>&1 | grep "Total:" | awk '{print $2}')

if [ "$PLUGIN_COUNT" -gt 0 ]; then
    log_success "SUCCESS! Loaded $PLUGIN_COUNT plugins"
    echo
    log_info "Testing scan..."
    ./whatweb example.com
    echo
    log_success "WhatWeb is now working! ✨"
else
    log_error "Still having issues"
    echo
    log_info "Manual fix required. Run:"
    echo "  1. Restore backup: cp backup-*/lib/whatweb.rb lib/whatweb.rb"
    echo "  2. Install gem: gem install getoptlong"
    echo "  3. Test: ./whatweb example.com"
fi
