set :views, File.dirname(__FILE__) + "/views"
set :haml, :format => :html5

get "/" do
  haml :search_results, :layout => :template
end

get "/catalog" do
  params[:facets] = ['author:10', 'inLanguage:10']
  @results = WorldCat::Discovery::Bib.search(params)
  haml :search_results, :layout => :template
end

get '/catalog/:oclc_number' do
  @bib = WorldCat::Discovery::Bib.find(params[:oclc_number])
  haml :show, :layout => :template
end