require "equivalent-xml"
require "rdf"
require "rdf/rdfxml"
require "oclc/auth"
require 'rest_client'
require "spira"
require "addressable/uri"

require "worldcat/discovery/configuration"
require "worldcat/discovery/version"
require "worldcat/discovery/uris"
require "worldcat/discovery/generic_resource"
require "worldcat/discovery/bib"
require "worldcat/discovery/person"
require "worldcat/discovery/place"
require "worldcat/discovery/organization"
require "worldcat/discovery/subject"
require "worldcat/discovery/search_results"
require "worldcat/discovery/product_model"
require "worldcat/discovery/review"
require "worldcat/discovery/facet_list"
require "worldcat/discovery/facet"
require "worldcat/discovery/facet_value"

module WorldCat
  module Discovery
    
    class << self
      def configure(api_key)
        @config = WorldCat::Discovery::Configuration.instance
        @config.api_key = api_key
      end
      
      def api_key
        @config.api_key
      end 
    end
    
  end
end
