require_relative '../spec_helper'

describe WorldCat::Discovery do
  
  context "when loading the API key into configuration" do
    before(:all) do
      @wskey = OCLC::Auth::WSKey.new('api-key', 'api-key-secret')
      WorldCat::Discovery.configure(@wskey)
    end
    
    it "should return the right key" do
      WorldCat::Discovery.api_key.should == @wskey
    end
    
    it "should not require the Bib class to be passed a key when finding an instance" do
      url = 'https://beta.worldcat.org/discovery/bib/data/30780581'
      stub_request(:get, url).to_return(:body => body_content("30780581.rdf"), :status => 200)
      lambda { bib = WorldCat::Discovery::Bib.find(30780581) }.should_not raise_error
    end

    it "should not require the Bib class to be passed a key when searching" do
      url = 'https://beta.worldcat.org/discovery/bib/search?q=wittgenstein+reader'
      stub_request(:get, url).to_return(:body => body_content("bib_search.rdf"), :status => 200)
      lambda { WorldCat::Discovery::Bib.search(:q => 'wittgenstein reader') }.should_not raise_error
    end
  end
  
end
