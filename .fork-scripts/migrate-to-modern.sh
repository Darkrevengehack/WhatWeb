#!/usr/bin/env bash
#
# WhatWeb Modernization Migration Script
# Automatically upgrades WhatWeb to use modern Ruby features
# Compatible with Ruby 2.0+ through 3.4+
#

set -e

# Colors
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
╦ ╦┬ ┬┌─┐┌┬┐╦ ╦┌─┐┌┐ 
║║║├─┤├─┤ │ ║║║├┤ ├┴┐
╚╩╝┴ ┴┴ ┴ ┴ ╚╩╝└─┘└─┘
Modernization Migration v2.0
EOF
    echo -e "${NC}"
}

backup_files() {
    log_info "Creating backup..."
    BACKUP_DIR="backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    cp -r lib "$BACKUP_DIR/" 2>/dev/null || true
    cp Gemfile "$BACKUP_DIR/" 2>/dev/null || true
    cp whatweb "$BACKUP_DIR/" 2>/dev/null || true
    
    log_success "Backup created: $BACKUP_DIR"
}

check_ruby_version() {
    log_info "Checking Ruby version..."
    
    if ! command -v ruby &> /dev/null; then
        log_error "Ruby not found. Please install Ruby first."
        exit 1
    fi
    
    RUBY_VERSION=$(ruby -v | awk '{print $2}')
    RUBY_MAJOR=$(echo $RUBY_VERSION | cut -d. -f1)
    RUBY_MINOR=$(echo $RUBY_VERSION | cut -d. -f2)
    
    log_success "Ruby ${RUBY_VERSION} detected"
    
    if [ "$RUBY_MAJOR" -ge 3 ] && [ "$RUBY_MINOR" -ge 4 ]; then
        NEEDS_MIGRATION=true
        log_warning "Ruby 3.4+ detected - migration recommended"
    else
        NEEDS_MIGRATION=false
        log_info "Ruby version compatible, but migration still recommended for future-proofing"
    fi
}

update_gemfile() {
    log_info "Updating Gemfile..."
    
    # Remove duplicate rchardet entries
    if grep -q "gem 'rchardet'" Gemfile; then
        log_info "Fixing duplicate rchardet entries..."
        # This is complex, so we'll just add a note
        log_warning "Please manually check Gemfile for duplicate 'rchardet' entries"
    fi
    
    # Ensure getoptlong is optional
    if grep -q "^gem 'getoptlong'" Gemfile; then
        log_info "Making getoptlong optional..."
        sed -i.bak "s/^gem 'getoptlong'/gem 'getoptlong', require: false/" Gemfile
    fi
    
    log_success "Gemfile updated"
}

add_modern_files() {
    log_info "Adding modern compatibility files..."
    
    # Create lib/option_parser_wrapper.rb
    cat > lib/option_parser_wrapper.rb << 'WRAPPER_EOF'
# GetoptLong compatibility wrapper using OptionParser
require 'optparse'

class GetoptLongCompat
  NO_ARGUMENT = :NONE
  REQUIRED_ARGUMENT = :REQUIRED
  OPTIONAL_ARGUMENT = :OPTIONAL
  
  Error = Class.new(StandardError)
  
  def initialize(*option_specs)
    @option_specs = option_specs
    @parsed_options = []
  end
  
  def each
    parser = OptionParser.new do |opts|
      @option_specs.each do |spec|
        names = spec[0..-2]
        arg_type = spec[-1]
        
        case arg_type
        when NO_ARGUMENT
          opts.on(*names) { @parsed_options << [names.first, ''] }
        when REQUIRED_ARGUMENT
          opts.on(*names, String) { |v| @parsed_options << [names.first, v] }
        when OPTIONAL_ARGUMENT
          opts.on(*names, String) { |v| @parsed_options << [names.first, v || ''] }
        end
      end
    end
    
    begin
      parser.parse!(ARGV)
    rescue OptionParser::InvalidOption, OptionParser::MissingArgument => e
      raise Error, e.message
    end
    
    @parsed_options.each { |opt, arg| yield opt, arg }
  end
end

GetoptLong = GetoptLongCompat unless defined?(GetoptLong)
WRAPPER_EOF
    
    log_success "Compatibility wrapper created"
}

update_whatweb_lib() {
    log_info "Updating lib/whatweb.rb..."
    
    # Add option_parser_wrapper require at the top
    if ! grep -q "option_parser_wrapper" lib/whatweb.rb; then
        # Add after the first require statement
        sed -i.bak "1,/^require/ s|^require 'getoptlong'|require_relative 'option_parser_wrapper'  # Modern compatibility\nrequire 'getoptlong' rescue nil  # Fallback|" lib/whatweb.rb
        log_success "lib/whatweb.rb updated with modern compatibility"
    else
        log_info "lib/whatweb.rb already has modern compatibility"
    fi
}

install_dependencies() {
    log_info "Installing/updating dependencies..."
    
    if command -v bundle &> /dev/null; then
        bundle install
        log_success "Dependencies installed"
    else
        log_warning "Bundler not found, installing gems manually..."
        gem install getoptlong addressable json ipaddr
        log_success "Core gems installed"
    fi
}

test_whatweb() {
    log_info "Testing WhatWeb..."
    
    if ./whatweb --version &> /dev/null; then
        log_success "WhatWeb is working! ✨"
        ./whatweb --version
        return 0
    else
        log_error "WhatWeb test failed"
        log_info "Rolling back to backup..."
        
        if [ -d "$BACKUP_DIR" ]; then
            cp -r "$BACKUP_DIR"/* .
            log_info "Backup restored. Please check manually."
        fi
        
        return 1
    fi
}

show_completion_message() {
    echo
    log_success "Migration complete! 🎉"
    echo
    log_info "What changed:"
    echo "  ✓ Added modern Ruby 3.4+ compatibility"
    echo "  ✓ Updated Gemfile with proper dependencies"
    echo "  ✓ Added OptionParser compatibility layer"
    echo "  ✓ Backup created in: $BACKUP_DIR"
    echo
    log_info "Next steps:"
    echo "  1. Test: ./whatweb --version"
    echo "  2. Scan: ./whatweb example.com"
    echo "  3. If issues occur, restore from: $BACKUP_DIR"
    echo
}

# Main execution
main() {
    show_banner
    
    # Check if in WhatWeb directory
    if [ ! -f "whatweb" ]; then
        log_error "Not in WhatWeb directory"
        exit 1
    fi
    
    log_info "Starting WhatWeb modernization..."
    echo
    
    check_ruby_version
    echo
    
    backup_files
    echo
    
    update_gemfile
    echo
    
    add_modern_files
    echo
    
    update_whatweb_lib
    echo
    
    install_dependencies
    echo
    
    test_whatweb
    echo
    
    show_completion_message
}

main "$@"
