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
      send("handle_#{key}", result[key])
    end

    def enabled?(feature_name)
      feature = @features.find { |feature| feature["name"] == feature_name }
      feature["active"] if feature
    end

    private

    def handle_sync(features)
      @features = features.freeze
    end

    def handle_create(feature)
      @features = (@features.dup << feature).freeze
    end

    # this is essentially a delete, followed by a create
    # but if we simply called them in sequence we would leave a point where a
    # valid feature momentarily disappears from the set of features.
    # so to avoid needing mutexes around each access, we will effectively duplicate
    # those two operations into a single update.
    def handle_update(feature)
      @features = (@features.reject { |f| f["id"] == feature["id"] } << feature).freeze
    end

    def handle_delete(feature)
      @features = @features.reject { |f| f["id"] == feature["id"] }.freeze
    end
  end
end
