set :views, File.dirname(__FILE__) + "/views"
set :haml, :format => :html5

get "/" do
  haml :index, :layout => :template
end

get "/catalog" do
  @result_set = WorldCat::BibliographicResource.search(params)
  haml :search_results, :layout => :template
end

get '/catalog/:oclc_number' do
  @bib_resource = WorldCat::BibliographicResource.new(:id => params[:oclc_number])
  haml :show, :layout => :template
end