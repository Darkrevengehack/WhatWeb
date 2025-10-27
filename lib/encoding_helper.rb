# Copyright 2025 WhatWeb Contributors
# Encoding Helper for UTF-8 safety

module EncodingHelper
  # Safely convert to UTF-8
  def self.safe_utf8(str)
    return '' if str.nil?
    
    str.force_encoding('UTF-8')
       .encode('UTF-8', invalid: :replace, undef: :replace, replace: '?')
  rescue => e
    ''
  end
  
  # Clean binary data
  def self.clean_binary(str)
    return '' if str.nil?
    
    str.force_encoding('BINARY')
       .encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
  rescue => e
    ''
  end
  
  # Detect if string is valid UTF-8
  def self.valid_utf8?(str)
    str.force_encoding('UTF-8').valid_encoding?
  rescue
    false
  end
end
