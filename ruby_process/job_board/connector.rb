require 'socket'
require 'JSON'

module JobBoarb
  class Connector < TCPSocket
    PACKAGE_SIZE_PATTERN = /^\*([0-9]+)$/

    def publish(channel, message)
      write("PUBLISH #{channel} '#{message.to_json}'\n")
    end

    def subscribe(channel)
      raise 'Please provide a block for this method' unless block_given?

      write("SUBSCRIBE #{channel}\n")
      raise 'Could not subscribe' unless subscribed?(channel)

      loop do
        package = read_package
        next unless pubsub?(package, channel)
        yield JSON.parse(package[2])
      end
    end

    private

    def read_package
      size = read_package_size
      return [] unless size

      [].tap do |results|
        size.times do
          results << read_package_chunk
        end
      end
    end

    def read_package_size
      size = readline
      matches = PACKAGE_SIZE_PATTERN.match(size)
      return unless matches
      matches[1].to_i
    end

    def read_package_chunk
      # We don't need this line
      readline
      # The real content we need
      readline
    end

    def readline
      gets("\n").chomp("\n")
    end

    def subscribed?(channel)
      _size = read_package_size
      cmd = read_package_chunk
      confirm_channel = read_package_chunk
      readline
      cmd == 'subscribe' && confirm_channel == channel
    end

    def pubsub?(package, channel)
      package[0] == 'message' && package[1] == channel
    end
  end
end
