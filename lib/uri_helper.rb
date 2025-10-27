# Copyright 2025 WhatWeb Contributors
# URI Helper for Ruby 3.0+ compatibility

require 'cgi'

module URIHelper
  # Safe URL encoding replacement for URI.escape
  def self.safe_escape(str)
    CGI.escape(str.to_s)
  end
  
  # Safe URL decoding replacement for URI.unescape
  def self.safe_unescape(str)
    CGI.unescape(str.to_s)
  end
  
  # Encode URL component
  def self.encode_component(str)
    CGI.escape(str.to_s).gsub('+', '%20')
  end
  
  # Check if string needs encoding
  def self.needs_encoding?(str)
    str.to_s !~ /^[\x00-\x7F]*$/
  end
end
