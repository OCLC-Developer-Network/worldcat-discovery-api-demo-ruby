# Helpers to deal with the vast variations in bibliographic data

helpers do
  
  def other_works(graph, dbpedia_author_uri, title)
    other_works = Array.new
    works = graph.query(:predicate => DBPEDIA_AUTHOR, :object => dbpedia_author_uri)
    works.each do |work|
      labels = @graph.query(:subject => work.subject, :predicate => RDFS_LABEL)
      en_label = labels.select {|l| l if l.object.language == :en}.first.object
      other_works << work if en_label.to_s.downcase != title.downcase
    end
    other_works
  end

  # Load an RDF graph.
  # Requires at least a URI to go and fetch an RDF document
  # Optionally pass in an array of predicates to follow and it will "crawl" 
  # those links when encountered.
  # Optionally pass in an existing graph to add the info to. This is how crawled 
  # content are added to the current graph. 
  def load_graph(url, followed_predicates = nil, graph = nil)
    begin
      graph = RDF::Graph.new if graph.nil?
      
      # Using RestClient because RDF::RDFXML::Reader.open(url) doesn't do well w/ redirects
      data = RestClient.get( url, :accept => 'application/rdf+xml' ) 
      RDF::Reader.for(:rdfxml).new(data) do |reader|
        reader.each_statement do |statement| 
          # Add the statement to the graph
          graph << statement 

          # If the statement contains a predicate we are interested in, recursively follow it
          # @TO-DO: add in a check that we are not going to get caught in a loop - see if 
          # subject already exists in the graph
          if followed_predicates and followed_predicates.has_key?(statement.predicate.to_s)
            uri = find_followable_uri(url, statement, followed_predicates)
            load_graph(uri, followed_predicates, graph) if uri
          end
        end
      end
      graph
    rescue RestClient::BadGateway => e
      puts "Warning: received response #{e.message} from #{url}"
      graph
    end
  end
  
  def find_followable_uri(subject, statement, followed_predicates)
    source = followed_predicates[statement.predicate.to_s][:source]
    follow = followed_predicates[statement.predicate.to_s][:follow]
    
    if follow == 'subject'
      uri = statement.subject.to_s
      statement.object == subject and uri.match(source) and !is_tautology?(statement) ? uri : nil
    elsif follow == 'object'
      uri = statement.object.to_s
      statement.subject == subject and uri.match(source) and !is_tautology?(statement) ? uri : nil
    else
      nil
    end
  end
  
  def is_tautology?(statement)
    statement.subject == statement.object
  end
  
  def facet_display_name(facet, facet_value)
    case facet.index
    when 'inLanguage' then MARC_LANGUAGES[facet_value.name]
    when 'author' then facet_value.name.titleize 
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
  
  def previous_page_url(pagination)
    uri = URI.parse(request.url)
    params = CGI.parse(uri.query)
    params["startNum"] = [pagination[:previous_page_start]]
    query_string = to_query_string(params)
    url("#{request.path_info}?#{query_string}")
  end
  
  def next_page_url(pagination)
    uri = URI.parse(request.url)
    params = CGI.parse(uri.query)
    params["startNum"] = [pagination[:next_page_start]]
    query_string = to_query_string(params)
    url("#{request.path_info}?#{query_string}")
  end
  
  def to_query_string(params)
    escaped_params = Array.new
    params.each do |key,values|
      values.each do |value|
        value = CGI.unescape(value.to_s)
        escaped_params << key + "=" + CGI.escape(value).gsub('+', '%20')
      end
    end
    escaped_params.join('&')
  end
    
  def facet_refine_url(facet, facet_value, params)
    uri = URI.parse(request.url)
    params = CGI.parse(uri.query)
    if params["facetQueries"].nil?
      params["facetQueries"] = Array.new
    elsif params["facetQueries"].is_a?(String)
      str = params["facetQueries"]
      params["facetQueries"] = Array.new
      params["facetQueries"] << str
    else
      params["facetQueries"] = params["facetQueries"].dup
    end
    params["facetQueries"] << "#{facet.index}:#{facet_value.name}"
    params.delete("startNum")
    query_string = to_query_string(params)
    url("#{request.path_info}?#{query_string}")
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