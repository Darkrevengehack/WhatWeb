#!/usr/bin/env bash
#
# WhatWeb Universal Installer
# Detects environment and installs dependencies automatically
# Compatible with: Termux, Kali Linux, Ubuntu, Debian, Arch, etc.
# Supports: Root and non-root users
#

set -e  # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Banner
show_banner() {
    echo -e "${BLUE}"
    cat << "EOF"
╦ ╦┬ ┬┌─┐┌┬┐╦ ╦┌─┐┌┐ 
║║║├─┤├─┤ │ ║║║├┤ ├┴┐
╚╩╝┴ ┴┴ ┴ ┴ ╚╩╝└─┘└─┘
Universal Installer v2.0
EOF
    echo -e "${NC}"
}

# Detect environment
detect_environment() {
    log_info "Detecting environment..."
    
    # Check if Termux
    if [ -n "$TERMUX_VERSION" ] || [ -d "/data/data/com.termux" ]; then
        ENV_TYPE="termux"
        log_success "Environment: Termux"
        return
    fi
    
    # Check if running with root
    if [ "$EUID" -eq 0 ]; then
        HAS_ROOT=true
        log_success "Running as: root"
    else
        HAS_ROOT=false
        log_info "Running as: non-root user"
    fi
    
    # Detect Linux distribution
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        ENV_TYPE="${ID}"
        log_success "Detected: ${NAME}"
    elif [ -f /etc/arch-release ]; then
        ENV_TYPE="arch"
        log_success "Detected: Arch Linux"
    else
        ENV_TYPE="unknown"
        log_warning "Unknown distribution, attempting generic installation"
    fi
}

# Check Ruby version
check_ruby() {
    log_info "Checking Ruby installation..."
    
    if command -v ruby &> /dev/null; then
        RUBY_VERSION=$(ruby -v | awk '{print $2}')
        log_success "Ruby ${RUBY_VERSION} found"
        
        # Check if Ruby 3.4+
        RUBY_MAJOR=$(echo $RUBY_VERSION | cut -d. -f1)
        RUBY_MINOR=$(echo $RUBY_VERSION | cut -d. -f2)
        
        if [ "$RUBY_MAJOR" -ge 3 ] && [ "$RUBY_MINOR" -ge 4 ]; then
            NEEDS_GETOPTLONG=true
            log_warning "Ruby 3.4+ detected - GetoptLong gem required"
        fi
        
        return 0
    else
        log_error "Ruby not found"
        return 1
    fi
}

# Install dependencies based on environment
install_dependencies() {
    log_info "Installing dependencies for ${ENV_TYPE}..."
    
    case "$ENV_TYPE" in
        termux)
            log_info "Using pkg package manager..."
            pkg update -y
            pkg install -y ruby git clang make libxml2 libxslt
            ;;
            
        kali|debian|ubuntu)
            if [ "$HAS_ROOT" = true ]; then
                log_info "Using apt package manager..."
                apt-get update
                apt-get install -y ruby ruby-dev git build-essential libxml2-dev libxslt-dev
            else
                log_error "Root required for apt. Please run with sudo or install dependencies manually:"
                log_info "  sudo apt-get install ruby ruby-dev git build-essential"
                exit 1
            fi
            ;;
            
        arch)
            if [ "$HAS_ROOT" = true ]; then
                log_info "Using pacman package manager..."
                pacman -Sy --noconfirm ruby git base-devel libxml2 libxslt
            else
                log_error "Root required for pacman. Please run with sudo or install dependencies manually:"
                log_info "  sudo pacman -S ruby git base-devel"
                exit 1
            fi
            ;;
            
        fedora|rhel|centos)
            if [ "$HAS_ROOT" = true ]; then
                log_info "Using yum/dnf package manager..."
                if command -v dnf &> /dev/null; then
                    dnf install -y ruby ruby-devel git gcc make libxml2-devel libxslt-devel
                else
                    yum install -y ruby ruby-devel git gcc make libxml2-devel libxslt-devel
                fi
            else
                log_error "Root required. Please run with sudo."
                exit 1
            fi
            ;;
            
        *)
            log_warning "Unknown package manager. Please install manually:"
            log_info "  Required: ruby git build-tools"
            read -p "Continue anyway? (y/n) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
            ;;
    esac
    
    log_success "System dependencies installed"
}

# Install Ruby gems
install_gems() {
    log_info "Installing Ruby gems..."
    
    # Check if bundler is installed
    if ! gem list bundler -i &> /dev/null; then
        log_info "Installing bundler..."
        gem install bundler
    fi
    
    # Install GetoptLong for Ruby 3.4+
    if [ "$NEEDS_GETOPTLONG" = true ]; then
        log_info "Installing getoptlong gem for Ruby 3.4+..."
        gem install getoptlong
    fi
    
    # Install core dependencies
    log_info "Installing core gems..."
    gem install addressable json ipaddr
    
    # Bundle install if Gemfile exists
    if [ -f "Gemfile" ]; then
        log_info "Running bundle install..."
        bundle install
    fi
    
    log_success "Ruby gems installed"
}

# Setup WhatWeb
setup_whatweb() {
    log_info "Setting up WhatWeb..."
    
    # Make whatweb executable
    chmod +x whatweb
    
    # Create symlink for easy access (optional)
    if [ "$ENV_TYPE" = "termux" ]; then
        INSTALL_DIR="$PREFIX/bin"
    else
        if [ "$HAS_ROOT" = true ]; then
            INSTALL_DIR="/usr/local/bin"
        else
            INSTALL_DIR="$HOME/.local/bin"
            mkdir -p "$INSTALL_DIR"
        fi
    fi
    
    read -p "Create symlink in ${INSTALL_DIR}? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ln -sf "$(pwd)/whatweb" "${INSTALL_DIR}/whatweb"
        log_success "Symlink created: ${INSTALL_DIR}/whatweb"
        
        # Add to PATH if needed
        if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
            log_warning "Add ${INSTALL_DIR} to your PATH:"
            log_info "  echo 'export PATH=\"${INSTALL_DIR}:\$PATH\"' >> ~/.bashrc"
            log_info "  source ~/.bashrc"
        fi
    fi
}

# Test installation
test_installation() {
    log_info "Testing WhatWeb installation..."
    
    if ./whatweb --version &> /dev/null; then
        log_success "WhatWeb is working!"
        ./whatweb --version
    else
        log_error "WhatWeb test failed"
        log_info "Try running: ./whatweb --version"
        exit 1
    fi
}

# Main installation process
main() {
    show_banner
    
    # Check if in WhatWeb directory
    if [ ! -f "whatweb" ]; then
        log_error "Not in WhatWeb directory. Please cd to WhatWeb folder first."
        exit 1
    fi
    
    log_info "Starting WhatWeb installation..."
    echo
    
    detect_environment
    echo
    
    check_ruby || install_dependencies
    echo
    
    install_gems
    echo
    
    setup_whatweb
    echo
    
    test_installation
    echo
    
    log_success "Installation complete! 🎉"
    log_info "Usage: ./whatweb example.com"
    log_info "Help:  ./whatweb --help"
}

# Run main function
main
