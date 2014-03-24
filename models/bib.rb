module WorldCat
  class BibliographicResource < WorldCat::Resource
    
    def initialize(options = {})
      if options[:id]
        url = "#{ENV['base_url']}/discovery/bib/search?q=no:#{options[:id]}"
        auth = API_KEY.hmac_signature('GET', url)
        resource = RestClient::Resource.new url
        response = resource.get(:authorization => auth, :accept => 'application/json')
        @data = JSON.parse(response)
      elsif options[:data]
        @data = options[:data]
      end
      super()
    end
    
    def self.new_from_hash(hash)
      bib = BibliographicResource.new(:data => hash)
    end
    
    def self.search(params)
      url = "#{ENV['base_url']}/discovery/bib/search?q=#{CGI.escape(params[:q])}"
      auth = API_KEY.hmac_signature('GET', url)
      resource = RestClient::Resource.new url
      response = resource.get(:authorization => auth, :accept => 'application/json')
      
      results = WorldCat::ResultSet.new( JSON.parse(response), WorldCat::BibliographicResource )
      results
    end
    
  end
end