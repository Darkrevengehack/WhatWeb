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

require_relative 'colour'

#
# Enhanced message handling functions for consistent output throughout WhatWeb
# Provides thread-safe, color-coded messaging with proper severity levels
# Optimized for high-performance scanning with reduced I/O overhead
#

# Message buffer for batch output (performance optimization)
$MESSAGE_BUFFER = []
$MESSAGE_BUFFER_MUTEX = Mutex.new
$MESSAGE_BUFFER_SIZE = 50  # Flush after N messages

#
# Flush message buffer (internal use)
#
def flush_message_buffer
  return if $MESSAGE_BUFFER.empty?
  
  $MESSAGE_BUFFER_MUTEX.synchronize do
    unless $MESSAGE_BUFFER.empty?
      STDERR.puts $MESSAGE_BUFFER.join("\n")
      $MESSAGE_BUFFER.clear
    end
  end
end

#
# Add message to buffer (internal use)
#
def buffer_message(msg)
  $MESSAGE_BUFFER_MUTEX.synchronize do
    $MESSAGE_BUFFER << msg
    flush_message_buffer if $MESSAGE_BUFFER.size >= $MESSAGE_BUFFER_SIZE
  end
end

#
# Display error messages (enhanced with buffering)
#
def error(s)
  return if $NO_ERRORS

  msg = (($use_colour == 'auto') || ($use_colour == 'always')) ? red(s) : s
  
  $semaphore.reentrant_synchronize do
    if defined?($OUTPUT_SYNC) && $OUTPUT_SYNC
      # Immediate output for real-time monitoring
      STDERR.puts msg
    else
      # Buffered output for performance
      buffer_message(msg)
    end
    
    $LOG_ERRORS.out(s) if $LOG_ERRORS
  end
end

#
# Display warning messages (enhanced)
#
def warning(s)
  return if $NO_ERRORS || $QUIET

  msg = (($use_colour == 'auto') || ($use_colour == 'always')) ? yellow(s) : s
  
  $semaphore.reentrant_synchronize do
    if defined?($OUTPUT_SYNC) && $OUTPUT_SYNC
      STDERR.puts msg
    else
      buffer_message(msg)
    end
    
    $LOG_ERRORS.out("WARNING: #{s}") if $LOG_ERRORS
  end
end

#
# Display notice messages (new - for informational messages)
#
def notice(s)
  return if $QUIET

  msg = (($use_colour == 'auto') || ($use_colour == 'always')) ? blue(s) : s
  
  $semaphore.reentrant_synchronize do
    if defined?($OUTPUT_SYNC) && $OUTPUT_SYNC
      STDERR.puts msg
    else
      buffer_message(msg)
    end
  end
end

#
# Display success messages (new - for positive feedback)
#
def success(s)
  return if $QUIET

  msg = (($use_colour == 'auto') || ($use_colour == 'always')) ? green(s) : s
  
  $semaphore.reentrant_synchronize do
    if defined?($OUTPUT_SYNC) && $OUTPUT_SYNC
      STDERR.puts msg
    else
      buffer_message(msg)
    end
  end
end

#
# Display debug messages (new - verbose debugging)
#
def debug(s)
  return unless $WWDEBUG || ($verbose && $verbose > 2)

  msg = (($use_colour == 'auto') || ($use_colour == 'always')) ? grey("[DEBUG] #{s}") : "[DEBUG] #{s}"
  
  $semaphore.reentrant_synchronize do
    STDERR.puts msg  # Always immediate for debugging
  end
end

#
# Environment-aware startup message
#
def display_environment_info
  return if $QUIET
  
  env = WhatWeb::Environment.info
  
  debug "Environment detected:"
  debug "  Ruby: #{env[:ruby_version]}"
  debug "  Platform: #{env[:platform]}"
  debug "  Distribution: #{env[:distro]}"
  debug "  Termux: #{env[:termux]}"
  debug "  Root: #{env[:root]}"
end

# Register cleanup hook to flush buffer on exit
at_exit do
  flush_message_buffer
end
