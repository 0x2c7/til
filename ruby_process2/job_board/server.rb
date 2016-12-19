require 'logger'

Thread.abort_on_exception = true
module JobBoarb
  class Server
    def initialize(options)
      @connector = Connector.new(options[:host], options[:port])
      @channel = options[:channel]
      @farm = WorkerFarm.new(logger: logger,
                             handler: options[:handler],
                             worker_count: options[:worker_count])
    end

    def start
      @farm.start
      logger.info "Server is running with pid #{Process.pid}"

      @connector.subscribe(@channel) do |message|
        @farm.schedule(message['command'], message['params'])
      end
    end

    private

    def logger
      @logger ||= Logger.new(STDOUT)
    end
  end
end
