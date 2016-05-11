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
        response, result = WorldCat::Discovery.get_data(uri.to_s)
        
        if result.class == Net::HTTPOK
        # Load the data into an in-memory RDF repository, get the GenericResource and its Bib
          Spira.repository = RDF::Repository.new.from_rdfxml(response)
          search_results = Spira.repository.query(:predicate => RDF.type, :object => DISCOVERY_SEARCH_RESULTS).first.subject.as(OfferSearchResults)
        
          # WorldCat::Discovery::SearchResults.new
          search_results
        else
          Spira.repository = RDF::Repository.new.from_rdfxml(response)
          if Spira.repository.query(:predicate => RDF.type, :object => CLIENT_REQUEST_ERROR).first
            client_request_error = Spira.repository.query(:predicate => RDF.type, :object => CLIENT_REQUEST_ERROR).first.subject.as(ClientRequestError)
          else
            client_request_error = Spira.repository.query(:predicate => RDF.type, :object => SERVER_REQUEST_ERROR).first.subject.as(ClientRequestError)
          end
          client_request_error.response_body = response
          client_request_error.response_code = response.code
          client_request_error.result = result
          client_request_error
        end
      end
      
      protected
      
      def self.production_url
        "https://beta.worldcat.org/discovery/offer"
      end
      
    end
  end
end
      
