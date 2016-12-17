module JobBoard
  class Client
    def initialize(options)
      @connector = JobBoarb::Connector.new(options[:host], options[:port])
      @channel = options[:channel]
    end

    def delay_work(command, params = [])
      puts "Schedule delay job **#{command} - #{params}**"
      @connector.publish(@channel,
                         command: command,
                         params: params)
    end
  end
end
