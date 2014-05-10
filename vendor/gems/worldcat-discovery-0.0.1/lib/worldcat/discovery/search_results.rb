module WorldCat
  module Discovery
    class SearchResults < Spira::Base
      
      property :total_results, :predicate => DISCOVERY_TOTAL_RESULTS, :type => XSD.integer
      property :start_index, :predicate => DISCOVERY_START_INDEX, :type => XSD.integer
      property :items_per_page, :predicate => DISCOVERY_ITEMS_PER_PAGE, :type => XSD.integer
      property :facet_list, :predicate => DISCOVERY_FACET_LIST, :type => 'FacetList'
      has_many :items, :predicate => SCHEMA_SIGNIFICANT_LINK, :type => 'GenericResource'
      
      def id
        self.subject
      end
      
      def bibs
        bibs = self.items.map {|item| item.about}
        
        # Create a Hash in which the keys are the display position and the values are the corresponding Bib objects
        indexed_bibs = bibs.reduce(Hash.new) {|sorted_bibs, bib| sorted_bibs[bib.display_position] = bib; sorted_bibs}
        
        # Convert the Hash form into an Array sorted by the display position
        sorted_bibs  = indexed_bibs.keys.sort.reduce(Array.new) {|sorted_bibs, position| sorted_bibs << indexed_bibs[position]}
        
        sorted_bibs
      end
      
      def facets
        if self.facet_list
          self.facet_list.facets
        else
          nil
        end
      end
      
    end
  end
end