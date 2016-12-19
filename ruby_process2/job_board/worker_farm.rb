require 'json'

module JobBoarb
  class WorkerFarm
    DEFAULT_WORKER_COUNT = 10

    def initialize(options = {})
      @worker_count = options[:worker_count] || DEFAULT_WORKER_COUNT
      @handler = options[:handler]
      @mutex = Mutex.new

      @result_pipe = IO.pipe
      @job_pipe = IO.pipe

      @logger = options[:logger]

      @workers = []
      create_workers
    end

    def start
      Thread.new { handle_schedule }
      Thread.new { handle_results }
    end

    def schedule(command, params = [])
      job = OpenStruct.new(command: command,
                           params: params,
                           result: nil)
      send(@job_pipe, job)
    end

    private

    def create_workers
      @worker_count.times do |index|
        @workers << create_worker(index)
      end
    end

    def create_worker(worker_id)
      pipe = IO.pipe
      worker_pid = fork do
        @worker_id = worker_id
        @pipe = pipe
        waiting_for_job
      end
      OpenStruct.new(id: worker_id,
                     busy: false,
                     pid: worker_pid,
                     pipe: pipe)
    end

    def waiting_for_job
      loop do
        job = receive(@pipe)
        @logger.info("Job received by worker #{@worker_id}")
        job.result = @handler.call(job.command, *job.params)
        send(@result_pipe, OpenStruct.new(worker_id: @worker_id, job: job))
      end
    end

    def handle_schedule
      loop do
        job = receive(@job_pipe)
        worker = nil
        loop do
          worker = @mutex.synchronize do
            next_worker
          end
          break if worker
        end
        @mutex.synchronize do
          worker.busy = true
        end
        send(worker.pipe, job)
      end
    end

    def handle_results
      loop do
        report = receive(@result_pipe)
        job = report.job
        release(report.worker_id)

        @logger.info("Job finished by worker #{report.worker_id}")
        @logger.info("#{job.command}(#{job.params}) = #{job.result}")
      end
    end

    def release(worker_id)
      worker = @workers.find { |w| w.id == worker_id }
      @mutex.synchronize do
        worker.busy = false
      end
    end

    def next_worker
      @workers.find { |w| !w.busy }
    end

    def send(pipe, data)
      Marshal.dump(data, pipe[1])
    end

    def receive(pipe)
      Marshal.load(pipe[0])
    end
  end
end
