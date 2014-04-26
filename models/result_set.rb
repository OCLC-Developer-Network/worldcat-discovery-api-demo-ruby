module WorldCat
  class ResultSet < WorldCat::Resource
    
    def initialize(data, item_class)
      @data = data
      process_data()
      embed_extra()
    end
    
    protected
    
    def embed_extra
      @data['@graph'].first['schema:significantLink'].each do |bib_item| 
        embed_by_property(bib_item, 'schema:author')
        embed_by_property(bib_item, 'schema:about')
      end
    end
    
    def embed_by_property(bib_item, property)
      if bib_item[property].is_a?(Hash)
        @graph.query(:subject => RDF::URI.new(bib_item[property]['@id'])).each do |stmt| 
          bib_item[property] = add_property_to_hash(bib_item[property], stmt)
        end
      elsif bib_item[property].is_a?(Array)
        bib_item[property].each do |prop|
          @graph.query(:subject => RDF::URI.new(prop['@id'])).each do |stmt| 
            prop = add_property_to_hash(prop, stmt)
          end
        end
      end
    end    
    
  end
end