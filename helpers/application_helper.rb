# Helpers to deal with the vast variations in bibliographic data

helpers do
  
  def language_display_name(code)
    LANGUAGES[code]
  end
  
  def typeof(bib_resource)
    if bib_resource.primary_type.is_a?(Array)
      bib_resource.primary_type.join(' ')
    else
      bib_resource.primary_type
    end
  end
  
  def format(bib_resource)
    primary_type = bib_resource['@type']
    if primary_type.is_a?(Array)
      primary_type.first.gsub('schema:', '')
    elsif primary_type.is_a?(String)
      primary_type.gsub('schema:', '')
    end
  end
  
  def displayable_subjects(bib_resource)
    subjects(bib_resource).select {|subject| subject if is_displayable?(subject) }
  end
  
  def is_displayable?(subject)
    has_name = subject['schema:name'] != nil
    is_fast = subject['@id'].match("http://id.worldcat.org/fast/")
    is_viaf = subject['@id'].match("http://viaf.org/viaf/")
    has_name and (is_fast or is_viaf)
  end
  
  def subjects(bib_resource)
    subject_data = bib_resource.properties['schema:about']
    if subject_data.is_a?(Hash)
      [subject_data]
    elsif subject_data.is_a?(Array)
      subject_data
    else
      []
    end
  end
  
  def descriptions(bib_resource)
    description_data = bib_resource.properties['schema:description']
    if description_data.is_a?(Hash)
      [description_data]
    elsif description_data.is_a?(Array)
      description_data
    elsif description_data.is_a?(String)
      [description_data]
    else
      []
    end
  end
  
  # Sometimes a contributor has a rdf:label, sometimes a schema:name
  def display_name(object)
    if object['schema:name']
      object['schema:name'].is_a?(Array) ? object['schema:name'].first : object['schema:name']
    elsif object['http://www.w3.org/2000/01/rdf-schema#label']
      if object['http://www.w3.org/2000/01/rdf-schema#label'].is_a?(Array) 
        object['http://www.w3.org/2000/01/rdf-schema#label'].first 
      else
        object['http://www.w3.org/2000/01/rdf-schema#label']
      end
    else
      ""
    end
  end
  
  def contributors(bib_resource)
    contributor_data = bib_resource.properties['schema:contributor']
    if contributor_data.is_a?(Hash)
      [contributor_data]
    elsif contributor_data.is_a?(Array)
      contributor_data
    else
      []
    end
  end
  
  def places_of_publication(bib_resource)
    places = bib_resource.properties['http://purl.org/library/placeOfPublication'].map do |place| 
      place['schema:name'].nil? ? nil : place['schema:name']
    end
    places.compact
  end
  
  def isbns(bib_resource)
    if bib_resource.properties['http://www.w3.org/2000/01/rdf-schema#seeAlso']
      isbns = bib_resource.properties['http://www.w3.org/2000/01/rdf-schema#seeAlso'].map do |further_info| 
        further_info['@type'].include?('schema:ProductModel') ? further_info['schema:isbn'] : nil
      end
      isbns.compact
    else
      []
    end
  end
  
  # Escapes HTML
  def h(text)
    Rack::Utils.escape_html(text)
  end
end