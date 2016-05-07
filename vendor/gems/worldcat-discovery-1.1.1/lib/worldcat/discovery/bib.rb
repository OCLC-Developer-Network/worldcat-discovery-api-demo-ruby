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
    
    # == Properties mapped from RDF data
    #
    # RDF properties are mapped via an ORM style mapping.
    # 
    #   bib = WorldCat::Discovery::Bib.find(255034622)
    #   bib.name        # => "Programming Ruby."
    #   bib.oclc_number # => 255034622
    #
    # [type] RDF predicate: http://www.w3.org/1999/02/22-rdf-syntax-ns#type; returns: RDF::URI
    # [alternateName] RDF predicate: http://schema.org/alternateName; returns: String
    # [oclc_number] RDF predicate: http://purl.org/library/oclcnum; returns: Integer
    # [work_uri] RDF predicate: http://schema.org/exampleOfWork; returns: RDF::URI
    # [num_pages] RDF predicate: http://schema.org/numberOfPages; returns: String
    # [date_published] RDF predicate: http://schema.org/datePublished; returns: String
    # [same_as] RDF predicate: http://www.w3.org/2002/07/owl#sameAs; returns: RDF::URI
    # [language] RDF predicate: http://schema.org/inLanguage; returns: String
    # [publisher] RDF predicate: http://schema.org/publisher; returns: WorldCat::Discovery::Organization
    # [display_position] RDF predicate: http://purl.org/goodrelations/v1#displayPosition; returns: Integer
    # [book_edition] RDF predicate: http://schema.org/bookEdition; returns: String
    # [url] RDF predicate: http://schema.org/url; returns: String
    # [urls] RDF predicate: https://schema.org/url; returns Enumerable of strings
    # [subjects] RDF predicate: http://schema.org/about; returns: Enumerable of WorldCat::Discovery::Subject objects
    # [work_examples] RDF predicate: http://schema.org/workExample; returns: Enumerable of WorldCat::Discovery::ProductModel objects
    # [places_of_publication] RDF predicate: http://purl.org/library/placeOfPublication; returns: Enumerable of WorldCat::Discovery::Place objects
    # [descriptions] RDF predicate: http://schema.org/description; returns: Enumerable of String objects
    # [reviews] RDF predicate: http://schema.org/reviews; returns: Enumerable of WorldCat::Discovery::Review objects
    # [contributors] RDF predicate: http://schema.org/contributor; returns: Enumerable of WorldCat::Discovery::Person objects
    # [is_part_of] RDF predicate: http://schema.org/isPartOf; returns: WorldCat::Discovery::Series
    # [similar_to] RDF predicate: http://schema.org/musicBy; returns: WorldCat::Discovery::Bib object
    # [awards] RDF predicate: http://schema.org/awards, returns: Enumerable of strings
    # [content_rating] RDF predicate: http://schema.org/contentRating, returns string    
    # [genres] RDF predicate: http://schema.org/genre, returns: Enumerable of WorldCat::Discovery Genre objects
    # [illustrators] RDF predicate: http://schema.org/illustrator; returns Enumerable of WorldCat::Discovery::Person objects
    # [copyright_year] RDF predicate: http://schema.org/copyrightYear; returns string
    # [book_format] RDF predicate: http://schema.org/bookFormat; returns RDF::URI
    # [editors] RDF predicate: http://schema.org/editor returns: Enumerable of WorldCat::Discovery::Person objects
    # [described_by RDF predicate: http://www.w3.org/2007/05/powder-s#describedby returns: WorldCat::Discovery::GenericResource object
    
    class Bib < Spira::Base
      
      attr_accessor :response_body, :response_code, :result
      
      property :alternate_name, :predicate => SCHEMA_ALT_NAME, :type => XSD.string
      property :oclc_number, :predicate => LIB_OCLC_NUMBER, :type => XSD.integer
      property :work_uri, :predicate => SCHEMA_EXAMPLE_OF_WORK, :type => RDF::URI
      property :num_pages, :predicate => SCHEMA_NUMBER_OF_PAGES, :type => XSD.string
      property :date_published, :predicate => SCHEMA_DATE_PUBLISHED, :type => XSD.string
      property :type, :predicate => RDF.type, :type => RDF::URI
      property :same_as, :predicate => SCHEMA_SAME_AS, :type => RDF::URI
      property :language, :predicate => SCHEMA_IN_LANGUAGE, :type => XSD.string
      property :publisher, :predicate => SCHEMA_PUBLISHER, :type => 'Organization'
      property :display_position, :predicate => GOOD_RELATIONS_POSITION, :type => XSD.integer
      property :book_edition, :predicate => SCHEMA_BOOK_EDITION, :type => XSD.string
      property :url, :predicate => SCHEMA_URL, :type => RDF::URI
      has_many :urls, :predicate => SCHEMA_URL, :type => RDF::URI
      has_many :subjects, :predicate => SCHEMA_ABOUT, :type => 'Subject'
      has_many :work_examples, :predicate => SCHEMA_WORK_EXAMPLE, :type => 'ProductModel'
      has_many :places_of_publication, :predicate => LIB_PLACE_OF_PUB, :type => 'Place'
      has_many :descriptions, :predicate => SCHEMA_DESCRIPTION, :type => XSD.string
      has_many :reviews, :predicate => SCHEMA_REVIEW, :type => 'Review'
      has_many :contributors, :predicate => SCHEMA_CONTRIBUTOR, :type => 'Person'
      has_many :types, :predicate => RDF.type, :type => RDF::URI
      has_many :parts_of, :predicate => SCHEMA_IS_PART_OF, :type => 'Series'
      property :similar_to, :predicate => SCHEMA_IS_SIMILAR_TO, :type => 'Bib'
      has_many :awards, :predicate => SCHEMA_AWARDS, :type => XSD.string
      property :content_rating, :predicate => SCHEMA_CONTENT_RATING, :type => XSD.string
      has_many :illustrators, :predicate => SCHEMA_ILLUSTRATOR, :type => 'Person'
      has_many :genres, :predicate => SCHEMA_GENRE, :type => XSD.string
      property :copyright_year, :predicate => SCHEMA_COPYRIGHT_YEAR, :type => XSD.string
      property :book_format, :predicate => SCHEMA_BOOK_FORMAT, :type => RDF::URI
      has_many :editors, :predicate => SCHEMA_EDITOR, :type => 'Person'
      property :described_by, :predicate => WDRS_DESCRIBED_BY, :type=> 'GenericResource'
      
      # call-seq:
      #   id() => RDF::URI
      # 
      # Will return the RDF::URI object that serves as the RDF subject of the current Bib
      def id
        self.subject
      end
      
      # call-seq
      # name() 
      # RDF predicate: http://schema.org/name or the http://www.w3.org/2000/01/rdf-schema#label returns: String 
      def name
        name = Spira.repository.query(:subject => self.id, :predicate => SCHEMA_NAME).first
        name = Spira.repository.query(:subject => self.id, :predicate => RDFS_LABEL).first if name.nil?
        name.object.to_s
        
      end
      
      # call-seq:
      #   author() => WorldCat::Discovery::Person or WorldCat::Discovery::Organization
      # 
      # Returns Bib author from RDF predicate: http://schema.org/author
      def author
        author_stmt = Spira.repository.query(:subject => self.id, :predicate => SCHEMA_CREATOR).first
        author_stmt = Spira.repository.query(:subject => self.id, :predicate => SCHEMA_AUTHOR).first if author_stmt.nil?

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
      
      # call-seq:
      #   isbns() => Array of String objects
      # 
      # Returns a Bib resource for the given OCLC number
      #
      # Convenience method for an Array of ISBN strings from the associated WorldCat::Discovery::ProductModel objects
      def isbns
        self.work_examples.map {|product_model| product_model.isbns}.flatten.sort
      end
      
      
      # call-seq:
      # audience() => string
      def audience
        audience_stmt = Spira.repository.query(:subject => self.id, :predicate => SCHEMA_AUDIENCE).first
        if audience_stmt
          audience = Spira.repository.query(:subject => audience_stmt.object, :predicate => SCHEMA_AUDIENCE_TYPE).first
          audience.object.to_s
        else
          nil
        end
      end
      
      # call-seq:
      #   data_sets() => Array of URI objects
      def data_sets
        self.described_by.datasets
      end
      
      # call-seq:
      #   search(params) => WorldCat::Discovery::SearchResults
      # 
      # Returns a search result set containing Bib resources for the given input parameters
      #
      # [params] a Hash of query parameters
      # 
      # Parameters
      # 
      # [:q] the primary query required to conduct a search of WorldCat
      # [:facetFields] an array of facets to be returned. Facets should be specified as +facet_name:num_facets+
      # [:startIndex] the integer offset from the beginning of the search result set. defaults to 0
      def self.search(params)
        uri = Addressable::URI.parse("#{Bib.production_url}/search")
        params[:dbIds] = (params[:dbIds].nil? or params[:dbIds].size == 0) ? 638 : params[:dbIds]
        uri.query_values = params
        response, result = WorldCat::Discovery.get_data(uri.to_s)
        
        if result.class == Net::HTTPOK
          # Load the data into an in-memory RDF repository, get the GenericResource and its Bib
          Spira.repository = RDF::Repository.new.from_rdfxml(response)
          search_results = Spira.repository.query(:predicate => RDF.type, :object => DISCOVERY_SEARCH_RESULTS).first.subject.as(BibSearchResults)
          search_results.response_body = response
          search_results.response_code = response.code
          search_results.result = result
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
            
      # call-seq:
      #   find(oclc_number) => WorldCat::Discovery::Bib
      # 
      # Returns a Bib resource for the given OCLC number
      #
      # [oclc_number] the WorldCat OCLC number for a bibliographic resource
      def self.find(oclc_number)
        url = "#{Bib.production_url}/data/#{oclc_number}"
        response, result = WorldCat::Discovery.get_data(url)
        
        if result.class == Net::HTTPOK
          # Load the data into an in-memory RDF repository, get the GenericResource and its Bib
          Spira.repository = RDF::Repository.new.from_rdfxml(response)
          generic_resource = Spira.repository.query(:predicate => RDF.type, :object => GENERIC_RESOURCE).first
          bib = generic_resource.subject.as(GenericResource).about
          bib.response_body = response
          bib.response_code = response.code
          bib.result = result
          
          bib = self.choose_best_type(bib)
          
          bib
          
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
        "https://beta.worldcat.org/discovery/bib"
      end
      
      def self.choose_best_type(bib)
        case
        when bib.types.include?(RDF::URI(SCHEMA_ARTICLE))
          bib.subject.as(Article)  
        when bib.types.include?(RDF::URI(SCHEMA_MUSIC_ALBUM))
          bib.subject.as(MusicAlbum)
        when bib.types.include?(RDF::URI(SCHEMA_MOVIE))
          bib.subject.as(Movie)
        when bib.types.include?(RDF::URI(SCHEMA_PERIODICAL))
          bib.subject.as(Periodical)  
        else
          bib
        end
      end

    end
  end
end