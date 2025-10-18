require 'uri'

# Simple thread-safe cookie jar for WhatWeb
# Provides automatic cookie persistence across redirects with minimal complexity
class SimpleCookieJar
  def initialize(max_domains: 10_000)
    @cookies = {}           # domain -> cookie_string
    @mutex = Mutex.new      # Thread safety
    @max_domains = max_domains
    @cleanup_threshold = max_domains / 2
    @request_count = 0
  end

  def add_cookies(set_cookie_header, url)
    return unless set_cookie_header && url
    
    domain = extract_domain(url)
    return unless domain

    @mutex.synchronize do
      @request_count += 1
      
      # Parse Set-Cookie header (simple approach)
      cookie_values = parse_set_cookie_header(set_cookie_header)
      unless cookie_values.empty?
        if @cookies[domain]
          # Merge cookies, with new cookies overriding existing ones with same name
          existing_cookies = {}
          @cookies[domain].split('; ').each do |cookie|
            name, value = cookie.split('=', 2)
            existing_cookies[name] = value if name && value
          end
          
          # Add new cookies, overriding existing ones
          cookie_values.split('; ').each do |cookie|
            name, value = cookie.split('=', 2)
            # Only store cookies with valid names (non-empty) and values
            existing_cookies[name] = value if name && !name.empty? && value && !value.empty?
          end
          
          # Rebuild cookie string
          @cookies[domain] = existing_cookies.map { |name, value| "#{name}=#{value}" }.join('; ')
        else
          @cookies[domain] = cookie_values
        end
      end
      
      # Cleanup after adding if we reach or exceed limit
      cleanup_old_domains if @cookies.size >= @max_domains
    end
  end

  def cookies_for_request(url)
    domain = extract_domain(url)
    return nil unless domain
    
    @mutex.synchronize { @cookies[domain] }
  end

  def stats
    @mutex.synchronize do
      {
        domains: @cookies.size,
        max_domains: @max_domains,
        requests_processed: @request_count,
        memory_estimate_kb: @cookies.size * 1024 # ~1KB per domain
      }
    end
  end

  # Display current cookie jar contents (for debugging)
  def display_cookies
    @mutex.synchronize do
      if @cookies.empty?
        debug("Cookie jar is empty") if defined?(debug)
      else
        debug("Cookie jar contents (#{@cookies.size} domains):") if defined?(debug)
        @cookies.each do |domain, cookies|
          debug("  #{domain}: #{cookies}") if defined?(debug)
        end
      end
    end
  end

  private

  def extract_domain(url)
    URI.parse(url.to_s).host&.downcase
  rescue URI::InvalidURIError, ArgumentError
    nil
  end

  def parse_set_cookie_header(header)
    begin
      cookie_values = []
      
      # Handle different cookie header formats
      if header.include?("\n")
        # Multiple Set-Cookie headers joined with newlines
        header.split("\n").each do |line|
          line = line.strip
          next if line.empty?
          
          # Extract the first cookie (before first semicolon for attributes)
          cookie_part = line.split(';').first
          cookie_part = cookie_part.strip if cookie_part
          
          if cookie_part && cookie_part.include?('=') && !cookie_part.empty?
            name, value = cookie_part.split('=', 2)
            if name && !name.empty? && value && !value.empty?
              cookie_values << cookie_part
            end
          end
        end
      elsif header.include?(';')
        # Check if this is a single cookie with attributes or multiple cookies
        parts = header.split(';').map(&:strip)
        
        # Known cookie attributes that should be ignored
        cookie_attributes = %w[path domain expires max-age secure httponly samesite]
        
        # If the first part looks like a cookie and subsequent parts are attributes, 
        # treat as single cookie with attributes
        first_part = parts.first
        if first_part && first_part.include?('=')
          # Check if remaining parts are cookie attributes
          remaining_parts = parts[1..-1]
          looks_like_attributes = remaining_parts.all? do |part|
            if part.include?('=')
              attr_name = part.split('=', 2).first.downcase
              cookie_attributes.include?(attr_name)
            else
              # Attributes like 'Secure', 'HttpOnly' don't have values
              cookie_attributes.include?(part.downcase)
            end
          end
          
          if looks_like_attributes
            # Single cookie with attributes - only take the first part
            name, value = first_part.split('=', 2)
            if name && !name.empty? && value && !value.empty?
              cookie_values << first_part
            end
          else
            # Multiple cookies - process all parts
            parts.each do |part|
              if part.include?('=') && !part.empty?
                name, value = part.split('=', 2)
                if name && !name.empty? && value && !value.empty?
                  cookie_values << part
                end
              end
            end
          end
        end
      else
        # Single cookie without attributes
        if header.include?('=') && !header.strip.empty?
          name, value = header.strip.split('=', 2)
          if name && !name.empty? && value && !value.empty?
            cookie_values << header.strip
          end
        end
      end
      
      cookie_values.join('; ')
    rescue => e
      # Log error but don't crash - only show in debug mode
      debug("Failed to parse cookie header: #{e.message}") if defined?(debug)
      ""
    end
  end

  def cleanup_old_domains
    # Emergency cleanup if way over limit
    if @cookies.size > @max_domains * 1.5
      @cookies.clear
      debug("Emergency cookie jar reset due to memory pressure") if defined?(debug)
    elsif @cookies.size >= @max_domains
      # Normal cleanup - Ruby hashes maintain insertion order, remove oldest domains
      domains_to_remove = @cookies.keys.first(@cleanup_threshold)
      domains_to_remove.each { |domain| @cookies.delete(domain) }
      
      debug("Cookie jar cleanup: removed #{domains_to_remove.size} oldest domains") if defined?(debug)
    end
  end
end
