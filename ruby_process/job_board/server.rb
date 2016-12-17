Thread.abort_on_exception=true
module JobBoarb
  class Server
    def initialize(options)
      @connector = Connector.new(options[:host], options[:port])
      @channel = options[:channel]
    end

    def start(&block)
      read_stream, write_stream = IO.pipe
      mutex = Mutex.new

      @worker_farm = WorkerFarm.new(mutex, write_stream, block)
      Thread.new { handle_jobs }

      puts "Server started with pid #{Process.pid} and #{@worker_farm.worker_pools.count} workers"
      loop { puts read_stream.gets }
    end

    private

    def handle_jobs
      @worker_farm.start
      @connector.subscribe(@channel) do |message|
        next if message['command'].nil?
        @worker_farm.schedule(message['command'], message['params'])
      end
    end
  end
end
