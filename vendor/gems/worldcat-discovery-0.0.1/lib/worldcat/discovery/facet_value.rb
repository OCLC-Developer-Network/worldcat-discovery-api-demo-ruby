module WorldCat
  module Discovery
    class FacetValue < Spira::Base
      
      property :type, :predicate => RDF.type, :type => RDF::URI
      property :name, :predicate => SCHEMA_NAME, :type => XSD.string
      property :count, :predicate => DISCOVERY_FACET_COUNT, :type => XSD.integer
      
      def id
        self.subject
      end

    end
  end
end