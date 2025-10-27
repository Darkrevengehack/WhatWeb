# Copyright 2025 WhatWeb Contributors
# Performance Monitoring

module PerformanceMonitor
  @stats = {
    requests: 0,
    errors: 0,
    start_time: Time.now,
    plugin_times: Hash.new(0)
  }
  
  class << self
    attr_reader :stats
    
    def record_request
      @stats[:requests] += 1
    end
    
    def record_error
      @stats[:errors] += 1
    end
    
    def record_plugin_time(plugin, duration)
      @stats[:plugin_times][plugin] += duration
    end
    
    def report
      elapsed = Time.now - @stats[:start_time]
      requests_per_sec = @stats[:requests] / elapsed
      
      puts "\n" + "="*50
      puts "Performance Report"
      puts "="*50
      puts "Total requests: #{@stats[:requests]}"
      puts "Total errors: #{@stats[:errors]}"
      puts "Elapsed time: #{elapsed.round(2)}s"
      puts "Requests/sec: #{requests_per_sec.round(2)}"
      
      if $verbose && $verbose > 1
        puts "\nTop 10 slowest plugins:"
        @stats[:plugin_times].sort_by { |_k, v| -v }.first(10).each do |plugin, time|
          puts "  #{plugin}: #{time.round(3)}s"
        end
      end
      
      puts "="*50
    end
  end
  
  at_exit { report if $verbose && $verbose > 0 }
end
