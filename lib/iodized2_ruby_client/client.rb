require 'iodized2_ruby_client/ws_client'
require 'iodized2_ruby_client/features_set'
require 'forwardable'

module Iodized2RubyClient
  class Client
    extend Forwardable

    def_delegators :@features, :features, :enabled?

    attr_reader :status

    def initialize(url, key, secret)
      @features = FeaturesSet.new

      connect_web_socket(url, key, secret)
    end

    def close
      case status
      when :connecting then @supervisor.kill
      when :running then @ws_client.close
      else
        # nothing to do we are not in a state that needs cleanup
      end
      @status = :terminated
    end

    private

    def handle_message(message)
      puts message
      result = JSON.parse(message)

      key = result.keys.first
      send("handle_#{key}", result[key])
    end


    def handle_sync(features)
      @features.sync_features(features)
    end

    def handle_create(feature)
      @features.add_feature(feature)
    end

    def handle_update(feature)
      @features.update_feature(feature)
    end

    def handle_delete(feature)
      @features.delete_feature(feature)
    end

    def connect_web_socket(url, key, secret)
      @status = :connecting
      @supervisor = Thread.new do
        backoff = nil
        begin
          sleep(backoff / 100.0) if backoff
          @ws_client = Iodized2RubyClient::WSClient.new(url, key, secret) do |message|
            handle_message(message)
          end
          @status = :running
          backoff = nil
          @ws_client.join
          puts "ws_client ended...what now?"
          @status = :terminated if @ws_client.status == :closed
        rescue Errno::ECONNREFUSED => e
          puts e
          backoff ||= 1
          backoff <<= 1
          puts "Backoff is now #{backoff / 100.0} seconds"
          next
        rescue => e
          @status = :failed
          @error = e
        end while ![:terminated, :failed].include?(@status)
      end
    end
  end
end
