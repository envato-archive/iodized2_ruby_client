require 'socket'
require 'uri'

require 'websocket/driver'

# we want to succeed with creation even if we can't open the TCP socket
# - do we need to defer this to some thread?
# we want to be able to handle being terminated from the server-side and attempt to
# reconnect (depending on why it failed)

module Iodized2RubyClient
  class WSClient
    DEFAULT_PORTS = { 'ws' => 80, 'wss' => 443 }

    attr_reader :url, :thread, :status

    def initialize(url, key, secret, &handler)
      @url  = url
      @uri  = URI.parse(url)
      @port = @uri.port || DEFAULT_PORTS[@uri.scheme]

      @tcp  = TCPSocket.new(@uri.host, @port)
      @dead = false

      @driver = WebSocket::Driver.client(self)

      @driver.on(:open)    { |event| authenticate(key, secret) }
      @driver.on(:message) { |event| handler.call(event.data) unless heartbeat?(event.data) }
      @driver.on(:close)   { |event| finalize(event) }

      @thread = Thread.new do
        @driver.parse(@tcp.read(1)) until @dead
      rescue
        puts "🙁 driver thread is exiting with exception"
        @heartbeat.kill if @heartbeat
      end

      @heartbeat = Thread.new do
        until @dead do
          sleep(20)
          puts "💓"
          send "_heartbeat"
        end
      rescue
        puts "🙁 heartbeat thread is exiting with exception"
        @thread.kill
      end

      @driver.start
      @status = :ok
    end

    def send(message)
      @driver.text(message)
    end

    def write(data)
      @tcp.write(data)
    end

    def close
      @status = :closed
      @driver.close
    end

    def finalize(event)
      p [:close, event.code, event.reason]
      @dead = true
      @thread.kill
      @heartbeat.kill
    end

    def join
      @thread.join
      @heartbeat.join
    end

    private

    def heartbeat?(data)
      data == '❤️'
    end

    def authenticate(key, secret)
      payload = JSON.dump({
        key: key,
        secret: secret
      })
      send "authenticate #{payload}"
    end
  end
end
