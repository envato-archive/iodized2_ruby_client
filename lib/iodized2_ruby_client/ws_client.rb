require "faye/websocket"
require "eventmachine"

module Iodized2RubyClient
  class WSClient
    def initialize(url, key, secret, &handler)
      @heartbeat = Thread.new do
        loop do
          sleep(20)
          puts "💓"
          send "_heartbeat"
        end
      end

      @thread = Thread.new do
        EM.run do
          @ws = Faye::WebSocket::Client.new(url)

          @ws.on :open do |event|
            p :open
            authenticate(key, secret)
          end

          @ws.on :message do |event|
            p [:message, event.data]
            handler.call(event.data) unless heartbeat?(event.data)
          end

          @ws.on :close do |event|
            p :close
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

    def authenticate(key, secret)
      payload = JSON.dump({
        key: key,
        secret: secret
      })
      send "authenticate #{payload}"
    end
  end
end
