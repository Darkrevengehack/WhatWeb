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
