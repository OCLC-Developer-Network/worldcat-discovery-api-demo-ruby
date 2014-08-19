set :views, File.dirname(__FILE__) + "/views"
set :haml, :format => :html5

get "/" do
  haml :search_results, :layout => :template
end

get "/catalog" do
  uri = URI.parse(request.url)
  params = CGI.parse(uri.query)
  params["facetFields"] = ['inLanguage:10', 'itemType:10']
  @results = WorldCat::Discovery::Bib.search(params)
  haml :search_results, :layout => :template
end

get '/catalog/:oclc_number' do
  @bib = WorldCat::Discovery::Bib.find(params[:oclc_number])
  haml :show, :layout => :template
end

get '/explore' do
  # { predicate => source }
  followed_predicates = Hash.new
  followed_predicates['http://www.w3.org/2002/07/owl#sameAs'] = { :source => 'http://dbpedia.org', :follow => 'object' }
  followed_predicates['http://dbpedia.org/ontology/author'] = { :source => 'http://dbpedia.org', :follow => 'subject' }
  followed_predicates['http://dbpedia.org/ontology/starring'] = { :source => 'http://dbpedia.org', :follow => 'subject' }
  
  @graph = load_graph(params[:uri], followed_predicates)
  haml :explore
end

