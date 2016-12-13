# Introduction to gRPC
## Introduction
- Microservice approach is mentioned every where at the moment. It is considered to be the exit for the Monolith applications. However, it is not for the beginner because when moving from the simple monolith application, you will meet a lot of other problems that need to solved. Those problems are not the business logic, but the technical side. One of them is how the services communicate with each other. I'm a beginner to the mirco service world. So, I'm having a little research as well as benchmarking so that I could learn and apply for the projects at the company if possible (yup company environment only, who needs microservice for a side project?). So let's begin.
- When I mention about the communication between microservices, perhaps the first thing popping in your head is REST API. And yes, it is the most popular way implemented to be the standard for service communication. It has bunch of advantages. For example, it is really easy and familiar with any developer, or it is highly compatible, supported in any frameworks in any programming language. However, REST API is based on client-server model. It is perfectly fit for that purpose. In the microservice world, the communication we are talking about here is server-server communication. So, REST API exposes some significant flaws. It is One-way communication, one server is the requester, other one is the responser. The server could respond anything it wants and hope the client could parse it. It becomes a potential error, especially deeply nested object. The second thing is that when the data needed to be transfer becomes huge, REST API becomes costly. It is caused due to the serialization and deserialization process. The server must load all data, serialize it and send back to the client. If we paginate it, it is much more slower since everything under the transportation layer must to be set up from the beginning. No way to reuse these effort. In fact, there are some other flaws in the design of REST API that I could not mention here (actually, I have just recently think about these two only :p)
- There are many other alternative standard born to solve the problems with REST API. One of them is Remove Procecure Call (RPC). It is just a general name for the mechanism the way a service fetches information from other services is just simple as calling an internal method. It is an open concept. So, there are many organisation joins in this play. gRPC is one of them. This RPC framework is developed by Google and its programing community. It is now one of the most popular RPC implementation in the market. So I'll focus on researching this framework first.

## How gRPC works?
- gRPC is a remote proceduce framework, backed by Google. It simplify the external communication between services as if it is a local object.
- The basic concept of gRPC is to define a service on the server callee (server) side, specify the methods the service could serve, the calling parameters and corresponding return types for each method. On the caller (client) side, gRPC provides a stub, which is the interface so that the client just needs to call method with the same name as it defined in the callee side.
- gRPC officially supports the all popular languages
- In the gRPC world, the matching of method parameters and return types is enforced. By default, gRPC use protocol buffer to define those information. Protocol buffer files (with `.proto` extention) are written with a simple programming language similar to Java called `proto` (https://developers.google.com/protocol-buffers/docs/proto3). Each protocol buffer files include the structure and type of exchanging messages, definition of supported method and a pair of request and return message the method use. This is a typical protocol buffer file:
```proto3
message MembersRequest {
  repeated int64 ids = 1;
}
message MembersReply {
  message MemberInfo {
    int64 id = 1;
    string name = 3;
    string email = 4;
  }
  repeated MemberInfo members = 1;
}
service AwesomeService {
  rpc LoadMember ( MembersRequest ) returns ( MembersReply ) {}
}
```

The above file indicates that the `AwesomeService` could handle `LoadMember` method. That method requires `MembersRequest` param, which wraps over an int64 array. The response is always `MembersReply` attached with an `MemberInfo` array under the key `members`.

- This protocol buffer file has nothing but the communication convention between services. If some services want to call `LoadMember` method in the `AwesomeService`, it must follow the rule described in the file. Otherwise, the connecting could not be procedured. At the beginning, this convention is a little strick. When we want to add more features, we have to edit in client, server and `proto` files. However, when the amount of services increases and the communication between them becomes much more complicated, this approach help us reduce the messy and potential bug problem caused with normal JSON. The gRPC helps us validate the incoming data and ensure the request provides right data structure. We don't need the annoying boiler-plate for those works anymore.

- Microservice is the world of different services written in high variety of programming languages. Each language has its own specifications and specific features. To ease the pain of implementing the same feature on different languages, gRPC help us a lot by providing extension for main streams programming languages like Ruby, Python, Java, Go, etc... And to load and apply the protocol buffers into our project, gRPC tool set provides a tool to compile `proto` files into the specification for the programming language we are using. We just need to include those specifications directly and gRPC takes care the rest for us.

- Language specified protocol buffer supporting is just the beginning of the whole story of gRPC. The real strength of gRPC lies at the data transpotation mechanism. This is a story about how my dream cluster works. Service `A` is written in Golang, Service `B` is written in Ruby. I define a `proto` file, then compile this file into `service_pb.go` for service `A`, and `service_pb.rb` for service `B`. Service `A` wants to get the data from service `B`. So, service use the SDK that gRPC provides to start a `RPC server` on a specific port, let's assume it `50051`. This server could be treated as a normal web server. At the beginning of the information fetching, service `A` delegate the gRPC to call method `LoadMember` from service `B` with request object created from `service_pb.go`. This object is serialized with protocol buffer, and push to the transportation layer to send to service `B`. Service `B`'s gRPC server receive the message, deserialize the requeest and trigger the handling logic to handle the request. Then, it creates a response object using `service_pb.rb`, serialize it, push to transportation layer to send back to service `A`. Service `A` get the response, deserialize again andgot the final response with response object form using `service_pb.go`. That's the whole process of a simple call.

- The above flow has something different, in which I think it is much more better than the traditional REST api call.
  - The client side (service `A`) create request object (pure Golang) and calls the gRPC directly. The server side receive the request object (pure Ruby), process it and push resposne object (pure Ruby) into gRPC. Then, service `A` receive resposne object again (pure Golang again). As you see, there is absolute no manual serialization and deserialization here. Service `A` send and receive pure golang object and the same as Server `B` with Ruby. gRPC do that dirty work for us. And before giving us the request and response object, it validates those data. So, we need to focus on the logic only. And by automatically convert the data into direct access object for the current programming language, the service could do this: `response.ids` and `request.memebrs[12].id`. And this way of data access is gruanteed by the gRPC.
  - The serialization and deserialization is conducted with protocol buffer. It is high-speed engine developed by google. The serialized data is under binary format and unreadable by human. That decreaases the time spent on this process dramaticcally and descrease the time needed to change the data. In case the data is huge, this improvement has significant impact on the overall result
  - No more API post / get boiler plate.
  - The availability of stream. (Gonna talk about this later. But it is awesome).

## Simple demo
### Simple demo with plain Ruby
To make everything easy at the beginning. Let's written everything in plain Ruby. To get started. You need to create 3 folders and corresponding blank files:
```
|_ server.rb
|_ client.rb
|_ member.proto
```
By convention, the `client.rb` file implements a simple server that intervally request to data service (`server.rb`) to query some information. They both follows the same interface writen in `member.proto`. Let's start with the proto file. Assume that the `member.proto` content is like bellow:

```proto3
syntax = "proto3";

message MemberRequest {
  int64 id = 1;
}

message MemberReply {
  string name = 1;
  string email = 2;
}

service MemberService {
  rpc LoadMember ( MemberRequest ) returns ( MemberReply ) {}
}
```

This is pretty simple. Client user MemberRequest, the server use MemberReply. They both use `LoadMember` (alias `load_member` in ruby convention). The number behind the attributes in message difinition is the order of aguments in static type languages (like C++, C#, etc.). We are working on Ruby, so we don't have to worry about that

To use this specification, we must compile this `.proto` file into ruby so thate the client and server could use them. The Ruby compiling process is conducted with a plugin written by Google. So, we'll install that gem:
```
gem install gprc-tools
```
Now, run the following command to compile this file:
```
grpc_tools_ruby_protoc --proto_path=./ --ruby_out=./lib --grpc_out=./lib **/*.proto
```
The following command reads the `.proto` file and generate ruby-specified library. Each `proto` file includes two parts: message definition and method definition. They are usually put into two different files so that other methods could re-use the message definition. By default, when running above comamnds, you get:
```
|_ lib
| |_ member_pb.rb
| |_ member_services_pb.rb
|_ member.proto
```
Let's implement the server side. At the beginning, we should load the generated file into our source code:
```ruby
path = File.expand_path('lib', File.dirname(__FILE__))
$LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
require 'member_services_pb'
```
Having a look at the generated `member_services_pb` file, we realise that the generator generates a class `MemberService::Service` that contains the nothing but some configs and method template. There is no logic to handle the requests here. The gRPC framework lets us handle every logic. To acheive that, we inherit the `MemberService::Service` and add the handling logic into it.
```ruby
class ServiceHandler < MemberService::Service
  def load_member(request, other)
    puts "Request received (under #{request.class.name}): id = #{request.id}"
    MemberReply.new(
      name: "Member ##{request.id}",
      email: 'test@gmail.com'
    )
  end
end
```
This is just a simple demo to return a dummy data. As I mentioned above, the request is casted into `MemberRequest` object so that we could access the attributes directly. No need to deserialize here. The logic here is pretty simple. Next, we just need to start the RPC servce.
```ruby
server = GRPC::RpcServer.new
server.add_http2_port("localhost:50051", :this_port_is_insecure)
server.handle(ServiceHandler)
server.run_till_terminated
```
The server gonna running on `localhost` with port `50051`. The `:this_port_is_insecure` part indicates that this server is not protected. Anyone that knows the server address could connect and fetch the data with ease. gRPC provides some mechanism to protect this vulnerability like Self-sign certification. We'll talk about this later.

Let's start the server on with a simple comment: `ruby server.rb`. The server is now ready to handle requests. Let's continue with the client side. Well, the clinent side is much much much more simpler. Like above, we need to require the `member_services_pb`. Then the main logic just need:
```ruby
loop do
  stub = MemberService::Stub.new(
    "localhost:50052",
    :this_channel_is_insecure
  )
  result = stub.load_member(MemberRequest.new(id: rand(1..1000)))
  puts "Reply received (under #{result.class.name}): name = #{result.name}, email = #{result.email}"
  sleep(1)
end
```
The real logic is just this line: `result = stub.load_member(MemberRequest.new(id: rand(1..1000)))`. It sends a `MemberRequest` instance which contains a random id number to the server. Then, it received a `MemberReply` response. So that we could access the attributes directly like above. And now we start the client with `ruby client.rb`. And hooya. Everything works like charm.

### Apply gRPC in Rails project
Basically, Rails is just a framework of Ruby. So, everything works the same as it does with plain Ruby. The addtional part is that we need to initialize Rails before starting the RPC server so that it could use everything in the rails project. It is this simple:
```ruby
require 'rails/all'
require File.expand_path('../config/environment', File.dirname(__FILE__))
```
However, if something went wrong, it fails in silence without any log. So, we need to add the logger into both Rails project and GRPC itself:
```ruby
module GRPC
  def self.logger
    Logger.new(STDOUT)
  end
end
ActiveRecord::Base.logger = Logger.new(STDOUT)
```

### Applying RPC into my company's project
Microservices and gRPC is a new approach for my company to move the whole system to. The previous stack depends on Heroku. They provides many useful utilities that save us a lot of cost at the beginning. As the time flies, it is too hard for the expansion because Heroku provoked a lot of freedom. Subsequently, we are moving our infrastructure to AWS. At first, the new features are implemented in new services. Then, we gradually extract the modules in the main Monolith application into services. At the moment, we are just at the beginning step. So, Heroku application is still there for most requests. What we are setting up here is one RPC server to gather information from main app. It is actually in our AWS cluster. It connect to a replication of Heroku's database and totally isolated with the main application. Every other services call RPC requests to this RPC server. In the main Heroku application, it delegates stuff to services via RPC too. It is fortune that Heroku allows external RPC call. So everything is fine until now. And we got some interesting benchmarking.

#### Services to Services
- Average request: 1.5 ms
- Median request: 1.2 ms
- Fasted request: 0.5 ms
- Slowest request: 7 ms
- 95% request time: 4ms

#### Heroku main app to services
- Average request: 6.5 ms
- Median request: 7 ms
- Fasted request: 3 ms
- Slowest request: 20 ms
- 95% request time: 7 ms

The RPC calls from Heroku main app is slow because it is out of our control. We could not do anything about it. This result is acceptable for us. So, perhaps we'll follow RPC for production :)

## Security with SSL
GRPC provides some security machanisms. SSL approach is the one that I like most. Following the SSL machanism used widely in the server world, the GRPC server holds a pair of Private Key and Certificate (sometimes called public key) and the GRPC client hold the same Certificate too. At the beginning of the transportation process, the server sends a digital certificate which are the connection encrytion information encrypted with the Certificate. The client decrypts and verifies the server. Then, it generates a session key, encrypt with the certificate and sends back to the server. The server decrypts it with Private key and confirm the connection is secure. From now, all the data transported are encrypted with the session key. Unlike the normal SSL connection between browser and the web server, we don't need a middleman to verify the participants in the connection establishment since all the participants are internal services under our control. Therefore, we could generate the Private key and the Certificate ourselves with Self-Sign SSL.

To start with, let's genereate the essential security stuffs for the secure connection:
- The first command genereates the Private Key with the length 4096 bit and open for the later process.
- The second command generates the Certificate baesd on the Private key. The Certifcate is created with a particular amount of time (10 years in the example) and some meta information.
- The last command is to cencrypt the Private key for security reason.

```bash
openssl genrsa -passout pass:1111 -des3 -out server.key 4096
openssl req -passin pass:1111 -new -x509 -days 3650 -key server.key -out server.crt -subj '/C=US/ST=NY/L=NYC/O=SomeCompany/CN=localhost/emailAddress=devops@somecompany.com'
openssl rsa -passin pass:1111 -in server.key -out server.key
```
After creating two files (`server.key` and `server.crt1)`, we could start using it right now. In the GRPC Server, instead of using `:this_channel_is_insecure`, `GRPC` provides us `Credentials` classes to support this. In the server side, add this part into the code:

```ruby
  credentials = GRPC::Core::ServerCredentials.new(
    nil,
    [{
      private_key: File.read('server.key'),
      cert_chain: File.read('server.crt')
    }],
    true
  )
  server = GRPC::RpcServer.new
  server.add_http2_port('0.0.0.0:50051', credentials)
```

In the client side, we need to configure the SSL too, add this code to the client:

```ruby
  credentials = GRPC::Core::Credentials.new(File.read('server.crt'))
  client = FortuneService::Stub.new('127.0.0.1:50051', creds: credentials)
```

And done :D. Everything works like charm for now. If someone holds the host and the port the gRPC server, they could not access withou the Private key and Certificate.

## Streaming
In almost offically supporting languages, gRPC supports the cool feature: Streaming. This features bring gRPC much further in the race with HTTP. The default behaviour of HTTP is response-request. Which means that we receive a complete request and then process it and response. This approach has some particular flaws. The most critical one is that it is super costly when the transported data is huge. It must load everything in the memory, serialize a huge data size and then send a huge bunch of file via the network. That huge data chunk must be deserialized, loaded everything into memory again. The requester must wait for a long time before actually receive it and it is costly to process that huge size of data at once. This could be fixed if we apply pagination, batching transporation, or even using HTTP streaming. However, it increases the unnecessary compexity of the whole service. By supporting gRPC out of the box, gRPC simplify the painful part of transportation process as well as decrease the processing time for both clinent and server.

gRPC supports three types of streaming:
- Client streaming ( client sends a big amount of data to server via Streaming )
- Server streaming ( server respones a big amount of data to client via streaming )
- Bio streamingg ( clients sends a big amount of data to server via Streaming, server receives each item, process it and sends each response back in the response stream )

To identicate the streaming feature, we just need to add one word into the `proto` file:
```proto
  # Client streaming
  rpc LoadMember ( stream MemberRequest ) returns ( MemberReply ) {}
  # Server streaming
  rpc LoadMember ( MemberRequest ) returns ( stream MemberReply ) {}
  # Bio streaming
  rpc LoadMember ( stream MemberRequest ) returns ( stream MemberReply ) {}
```
And that's it. So simple :). To add the straming support in Ruby, we apply Enumerable pattern when sending the data. In the client side, to send the streaming data, we wrap it with Enumarator instance:
```ruby
stub.load_member(
  Enumerator.new do |yielder|
    3.times do |n|
      yielder << MemberRequest.new(id: n)
    end
  end
)
```

Everything works like charm. In the server side, to sends the streaming data, we do the same things

```ruby
def load_member(request)
  some_responses = CalculateResponse.call(request)
  Enumerator.new do |yielder|
    some_responses.each do |response|
      yielder << MemberReply.new(response)
    end
  end
end
```

In case bio-streaming is implemeneted, we just need this in the server side:

```ruby
  def load_member(requests, _other = nil)
    Enumerator.new do |yielder|
      requests.each do |request|
        some_responses = CalculateResponse.call(request)
        some_responses.each do |response|
          yielder << MemberReply.new(response)
        end
      end
    end
  end
```

As you can see, everything is independent with each other. Therefore, we could apply parallel computing here to decrease the processing time:

```ruby
  def load_member(requests, _other = nil)
    Enumerator.new do |yielder|
      Parrallel.each(requests) do |request|
        some_responses = CalculateResponse.call(request)
        some_responses.each do |response|
          yielder << MemberReply.new(response)
        end
      end
    end
  end
```

## Parrallel handling
Typically, a service needs many data from different source. It trigger gRPC calls multiple times. Each call adds up the final response time of the request. It is a bad idea to let the grPC calls processed sequently. Thereforee, applying parallel calling is a good idea. In ruby, we could use `Parallel` gem for this job. It does a great things after all.

```ruby
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
```
By using this, all the data are retrieved in parallel. After all data are fetched, it is composed into one single hash to use later.
