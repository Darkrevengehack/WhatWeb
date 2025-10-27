# Copyright 2025 WhatWeb Contributors
# Enhanced Error Handling

module ErrorHandler
  class WhatWebError < StandardError; end
  class NetworkError < WhatWebError; end
  class ParseError < WhatWebError; end
  class PluginError < WhatWebError; end
  
  def self.handle_gracefully
    yield
  rescue Timeout::Error => e
    error "Timeout: #{e.message}"
    nil
  rescue SocketError => e
    error "Network error: #{e.message}"
    nil
  rescue Errno::ECONNREFUSED => e
    error "Connection refused: #{e.message}"
    nil
  rescue => e
    error "Unexpected error: #{e.class} - #{e.message}"
    debug e.backtrace.join("\n") if $WWDEBUG
    nil
  end
  
  def self.with_retry(max_attempts: 3, delay: 1)
    attempts = 0
    begin
      attempts += 1
      yield
    rescue => e
      if attempts < max_attempts
        warning "Attempt #{attempts} failed, retrying in #{delay}s..."
        sleep delay
        retry
      else
        raise
      end
    end
  end
end
