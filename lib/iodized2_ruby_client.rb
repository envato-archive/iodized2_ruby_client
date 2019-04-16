require "iodized2_ruby_client/version"
require "iodized2_ruby_client/client"

module Iodized2RubyClient
  class Error < StandardError; end

  def self.new(url)
    Client.new(url)
  end
end
