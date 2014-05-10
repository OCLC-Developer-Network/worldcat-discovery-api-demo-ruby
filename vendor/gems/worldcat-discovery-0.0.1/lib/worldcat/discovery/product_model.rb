module WorldCat
  module Discovery
    class ProductModel < Spira::Base
      
      property :name, :predicate => SCHEMA_NAME, :type => XSD.string
      property :isbn, :predicate => SCHEMA_ISBN, :type => XSD.string
      has_many :types, :predicate => RDF.type, :type => RDF::URI
      
      def id
        self.subject
      end
      
      def type
        SCHEMA_PRODUCT_MODEL
      end
      
    end
  end
end