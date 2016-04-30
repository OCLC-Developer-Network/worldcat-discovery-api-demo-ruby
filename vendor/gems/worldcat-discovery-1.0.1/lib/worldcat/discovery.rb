# Copyright 2014 OCLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "equivalent-xml"
require "rdf"
require "rdf/rdfxml"
require "oclc/auth"
require 'rest_client'
require "spira"
require "addressable/uri"

require "worldcat/discovery/configuration"
require "worldcat/discovery/configuration_exception"
require "worldcat/discovery/version"
require "worldcat/discovery/uris"
require "worldcat/discovery/generic_resource"
require "worldcat/discovery/bib"
require "worldcat/discovery/movie"
require "worldcat/discovery/music_album"
require "worldcat/discovery/article"
require "worldcat/discovery/publication_issue"
require "worldcat/discovery/publication_volume"
require "worldcat/discovery/periodical"
require "worldcat/discovery/series"
require "worldcat/discovery/database_list"
require "worldcat/discovery/database"
require "worldcat/discovery/person"
require "worldcat/discovery/place"
require "worldcat/discovery/organization"
require "worldcat/discovery/subject"
require "worldcat/discovery/search_results"
require "worldcat/discovery/bib_search_results"
require "worldcat/discovery/offer_search_results"
require "worldcat/discovery/product_model"
require "worldcat/discovery/review"
require "worldcat/discovery/facet"
require "worldcat/discovery/facet_value"
require "worldcat/discovery/offer"
require "worldcat/discovery/some_products"
require "worldcat/discovery/collection"
require "worldcat/discovery/library"
require "worldcat/discovery/client_request_error"

module WorldCat
  module Discovery
    
    class << self
      
      def configure(api_key, authenticating_institution_id, context_institution_id)
        @config = WorldCat::Discovery::Configuration.instance
        @config.api_key = api_key
        @config.authenticating_institution_id = authenticating_institution_id
        @config.context_institution_id = context_institution_id
      end
      
      def api_key
        @config.api_key
      end
      
      def access_token
        token = @config.access_token
        if token.nil? or token.expired?
          authenticating_institution_id = @config.authenticating_institution_id
          context_institution_id = @config.context_institution_id
          token = @config.api_key.client_credentials_token(authenticating_institution_id, context_institution_id)
          @config.access_token = token
        end
        token
      end
      
      def configured?
        WorldCat::Discovery::Configuration.instance.api_key.nil? ? false : true
      end
      
      def get_data(url)
        # Retrieve the key from the singleton configuration object
        raise ConfigurationException.new unless WorldCat::Discovery.configured?()
        token = WorldCat::Discovery.access_token
        auth = "Bearer #{token.value}"
        
        # Make the HTTP request for the data
        resource = RestClient::Resource.new url
        resource.get(:authorization => auth, 
            :user_agent => "WorldCat::Discovery Ruby gem / #{WorldCat::Discovery::VERSION}",
            :accept => 'application/rdf+xml') do |response, request, result|
          [response, result]
        end
      end
      
    end
  end
end
