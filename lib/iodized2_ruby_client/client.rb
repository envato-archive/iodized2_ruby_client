require 'iodized2_ruby_client/ws_client'
require 'iodized2_ruby_client/features_set'
require 'forwardable'

module Iodized2RubyClient
  class Client
    extend Forwardable

    def_delegators :@features, :features, :enabled?

    def initialize(url, key, secret)
      @features = FeaturesSet.new

      @ws_client = Iodized2RubyClient::WSClient.new(url, key, secret) do |message|
        handle_message(message)
      end
    end

    def handle_message(message)
      puts message
      result = JSON.parse(message)

      key = result.keys.first
      send("handle_#{key}", result[key])
    end

    private

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
  end
end
