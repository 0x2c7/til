path = File.expand_path('lib', File.dirname(__FILE__))
$LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)

require 'grpc'
require 'logger'
require 'parallel'
require 'member_services_pb'

stub = MemberService::Stub.new(
  'localhost:50052',
  :this_channel_is_insecure
)

stub2 = OrderService::Stub.new(
  'localhost:50053',
  :this_channel_is_insecure
)

enum = Enumerator.new do |yielder|
  3.times do |n|
    yielder << MemberRequest.new(id: n)
  end
end

enum2 = Enumerator.new do |yielder|
  3.times do |n|
    yielder << MemberRequest.new(id: n)
  end
end

results = Parallel.map(
  [
    [stub, :load_member, enum],
    [stub2, :load_order, enum2]
  ]
) do |s, method, params|
  result = s.send(method, params)
  result.to_a.map(&:to_h)
end

puts results.inspect
