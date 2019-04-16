module Iodized2RubyClient
  class Client
    def initialize(url)
    end

    def features
      [
        {
          id: 1,
          name: "name",
          active: false
        },
        {
          id: 2,
          name: "name2",
          active: true
        }
      ]
    end
  end
end
