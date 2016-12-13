path = File.expand_path('lib', File.dirname(__FILE__))
require 'logger'
$LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)

require 'member_services_pb'

module GRPC
  def self.logger
    Logger.new(STDOUT)
  end
end

class ServiceHandler < OrderService::Service
  def load_order(requests, _other = nil)
    Enumerator.new do |yielder|
      requests.each do |request|
        puts "Request received: id = #{request.id}"
        amount = rand(1..15)
        puts "Response with #{amount}"
        amount.times do |n|
          sleep(1)
          yielder << OrderReply.new(
            number: "Order #{amount} - #{request.id} - #{rand(1..10000)}"
          )
        end
      end
    end
  end
end

server = GRPC::RpcServer.new
server.add_http2_port("localhost:50053", :this_port_is_insecure)
server.handle(ServiceHandler.new)
server.run_till_terminated
