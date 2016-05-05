# Copyright 2016 OCLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'spec_helper'

describe "the error page" do
  context "when using a WSKey not for WorldCat Metadata API" do
    before(:all) do
      stub_request(:get, "https://beta.worldcat.org/discovery/bib/data/30780581").
        to_return(:status => 200, :body => mock_file_contents("30780581.rdf"))
      get '/record/30780581'
    end
    
    it "should raise an error when calling the find() method on the Bib class" do
      expect(last_response).to raise_error(WorldCat::Discovery::ConfigurationException, 
          'Cannot find/search Bib resources unless an API key is configured. Call WorldCat::Discovery.configure(wskey) with an OCLC::Auth::WSKey')
    end
      
  end
  
  context "when using a WSKey that is not valid" do
    before(:all) do
      stub_request(:get, "https://beta.worldcat.org/discovery/bib/data/30780581").
        to_return(:status => 200, :body => mock_file_contents("30780581.rdf"))
      get '/record/30780581'
    end
    
    it "should raise an error when calling the find() method on the Bib class" do
      expect(last_response).to raise_error(WorldCat::Discovery::ConfigurationException, 
          'Cannot find/search Bib resources unless an API key is configured. Call WorldCat::Discovery.configure(wskey) with an OCLC::Auth::WSKey')
    end
  end
  
  context "when using an access token that is not valid" do
    before(:all) do
      stub_request(:get, "https://beta.worldcat.org/discovery/bib/data/30780581").
        to_return(:status => 401, :body => mock_file_contents("error_response_bad_access_token.rdf"))
      get '/record/30780581'
      doc = Nokogiri::HTML(last_response.body)
    end
    
    it "should display the error section" do
      expect(@alert.xpath("./span[@id='error-heading'][text()='Sorry, but the requested page was not found.']").size).to eq(1)
    end
  end
  
  context "when using an access token that is not for the right web service" do
    before(:all) do
      stub_request(:get, "https://beta.worldcat.org/discovery/bib/data/30780581").
        to_return(:status => 403, :body => mock_file_contents("error_response_access_token_wrong_service.rdf"))
      get '/record/30780581'
      doc = Nokogiri::HTML(last_response.body)
    end
    
    it "should display the error section" do
      expect(@alert.xpath("./span[@id='error-heading'][text()='Sorry, but the requested page was not found.']").size).to eq(1)
    end
  end
  
  context "when sending an empty query" do
    before(:all) do
      stub_request(:get, "https://beta.worldcat.org/discovery/bib/search?q=&facetFields=creator:10&facetFields=inLanguage:10&facetFields=itemType:10&dbIds=638'").
        to_return(:status => 400, :body => mock_file_contents("error_response_empty_query.xml"))
      get '/catalog?q=&scope=my_library'
      doc = Nokogiri::HTML(last_response.body)
      @alert = doc.xpath("//div[@id='errors']").first
    end

    it "should display the error section" do
      expect(@alert.xpath("./span[@id='error-heading'][text()='Sorry, but the requested page was not found.']").size).to eq(1)
    end
  end
  
  context "when trying to display an OCLC number that does not exist" do
    before(:all) do
      stub_request(:get, "https://beta.worldcat.org/discovery/bib/data/99999999999999").
        to_return(:status => 404, :body => mock_file_contents("error_response_not_found.xml"))
      get '/record/99999999999999'
      doc = Nokogiri::HTML(last_response.body)
      @alert = doc.xpath("//div[@id='errors']").first
    end

    it "should display the error section" do
      expect(@alert.xpath("./span[@id='error-heading'][text()='Sorry, but the requested page was not found.']").size).to eq(1)
    end

  end
    
end
