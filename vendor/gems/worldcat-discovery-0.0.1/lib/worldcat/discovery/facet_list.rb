module WorldCat
  module Discovery
    class FacetList < Spira::Base
      
      property :type, :predicate => RDF.type, :type => RDF::URI
      has_many :facets, :predicate => DISCOVERY_FACET, :type => 'Facet'
      
      def id
        self.subject
      end

    end
  end
end