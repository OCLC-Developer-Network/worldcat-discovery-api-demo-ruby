require "singleton"

module WorldCat
  module Discovery
    class Configuration
      
      include Singleton
      attr_accessor :api_key
      
    end
  end
end