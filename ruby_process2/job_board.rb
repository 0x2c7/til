$LOAD_PATH.unshift(File.expand_path('./job_board/', '.'))
require 'byebug'

module JobBoarb
  HOST = 'localhost'
  PORT = '6379'
end

require 'connector'
require 'worker_farm'
require 'server'
require 'client'
