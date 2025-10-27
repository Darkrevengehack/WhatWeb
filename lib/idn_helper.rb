# Copyright 2025 WhatWeb Contributors
# International Domain Name (IDN) Support

module IDNHelper
  def self.normalize_url(url)
    require 'addressable/uri'
    
    uri = Addressable::URI.parse(url.to_s)
    uri.normalize!
    
    # Convert international domains to punycode
    if uri.host && needs_punycode?(uri.host)
      uri.host = Addressable::IDNA.to_ascii(uri.host)
    end
    
    uri.to_s
  rescue => e
    url.to_s  # Fallback to original
  end
  
  def self.needs_punycode?(host)
    host !~ /^[\x00-\x7F]*$/
  end
  
  def self.safe_parse(url)
    require 'addressable/uri'
    Addressable::URI.parse(url.to_s)
  rescue => e
    nil
  end
end
