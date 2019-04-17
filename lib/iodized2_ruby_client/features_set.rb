module Iodized2RubyClient
  class FeaturesSet
    attr_reader :features

    def initialize
      @features = []
    end

    def enabled?(feature_name)
      feature = @features.find { |feature| feature["name"] == feature_name }
      feature["active"] if feature
    end

    def sync_features(features)
      @features = features.freeze
    end

    def add_feature(feature)
      @features = (@features.dup << feature).freeze
    end

    # this is essentially a delete, followed by a create
    # but if we simply called them in sequence we would leave a point where a
    # valid feature momentarily disappears from the set of features.
    # so to avoid needing mutexes around each access, we will effectively duplicate
    # those two operations into a single update.
    def update_feature(feature)
      @features = (@features.reject { |f| f["id"] == feature["id"] } << feature).freeze
    end

    def delete_feature(feature)
      @features = @features.reject { |f| f["id"] == feature["id"] }.freeze
    end
  end
end
