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
      @features << feature
    end

    def update(feature)
      index = @features.index { |f| f["id"] == feature["id"] }
      @features[index] = feature if index
    end

    def delete(feature)
      @features = @features.reject { |f| f["id"] == feature["id"] }
    end
  end
end
