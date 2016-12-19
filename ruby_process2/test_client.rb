require_relative './job_board'

client = JobBoard::Client.new(
  host: 'localhost',
  port: '6379',
  channel: 'redis-job-board'
)

loop do
  commands = [:add, :subtract, :multiply, :divide]
  client.delay_work(commands[rand(0..3)], [rand(1..1000), rand(1..1000)])
  sleep(0.1)
end
