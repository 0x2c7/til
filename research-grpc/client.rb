path = File.expand_path('lib', File.dirname(__FILE__))
$LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)

require 'member_services_pb'

loop do
  stub = MemberService::Stub.new(
    "localhost:50052",
    :this_channel_is_insecure
  )
  result = stub.load_member(MemberRequest.new(id: rand(1..1000)))
  puts "Reply received (under #{result.class.name}): name = #{result.name}, email = #{result.email}"
  sleep(1)
end
