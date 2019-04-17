require "faye/websocket"
require "eventmachine"

module Iodized2RubyClient
  class WSClient
    def initialize(url, &handler)
      @heartbeat = Thread.new do
        loop do
          sleep(20)
          send "_heartbeat"
        end
      end

      @thread = Thread.new do
        EM.run do
          @ws = Faye::WebSocket::Client.new(url)
          # @ws.on :open do |event|
          #   p [:open]
          #   ws.send('Hello, world!')
          # end

          @ws.on :message do |event|
            handler.call(event.data) unless heartbeat?(event.data)
          end

          @ws.on :close do |event|
            finalize(event)
          end
        end
      end
    end

    def send(message)
      @ws.send(message)
    end

    def close
      @ws.close
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
  end
end
