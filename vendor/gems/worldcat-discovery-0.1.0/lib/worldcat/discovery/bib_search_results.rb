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
    # [facets] RDF predicate: http://worldcat.org/vocab/discovery/facet; returns: Array of WorldCat::Discovery::Facet objects
    
    class BibSearchResults < SearchResults
      
      has_many :facets, :predicate => DISCOVERY_FACET, :type => 'Facet'
      has_many :items, :predicate => DC_TERMS_HAS_PART, :type => 'GenericResource'
      
      # call-seq:
      #   bibs() => Array of WorldCat::Discovery::Bib objects
      # 
      # Returns Bib objects contained in the SearchResults. 
      # Results will be sorted by display position.
      def bibs
        bibs = self.items.map {|item| item.about}
        
        # Create a Hash in which the keys are the display position and the values are the corresponding Bib objects
        indexed_bibs = bibs.reduce(Hash.new) {|sorted_bibs, bib| sorted_bibs[bib.display_position] = bib; sorted_bibs}
        
        # Convert the Hash form into an Array sorted by the display position
        sorted_bibs  = indexed_bibs.keys.sort.reduce(Array.new) {|sorted_bibs, position| sorted_bibs << indexed_bibs[position]}
        
        sorted_bibs
      end
      
    end
  end
end
      
