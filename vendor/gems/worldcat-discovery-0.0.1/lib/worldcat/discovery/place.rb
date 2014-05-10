module WorldCat
  module Discovery
    class Place < Spira::Base
      
      property :name, :predicate => SCHEMA_NAME, :type => XSD.string
      property :type, :predicate => RDF.type, :type => RDF::URI
      
      def id
        self.subject
      end

    end
  end
end