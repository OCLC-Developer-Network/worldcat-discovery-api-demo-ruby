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

module WorldCat
  module Discovery
    class Offer < Spira::Base
      
      property :display_position, :predicate => GOOD_RELATIONS_POSITION, :type => XSD.integer
      property :type, :predicate => RDF.type, :type => RDF::URI
      property :item_offered, :predicate => SCHEMA_ITEM_OFFERED, :type => 'SomeProducts'

      # call-seq:
      #   find_by_oclc(oclc_number, params = nil) => WorldCat::Discovery::SearchResults
      # 
      # Returns a search result set containing Offer resources for the given input parameters
      #
      # [oclc_number] an integer representing the OCLC number to retrieve holdings/offers
      # 
      # Parameters
      # 
      # [:tbd] TBD
      def self.find_by_oclc(oclc_number, params = nil)
        uri = Addressable::URI.parse("#{Offer.production_url}/oclc/#{oclc_number}")
        uri.query_values = params
        response = get_data(uri.to_s)
        
        # Load the data into an in-memory RDF repository, get the GenericResource and its Bib
        Spira.repository = RDF::Repository.new.from_rdfxml(response)
        search_results = Spira.repository.query(:predicate => RDF.type, :object => DISCOVERY_SEARCH_RESULTS).first.subject.as(OfferSearchResults)
        
        # WorldCat::Discovery::SearchResults.new
        search_results
      end
      
      # # call-seq:
      # #   find(oclc_number) => WorldCat::Discovery::Bib
      # # 
      # # Returns a Bib resource for the given OCLC number
      # #
      # # [oclc_number] the WorldCat OCLC number for a bibliographic resource
      # def self.find_by_oclc(oclc_number)
      #   url = "#{Bib.production_url}/oclc/#{oclc_number}"
      #   response = get_data(url)
      # 
      #   # Load the data into an in-memory RDF repository, get the GenericResource and its Bib
      #   Spira.repository = RDF::Repository.new.from_rdfxml(response)
      #   generic_resource = Spira.repository.query(:predicate => RDF.type, :object => GENERIC_RESOURCE).first
      #   bib = generic_resource.subject.as(GenericResource).about
      #   
      #   bib
      # end
      
      protected
      
      def self.production_url
        "https://beta.worldcat.org/discovery/offer"
      end
      
      # def self.get_data(url)
      #   # Retrieve the key from the singleton configuration object
      #   raise ConfigurationException.new unless WorldCat::Discovery.configured?()
      #   wskey = WorldCat::Discovery.api_key
      #
      #   # Make the HTTP request for the data
      #   auth = wskey.hmac_signature('GET', url)
      #   resource = RestClient::Resource.new url
      #   resource.get(:authorization => auth,
      #       :user_agent => "WorldCat::Discovery Ruby gem / #{WorldCat::Discovery::VERSION}",
      #       :accept => 'application/rdf+xml')
      # end
      
      def self.get_data(url)
        # Retrieve the key from the singleton configuration object
        raise ConfigurationException.new unless WorldCat::Discovery.configured?()
        token = WorldCat::Discovery.access_token
        auth = "Bearer #{token.value}"
        
        # Make the HTTP request for the data
        resource = RestClient::Resource.new url
        resource.get(:authorization => auth, 
            :user_agent => "WorldCat::Discovery Ruby gem / #{WorldCat::Discovery::VERSION}",
            :accept => 'application/rdf+xml') 
      end
      
    end
  end
end
      
