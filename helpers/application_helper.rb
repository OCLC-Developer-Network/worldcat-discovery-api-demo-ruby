# Helpers to deal with the vast variations in bibliographic data

helpers do
  
  def facet_display_name(facet, facet_value)
    case facet.index
    when 'srw.ln' then MARC_LANGUAGES[facet_value.name]
    when 'srw.ap' then facet_value.name.titleize 
    else facet_value.name
    end
  end

  def pagination(params, results)
    pagination = Hash.new
    pagination[:first] = results.start_index + 1 # params[:start].nil? ? 1 : params[:start].to_i\
    pagination[:last] = pagination[:first] + results.items_per_page - 1
    pagination[:total] = results.total_results.to_i
    pagination[:next_page_start] = (pagination[:first] + results.items_per_page - 1) > results.total_results.to_i ? nil : pagination[:first] + results.items_per_page - 1
    pagination[:previous_page_start] = (pagination[:first] - 11) < 0 ? nil : pagination[:first] - 11
    pagination
  end
    
  def facet_refine_url(facet, facet_value, params)
    q  = params[:q]
    q += " AND #{facet.index}:#{facet_value.name}"
    url("/catalog?q=#{q}")
  end
  
  def is_published?(bib)
    places = pub_places(bib)
    has_place = false
    has_place = places.size > 0
    
    has_publisher = false
    has_publisher = true if bib.publisher
    
    has_pub_date = false
    has_pub_date = true if bib.date_published
    
    has_place or has_publisher or has_pub_date
  end
  
  def pub_places(bib)
    places = bib.places_of_publication.map do |place|
      place.name.nil? ? nil : place.name
    end
    places.compact
  end
  
  def display_subjects(bib)
    bib.subjects.select {|subject| subject if displayable?(subject)}
  end
  
  def displayable?(subject)
    has_name = subject.name != nil
    is_fast = subject.id.to_s.match("http://id.worldcat.org/fast/")
    is_viaf = subject.id.to_s.match("http://viaf.org/viaf/")
    has_name and (is_fast or is_viaf)
  end
  
  # Sometimes a contributor has a rdf:label, sometimes a schema:name
  # def display_name(object)
  #   if object['schema:name']
  #     object['schema:name'].is_a?(Array) ? object['schema:name'].first : object['schema:name']
  #   elsif object['http://www.w3.org/2000/01/rdf-schema#label']
  #     if object['http://www.w3.org/2000/01/rdf-schema#label'].is_a?(Array) 
  #       object['http://www.w3.org/2000/01/rdf-schema#label'].first 
  #     else
  #       object['http://www.w3.org/2000/01/rdf-schema#label']
  #     end
  #   else
  #     ""
  #   end
  # end
  
  # Escapes HTML
  def h(text)
    Rack::Utils.escape_html(text)
  end
end