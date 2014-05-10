module WorldCat
  module Discovery
    class ConfigurationException < RuntimeError
      
      MESSAGE = 'Cannot find Bib resources unless an API key is configured. Call WorldCat::Discovery.configure(wskey) with an OCLC::Auth::WSKey'
      
      def message
        MESSAGE
      end
    end
  end
end