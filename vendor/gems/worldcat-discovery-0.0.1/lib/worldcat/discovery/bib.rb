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
    class Bib < Spira::Base
      
      property :name, :predicate => SCHEMA_NAME, :type => XSD.string
      property :oclc_number, :predicate => LIB_OCLC_NUMBER, :type => XSD.integer
      property :work_uri, :predicate => SCHEMA_EXAMPLE_OF_WORK, :type => RDF::URI
      property :num_pages, :predicate => SCHEMA_NUMBER_OF_PAGES, :type => XSD.string
      property :date_published, :predicate => SCHEMA_DATE_PUBLISHED, :type => XSD.string
      property :type, :predicate => RDF.type, :type => RDF::URI
      property :same_as, :predicate => OWL_SAME_AS, :type => RDF::URI
      property :language, :predicate => SCHEMA_IN_LANGUAGE, :type => XSD.string
      property :publisher, :predicate => SCHEMA_PUBLISHER, :type => 'Organization'
      property :display_position, :predicate => GOOD_RELATIONS_POSITION, :type => XSD.integer
      property :book_edition, :predicate => SCHEMA_BOOK_EDITION, :type => XSD.string
      has_many :subjects, :predicate => SCHEMA_ABOUT, :type => 'Subject'
      has_many :work_examples, :predicate => SCHEMA_WORK_EXAMPLE, :type => 'ProductModel'
      has_many :places_of_publication, :predicate => LIB_PLACE_OF_PUB, :type => 'Place'
      has_many :descriptions, :predicate => SCHEMA_DESCRIPTION, :type => XSD.string
      has_many :reviews, :predicate => SCHEMA_REVIEW, :type => 'Review'
      has_many :contributors, :predicate => SCHEMA_CONTRIBUTOR, :type => 'Person'
      
      def id
        self.subject
      end
      
      def author
        author_stmt = Spira.repository.query(:subject => self.id, :predicate => SCHEMA_AUTHOR).first
        if author_stmt
          author_type = Spira.repository.query(:subject => author_stmt.object, :predicate => RDF.type).first
          case author_type.object
          when SCHEMA_PERSON then author_stmt.object.as(Person)
          when SCHEMA_ORGANIZATION then author_stmt.object.as(Organization)
          else nil
          end
        else
          nil
        end
      end
      
      def isbns
        self.work_examples.map {|product_model| product_model.isbn}.sort
      end
      
      def self.search(params)
        uri = Addressable::URI.parse("#{Bib.production_url}/search")
        uri.query_values = params
        response = get_data(uri.to_s)
        
        # Load the data into an in-memory RDF repository, get the GenericResource and its Bib
        Spira.repository = RDF::Repository.new.from_rdfxml(response)
        search_results = Spira.repository.query(:predicate => RDF.type, :object => SCHEMA_SEARCH_RES_PAGE).first.subject.as(SearchResults)
        
        # WorldCat::Discovery::SearchResults.new
        search_results
      end
            
      def self.find(oclc_number)
        url = "#{Bib.production_url}/data/#{oclc_number}"
        response = get_data(url)

        # Load the data into an in-memory RDF repository, get the GenericResource and its Bib
        Spira.repository = RDF::Repository.new.from_rdfxml(response)
        generic_resource = Spira.repository.query(:predicate => RDF.type, :object => GENERIC_RESOURCE).first
        bib = generic_resource.subject.as(GenericResource).about
        
        bib
      end

      def self.production_url
        "https://beta.worldcat.org/discovery/bib"
      end
      
      protected
      
      def self.get_data(url)
        # Retrieve the key from the singleton configuration object
        raise ConfigurationException.new unless WorldCat::Discovery.configured?()
        wskey = WorldCat::Discovery.api_key
        
        # Make the HTTP request for the data
        auth = wskey.hmac_signature('GET', url)
        resource = RestClient::Resource.new url
        resource.get(:authorization => auth, 
            :user_agent => "WorldCat::Discovery Ruby gem / #{WorldCat::Discovery::VERSION}",
            :accept => 'application/rdf+xml') 
      end
      
    end
  end
end