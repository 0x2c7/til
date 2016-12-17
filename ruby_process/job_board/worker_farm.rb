module JobBoarb
  class WorkerFarm
    DEFAULT_WORKER_COUNT = 10

    attr_reader :worker_pools

    def initialize(output_mutex, output_stream, handler, worker_count = DEFAULT_WORKER_COUNT)
      @worker_count = worker_count
      @worker_pools = []
      @jobs = []
      @farm_mutex = Mutex.new
      @handler = handler

      @output_mutex = output_mutex
      @output_stream = output_stream
      setup_pools
    end

    def start
      Thread.new do
        loop { delegate_jobs }
      end
      Thread.new do
        loop { collect_jobs }
      end
    end

    def schedule(command, params = [])
      @farm_mutex.synchronize do
        @jobs << OpenStruct.new(command: command, params: params)
      end
    end

    def clean
      @workers.each do |worker|
        Process.kill(:INT, worker.pid)
      end
    end

    private

    def setup_pools
      @parent_read, children_write = IO.pipe
      @worker_count.times do |index|
        @worker_pools << create_worker(index, @parent_read, children_write)
      end
    end

    def create_worker(worker_id, parent_read, children_write)
      children_read, parent_write = IO.pipe

      worker_pid = fork do
        parent_read.close
        parent_write.close
        loop do
          begin
            job = Marshal.load(children_read)
          rescue EOFError
            next
          end
          result = @handler.call(job.command, *job.params)
          @output_mutex.synchronize do
            @output_stream.puts("Finish job **#{job.command}(#{job.params}) = #{result}** of worker #{worker_id}")
          end
          Marshal.dump({ worker_id: worker_id }, children_write)
        end
      end

      OpenStruct.new(id: worker_id,
                     pid: worker_pid,
                     read_stream: parent_read,
                     write_stream: parent_write)
    end

    def delegate_jobs
      worker = select_worker
      return if worker.nil?
      job = @farm_mutex.synchronize { @jobs.pop }
      return if job.nil?

      @output_mutex.synchronize do
        @output_stream.puts("Job delegated to worker #{worker.id}")
      end
      Marshal.dump(job, worker.write_stream)
      @farm_mutex.synchronize { worker.busy = true }
    end

    def select_worker
      @worker_pools.find { |worker| !worker.busy }
    end

    def collect_jobs
      loop do
        result = Marshal.load(@parent_read)
        worker = @worker_pools.find { |w| w.id == result[:worker_id] }
        @farm_mutex.synchronize do
          worker.busy = false
        end
      end
    end
  end
end
