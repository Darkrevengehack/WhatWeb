#!/usr/bin/env bash
#
# WhatWeb Plugin Loading Fix
# Diagnoses and fixes "No plugins selected, exiting" error
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[⚠]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }

show_banner() {
    echo -e "${BLUE}"
    cat << "EOF"
╔═══════════════════════════════╗
║  Plugin Loading Diagnostic   ║
╚═══════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Step 1: Check plugin directory
check_plugin_dir() {
    log_info "Checking plugin directory..."
    
    if [ ! -d "plugins" ]; then
        log_error "plugins/ directory not found!"
        log_info "You might be in the wrong directory"
        return 1
    fi
    
    PLUGIN_COUNT=$(ls -1 plugins/*.rb 2>/dev/null | wc -l)
    
    if [ "$PLUGIN_COUNT" -eq 0 ]; then
        log_error "No .rb files found in plugins/"
        return 1
    fi
    
    log_success "Found $PLUGIN_COUNT plugin files"
    
    # Show sample plugins
    log_info "Sample plugins:"
    ls plugins/*.rb | head -5 | while read plugin; do
        echo "  - $(basename $plugin)"
    done
    
    return 0
}

# Step 2: Check file permissions
check_permissions() {
    log_info "Checking file permissions..."
    
    if [ ! -x "whatweb" ]; then
        log_warning "whatweb is not executable, fixing..."
        chmod +x whatweb
        log_success "Fixed whatweb permissions"
    else
        log_success "whatweb is executable"
    fi
    
    # Check if plugins are readable
    if [ ! -r "plugins/apache.rb" ]; then
        log_warning "Plugin files not readable, fixing..."
        chmod -R 644 plugins/*.rb
        log_success "Fixed plugin permissions"
    else
        log_success "Plugins are readable"
    fi
}

# Step 3: Test Ruby can load whatweb lib
test_ruby_loading() {
    log_info "Testing Ruby library loading..."
    
    cat > /tmp/test_whatweb_load.rb << 'EOF'
#!/usr/bin/env ruby
$LOAD_PATH.unshift(File.expand_path('.'))
begin
  require 'lib/whatweb'
  puts "✓ lib/whatweb.rb loaded successfully"
  
  if defined?(PluginSupport)
    puts "✓ PluginSupport class found"
  else
    puts "✗ PluginSupport class NOT found"
    exit 1
  end
  
  exit 0
rescue LoadError => e
  puts "✗ LoadError: #{e.message}"
  puts e.backtrace.first(5).join("\n")
  exit 1
rescue => e
  puts "✗ Error: #{e.class} - #{e.message}"
  puts e.backtrace.first(5).join("\n")
  exit 1
end
EOF
    
    if ruby /tmp/test_whatweb_load.rb 2>&1; then
        log_success "Ruby can load WhatWeb library"
        rm /tmp/test_whatweb_load.rb
        return 0
    else
        log_error "Ruby cannot load WhatWeb library"
        rm /tmp/test_whatweb_load.rb
        return 1
    fi
}

# Step 4: Test plugin loading specifically
test_plugin_loading() {
    log_info "Testing plugin loading mechanism..."
    
    cat > /tmp/test_plugins.rb << 'EOF'
#!/usr/bin/env ruby
$LOAD_PATH.unshift(File.expand_path('.'))

begin
  require 'lib/whatweb'
  
  puts "Attempting to load plugins..."
  
  # Check PLUGIN_DIRS
  if defined?($load_path_plugins)
    puts "Plugin paths configured: #{$load_path_plugins.inspect}"
  end
  
  # Try to load plugins
  plugins = PluginSupport.load_plugins
  
  if plugins.nil?
    puts "✗ load_plugins returned nil"
    exit 1
  elsif plugins.empty?
    puts "✗ load_plugins returned empty array"
    exit 1
  else
    puts "✓ Loaded #{plugins.length} plugins"
    puts "Sample plugins:"
    plugins.first(5).each do |name, _|
      puts "  - #{name}"
    end
    exit 0
  end
  
rescue => e
  puts "✗ Error loading plugins: #{e.class}"
  puts "   Message: #{e.message}"
  puts "   Backtrace:"
  puts e.backtrace.first(10).map { |l| "     #{l}" }.join("\n")
  exit 1
end
EOF
    
    if ruby /tmp/test_plugins.rb 2>&1; then
        log_success "Plugin loading works!"
        rm /tmp/test_plugins.rb
        return 0
    else
        log_error "Plugin loading failed"
        log_info "See error details above"
        rm /tmp/test_plugins.rb
        return 1
    fi
}

# Step 5: Check for compatibility wrapper issues
check_wrapper() {
    log_info "Checking compatibility wrapper..."
    
    if [ -f "lib/option_parser_wrapper.rb" ]; then
        log_info "Found option_parser_wrapper.rb"
        
        # Test if it loads
        if ruby -e "require './lib/option_parser_wrapper.rb'; puts GetoptLong" 2>&1 | grep -q "GetoptLongCompat"; then
            log_success "Compatibility wrapper works"
        else
            log_warning "Compatibility wrapper might have issues"
        fi
    else
        log_info "No compatibility wrapper found (might be using getoptlong gem)"
    fi
}

# Step 6: Fix common issues
apply_fixes() {
    log_info "Applying common fixes..."
    
    # Fix 1: Ensure lib/whatweb.rb has correct requires
    if ! grep -q "require_relative 'plugins'" lib/whatweb.rb; then
        log_warning "lib/whatweb.rb might be missing plugin support require"
        log_info "This should be in lib/plugin_support.rb"
    fi
    
    # Fix 2: Check if there's a conflict in requires
    if grep -q "require 'getoptlong'" lib/whatweb.rb && [ -f "lib/option_parser_wrapper.rb" ]; then
        log_info "Both getoptlong and wrapper found - ensuring compatibility..."
        
        # Make getoptlong require conditional
        if ! grep -q "require 'getoptlong' rescue nil" lib/whatweb.rb; then
            log_info "Making getoptlong require conditional..."
            sed -i.bak "s|require 'getoptlong'|require 'getoptlong' rescue nil  # Optional|" lib/whatweb.rb
            log_success "Fixed getoptlong require"
        fi
    fi
    
    # Fix 3: Verify plugin_support.rb exists
    if [ ! -f "lib/plugin_support.rb" ]; then
        log_error "lib/plugin_support.rb is MISSING!"
        log_info "This is critical - plugin loading won't work without it"
        return 1
    else
        log_success "lib/plugin_support.rb exists"
    fi
    
    return 0
}

# Step 7: Test actual scan
test_scan() {
    log_info "Testing actual scan..."
    
    # First try to list plugins
    log_info "Listing plugins..."
    if ./whatweb --list-plugins 2>&1 | grep -q "Plugins:"; then
        log_success "Plugin listing works!"
    else
        log_error "Plugin listing failed"
        log_info "Output:"
        ./whatweb --list-plugins 2>&1 | head -10
        return 1
    fi
    
    # Try a simple scan
    log_info "Attempting simple scan..."
    if ./whatweb --version >/dev/null 2>&1; then
        log_success "Version command works"
    else
        log_error "Version command failed"
        return 1
    fi
    
    # Try scanning example.com
    log_info "Scanning example.com (this might take a moment)..."
    if timeout 15 ./whatweb example.com 2>&1 | grep -qi "http\|IP"; then
        log_success "Scan completed successfully!"
        return 0
    else
        log_error "Scan failed or timed out"
        log_info "Manual test: ./whatweb example.com"
        return 1
    fi
}

# Main diagnostic process
main() {
    show_banner
    
    if [ ! -f "whatweb" ]; then
        log_error "Not in WhatWeb directory!"
        log_info "Please cd to WhatWeb directory first"
        exit 1
    fi
    
    echo
    log_info "Starting diagnostic process..."
    echo
    
    check_plugin_dir || { echo; log_error "Plugin directory check failed!"; exit 1; }
    echo
    
    check_permissions
    echo
    
    test_ruby_loading || { echo; log_error "Ruby library loading failed!"; exit 1; }
    echo
    
    check_wrapper
    echo
    
    apply_fixes
    echo
    
    test_plugin_loading || { 
        echo
        log_error "Plugin loading still failing!"
        log_info "Detailed diagnosis:"
        log_info "1. Check Ruby version: ruby --version"
        log_info "2. Check gems: gem list"
        log_info "3. Try: bundle exec ./whatweb example.com"
        log_info "4. Check lib/plugin_support.rb exists"
        exit 1
    }
    echo
    
    test_scan
    echo
    
    log_success "Diagnostic complete!"
    echo
    log_info "Summary:"
    log_info "  ✓ Plugin directory: OK"
    log_info "  ✓ File permissions: OK"
    log_info "  ✓ Ruby loading: OK"
    log_info "  ✓ Plugin loading: OK"
    echo
    log_info "If scan still fails, try:"
    log_info "  ./whatweb --debug -vv example.com"
    echo
}

main "$@"
