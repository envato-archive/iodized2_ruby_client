require "test_helper"

class Iodized2RubyClientTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Iodized2RubyClient::VERSION
  end

  def test_no_connection_does_not_fail_client_creation
    client = ::Iodized2RubyClient.new("ws://localhost:9999/whatever-it-won't-work", "key", "secret") do |_message|
      fail "We shouldn't receive a message!"
    end
    assert client.status == :connecting

    sleep(10)
    client.close

    assert client.status == :terminated
  end
end
