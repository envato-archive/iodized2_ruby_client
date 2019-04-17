require 'socket'
require 'uri'

require 'websocket/driver'

module Iodized2RubyClient
  class WSClient
    DEFAULT_PORTS = { 'ws' => 80, 'wss' => 443 }

    attr_reader :url, :thread

    def initialize(url, key, secret, &handler)
      @url  = url
      @uri  = URI.parse(url)
      @port = @uri.port || DEFAULT_PORTS[@uri.scheme]

      @tcp  = TCPSocket.new(@uri.host, @port)
      @dead = false

      @driver = WebSocket::Driver.client(self)

      @driver.on(:open)    { |event| authenticate(key, secret) }
      @driver.on(:message) { |event| handler.(event.data) unless heartbeat?(event.data) }
      @driver.on(:close)   { |event| finalize(event) }

      @thread = Thread.new do
        @driver.parse(@tcp.read(1)) until @dead
      end

      @heartbeat = Thread.new do
        loop do
          sleep(20)
          send "_heartbeat"
        end
      end

      @driver.start
    end

    def send(message)
      @driver.text(message)
    end

    def write(data)
      @tcp.write(data)
    end

    def close
      @driver.close
    end

    def finalize(event)
      p [:close, event.code, event.reason]
      @dead = true
      @thread.kill
      @heartbeat.kill
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
