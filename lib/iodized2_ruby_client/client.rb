require 'iodized2_ruby_client/ws_client'

module Iodized2RubyClient
  class Client
    attr_reader :features

    def initialize(url)
      @url = url
      @features = []

      @ws_client = Iodized2RubyClient::WSClient.new(@url) do |message|
        handle_message(message)
      end
    end

    def handle_message(message)
      result = JSON.parse(message)

      key = result.keys.first
      send(key, result[key])
    end

    private

    def sync(features)
      @features = features
    end

    def create(feature)
      # TODO: implement-me!
      # @features << feature
    end

    def update(feature)
      # TODO: implement-me!
    end

    def delete(feature)
      # TODO: implement-me!
    end
  end
end
