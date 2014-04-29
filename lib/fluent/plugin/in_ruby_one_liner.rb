module Fluent
  class Fluent::RubyOneLinerInput < Fluent::Input
    Fluent::Plugin.register_input('ruby_one_liner', self)

    config_param :require_libs, :string,:default => ''
    config_param :command, :string
    config_param :run_interval, :integer

    def initialize
      super
    end

    def configure(config)
      super

      libs = @require_libs.split(',')
      libs.each {|lib| require lib}

      @config = config
      @lambda = eval("lambda {#{@command}}")
    end

    def start
      super
      @thread = Thread.new(&method(:run))
    end

    def run
      loop do
        begin
          @lambda.call
          sleep @run_interval
        rescue
          $log.warn "raises exception: #{$!.class}, '#{$!.message}, #{param}'"
        end
      end
    end

    def shutdown
      Thread.kill(@thread)
    end

  end
end
