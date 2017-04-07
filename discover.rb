set :views, File.dirname(__FILE__) + "/views"
set :haml, :format => :html5

get "/" do
  haml :search_results, :layout => :template
end

get "/advanced" do
  @db_list = WorldCat::Discovery::Database.list
  if @db_list.class == WorldCat::Discovery::DatabaseList
    haml :advanced_search, :layout => :template
  else
    haml :error, :layout => :template
  end
end

get "/catalog" do
  uri = URI.parse(request.url)
  app_params = CGI.parse(uri.query)
  api_params = discovery_api_params(app_params)
  @results = WorldCat::Discovery::Bib.search(api_params)
  if @results.response_code == 200
    haml :search_results, :layout => :template
  else
    haml :error, :layout => :template
  end
end

get '/catalog/:oclc_number' do
  @offer_results = WorldCat::Discovery::Offer.find_by_oclc(params[:oclc_number], {"heldBy" => library_symbols})
  if @offer_results.class == WorldCat::Discovery::OfferSearchResults
    @bib = @offer_results.bib
  else
    @bib = nil
  end

  case @bib
  when nil then haml :error, :layout => :template
  when OCLC::Auth::Exception then haml :error, :layout => :template
  when WorldCat::Discovery::ClientRequestError then haml :error, :layout => :template
  when WorldCat::Discovery::Article then haml :article, :layout => :template
  when WorldCat::Discovery::Movie then haml :movie, :layout => :template
  when WorldCat::Discovery::MusicAlbum then haml :music_album, :layout => :template
  when WorldCat::Discovery::Periodical then haml :periodical, :layout => :template
  else haml :show, :layout => :template
  end
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

