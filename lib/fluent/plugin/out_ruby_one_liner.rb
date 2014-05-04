module Fluent
  class Fluent::RubyOneLinerOutput < Fluent::Output
    Fluent::Plugin.register_output('ruby_one_liner', self)
    
    config_param :require_libs, :string,:default => ''
    config_param :command, :string, :default => ''
    config_param :commandfile, :string, :default => ''
    config_param :run_interval, :integer

    def initialize
      super
    end

    def configure(config)
      super
      
      libs = @require_libs.split(',')
      libs.each {|lib| require lib}

      Signal.trap :INT do
        $log.warn 'out_ruby_one_liner: reload commandfile start'
        reload_commandfile!
        $log.warn 'out_ruby_one_liner: reload commandfile end'
      end

      command = if !@command.empty?
        @command
      elsif !@commandfile.empty?
        open(@commandfile).read
      else
        raise ConfigError, "out_ruby_one_liner: command or commandfile is required to be set."    
      end
      @config = config
      @lambda = eval("lambda {|tag, time, record| #{command}}")
      @q = Queue.new
    end

    def start
      super

      @thread = Thread.new(&method(:run))
    rescue
      $log.warn "raises exception: #{$!.class}, '#{$!.message}"
    end

    def shutdown
      super

      Thread.kill(@thread)
    end

    def emit(tag, es, chain)
      es.each {|time, record|
        param = OpenStruct.new
        param.tag = tag
        param.time = time
        param.record = record

        @q.push param
      }

      chain.next
    end

    private
    
    def reload_commandfile!
      command = open(@commandfile).read
      Thread.kill(@thread)
      @lambda = eval("lambda {|tag, time, record| #{command}}")
      @thread = Thread.new(&method(:run))
    end
    
    def run
      loop do
        param = @q.pop
        tag = param.tag
        time = param.time
        record = param.record
        
        begin
          @lambda.call tag, time, record
          sleep @run_interval
        rescue
          $log.warn "raises exception: #{$!.class}, '#{$!.message}, #{param}'"
        end
      end
    end

  end
end
