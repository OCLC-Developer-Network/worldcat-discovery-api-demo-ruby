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
    # [type] RDF predicate: http://www.w3.org/1999/02/22-rdf-syntax-ns#type; returns: RDF::URI
    # [index] RDF predicate: http://worldcat.org/vocab/discovery/facetIndex (index corresponding to current facet); returns: String
    
    class Facet < Spira::Base
      
      property :type, :predicate => RDF.type, :type => RDF::URI
      property :index, :predicate => DISCOVERY_FACET_INDEX, :type => XSD.string
      has_many :_values, :predicate => DISCOVERY_FACET_VALUE, :type => 'FacetValue'
      
      # call-seq:
      #   values() => Array of WorldCat::Discovery::FacetValue objects
      #
      # Example
      #
      #   results = WorldCat::Discovery::Bib.search(params)
      #   results.facets.first.values.map {|fv| "#{fv.name} (#{fv.count})"}
      #   # => ["thomas, david (18)", "ruby, ralph (9)", "tate, bruce (8)", ... ]
      #
      # Values will be sorted with the most commonly occuring facets first
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
      
      # call-seq:
      #   id() => RDF::URI
      # 
      # Will return the RDF::URI object that serves as the RDF subject of the current Facet
      def id
        self.subject
      end

    end
  end
end