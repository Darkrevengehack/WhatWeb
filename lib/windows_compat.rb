# Copyright 2025 WhatWeb Contributors
# Windows Compatibility Layer

module WindowsCompat
  def self.windows?
    RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/
  end
  
  def self.normalize_path(path)
    windows? ? path.gsub('/', '\\') : path
  end
  
  def self.enable_ansi_colors
    return unless windows?
    
    begin
      # Enable ANSI escape sequences on Windows 10+
      system('')
    rescue
      # Fallback: disable colors if ANSI not supported
      $use_colour = false
    end
  end
  
  def self.command_exists?(cmd)
    exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
    ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
      exts.each do |ext|
        exe = File.join(path, "#{cmd}#{ext}")
        return true if File.executable?(exe) && !File.directory?(exe)
      end
    end
    false
  end
end

# Auto-enable ANSI on load
WindowsCompat.enable_ansi_colors if WindowsCompat.windows?
