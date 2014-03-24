module WorldCat
  class Resource
    
    attr_accessor :data, :context, :graph, :properties, :primary_topic
    
    def initialize
      process_data
      embed_extra
    end
    
    def primary_type
      @properties['@type']
    end
    
    def ontology_uri(property)
      @context[property].class == Hash ? @context[property]['@id'] : @context[property]
    end

    def get_semantic_property(predicate)
      @graph.query(:subject => @primary_topic, :predicate => RDF::URI.new(predicate)).first
    end
    
    def property_values(predicate)
      @graph.query(:subject => @primary_topic, :predicate => RDF::URI.new(predicate))
    end
    
    def sub_graph(subject)
      @graph.query(:subject => RDF::URI.new(subject))
    end
    
    protected
    
    def process_data
      @context = @data['@context']
      if @data['@graph'].first['schema:significantLink'].is_a?(Hash)
        # I am creating an Resource from a single result
        @properties = @data['@graph'].first['schema:significantLink']
      else
        # I am creating a single entity from a search result set
        @properties = @data['@graph'].first
      end
      @primary_topic = RDF::URI.new(@properties['@id'])
      @graph = RDF::Graph.new
      @graph << JSON::LD::API.toRdf(@data)
    end
    
    # The Autobiography Problem
    # When two different predicates/properties share the same ID as an object, 
    # only one of them will include the sub-properties.
    def embed_extra

      # Get all the objects from each triple in the graph
      @graph.each_object do |object|
        
        # Query the graph for each object to find objects that appear more than once
        # that are not the primary topic of this resource
        if @graph.query(:object => object).size > 1 #and object.to_s != @primary_topic
          
          # Get all the statements for which this object is also a subject (i.e., has CBD)
          @graph.query(:subject => object).each do |statement|
            
            # Get all the statements where the curren statement is a subject 
            # and map the predicates from those statements to an array of strings.
            # This is the Concise Bounded Description for a child property.
            predicates = @graph.query(:object => statement.subject).map {|s| s.predicate.to_s}
            
            # Convert each predicate to the form used in the @context hash
            predicates = map_uri_predicates_to_context_versions(predicates)
            
            # For each predicate, find it in the properties
            predicates.each do |predicate|
            
              if @properties[predicate].is_a?(Hash)
                @properties[predicate] = add_property_to_hash(@properties[predicate], statement)
              elsif @properties[predicate].is_a?(Array)
            
                @properties[predicate].each_index do |i| 
                  if @properties[predicate][i]['@id'] == statement.subject.to_s
                    @properties[predicate][i] = add_property_to_hash(@properties[predicate][i], statement)
                  end
                end 
            
              end # @properties[predicate].is_a?(Array)
            end # predicates.each
          end # @graph.query(:subject => object).each do |statement|
        end # if @graph.query(:object => object).size > 1
      end # @graph.each_object do |object|
    end
    
    def add_property_to_hash(hash, property_stmt)
      if property_stmt.predicate.to_s == 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type'
        key = '@type' 
      else
        key = map_uri_predicates_to_context_versions([property_stmt.predicate.to_s]).first
      end
      
      # Add the missing data to the properties Hash for the given subject
      hash[key] = map_uri_predicates_to_context_versions([property_stmt.object.to_s]).first
      hash
    end
    
    # Takes an array of URI predicates like
    #
    #   ['http://schema.org/name', 'http://schema.org/author']
    #
    # and mapps them to 
    #
    #   ['schema:name', 'schema:author']
    #
    # if that is how they appear in the @context
    #
    # [predicates] an array of predicates to be mapped to the context versions
    def map_uri_predicates_to_context_versions(predicates)
      predicates.map! do |p|
        @context.each { |k,v| p = p.gsub(v,"#{k}:") }
        p
      end
      predicates
    end
    
  end
end