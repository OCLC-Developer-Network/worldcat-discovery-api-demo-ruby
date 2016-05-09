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
    class OfferSearchResults < SearchResults
      
      has_many :items, :predicate => DISCOVERY_HAS_PART, :type => 'Offer'
      property :total_results, :predicate => DISCOVERY_TOTAL_RESULTS, :type => XSD.integer
      property :start_index, :predicate => DISCOVERY_START_INDEX, :type => XSD.integer
      property :items_per_page, :predicate => DISCOVERY_ITEMS_PER_PAGE, :type => XSD.integer
      
      # call-seq:
      #   offers() => Array of WorldCat::Discovery::Offer objects
      # 
      # Returns Offer objects contained in the SearchResults. 
      # Results will be sorted by display position.
      def offers
        # Create a Hash in which the keys are the display position and the values are the corresponding Bib objects
        indexed_offers = self.items.reduce(Hash.new) {|sorted_offers, offer| sorted_offers[offer.display_position] = offer; sorted_offers}

        # Convert the Hash form into an Array sorted by the display position
        sorted_offers  = indexed_offers.keys.sort.reduce(Array.new) {|sorted_offers, position| sorted_offers << indexed_offers[position]}
        
        sorted_offers
      end
      
      # call-seq:
      #   bib() => WorldCat::Discovery::Bib
      # 
      # Will return a subclass of Bib
      def bib
        generic_resource = Spira.repository.query(:predicate => RDF.type, :object => GENERIC_RESOURCE).first
        bib = generic_resource.subject.as(GenericResource).about
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
      
