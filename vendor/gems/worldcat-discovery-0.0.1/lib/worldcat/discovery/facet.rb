module WorldCat
  module Discovery
    class Facet < Spira::Base
      
      property :type, :predicate => RDF.type, :type => RDF::URI
      property :index, :predicate => DISCOVERY_FACET_INDEX, :type => XSD.string
      has_many :_values, :predicate => DISCOVERY_FACET_VALUE, :type => 'FacetValue'
      
      def values
        # Create a Hash in which the keys are the facet value count and the values are an Array of FacetValue objects
        indexed_values = self._values.reduce(Hash.new) do |sorted_values, facet_value| 
          sorted_values[facet_value.count] = Array.new unless sorted_values.has_key?(facet_value.count)
          sorted_values[facet_value.count] << facet_value
          sorted_values
        end
        
        # Convert the Hash form into an Array sorted by the facet value counts from highest to lowest
        sorted_counts = indexed_values.keys.sort.reverse
        sorted_values = sorted_counts.reduce(Array.new) do |sorted_values, count| 
          indexed_values[count].each do |facet_value|
            sorted_values << facet_value
          end
          sorted_values
        end

        sorted_values
      end
      
      def id
        self.subject
      end

    end
  end
end