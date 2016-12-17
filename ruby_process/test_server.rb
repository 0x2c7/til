require_relative './job_board'

server = JobBoarb::Server.new(
  host: 'localhost',
  port: '6379',
  channel: 'redis-job-board'
)
server.start do |command, one, two|
  sleep(rand(3))
  case command
  when 'add'
    one + two
  when 'subtract'
    one - two
  when 'multiply'
    one * two
  when 'divide'
    one / two
  end
end
