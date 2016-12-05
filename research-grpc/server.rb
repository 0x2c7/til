path = File.expand_path('lib', File.dirname(__FILE__))
$LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)

require 'member_services_pb'

class ServiceHandler < MemberService::Service
  def load_member(request, other)
    puts "Request received (under #{request.class.name}): id = #{request.id}"
    MemberReply.new(
      name: "Member ##{request.id}",
      email: 'test@gmail.com'
    )
  end
end

server = GRPC::RpcServer.new
server.add_http2_port("localhost:50052", :this_port_is_insecure)
server.handle(ServiceHandler)
server.run_till_terminated
