set :views, File.dirname(__FILE__) + "/views"
set :haml, :format => :html5

get "/" do
  haml :search_results, :layout => :template
end

get "/advanced" do
  @db_list = WorldCat::Discovery::Database.list
  haml :advanced_search, :layout => :template
end

get "/catalog" do
  uri = URI.parse(request.url)
  app_params = CGI.parse(uri.query)
  api_params = discovery_api_params(app_params)
  
  @results = WorldCat::Discovery::Bib.search(api_params)
  haml :search_results, :layout => :template
end

get '/catalog/:oclc_number' do
  @bib = WorldCat::Discovery::Bib.find(params[:oclc_number])
  @offer_results = WorldCat::Discovery::Offer.find_by_oclc(params[:oclc_number], {"heldBy" => library_symbols})
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

