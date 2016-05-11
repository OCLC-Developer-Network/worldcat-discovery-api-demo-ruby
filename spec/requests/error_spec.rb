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
  context "when using a WSKey that is not valid" do
    before(:all) do
      url = 'https://authn.sd00.worldcat.org/oauth2/accessToken?authenticatingInstitutionId=128807&contextInstitutionId=128807&grant_type=client_credentials&scope=WorldCatDiscoveryAPI'
      stub_request(:post, url).to_return(:body => mock_file_contents("errorToken.json"), :status => 401)
      stub_request(:get, "https://beta.worldcat.org/discovery/offer/oclc/30780581?heldBy=OCPSB").
        to_return(:status => 200, :body => mock_file_contents("offer_set_30780581.rdf"))
      get '/catalog/30780581'
      @doc = Nokogiri::HTML(last_response.body)
      @status = last_response.status
    end
    
    it "should raise an error when calling the find() method on the Bib class" do
      expect(@status).to eq(500)
      error_codes = @doc.xpath("//td[@class='code']/div/text()")
      error_codes = error_codes.map {|error_code| error_code.to_s}
      expect(error_codes).to include('#&lt;OCLC::Auth::Exception: WSKey "test" is invalid&gt;')
    end
  end
  
  context "when using a WSKey not for WorldCat Metadata API" do
    before(:all) do
      url = 'https://authn.sd00.worldcat.org/oauth2/accessToken?authenticatingInstitutionId=128807&contextInstitutionId=128807&grant_type=client_credentials&scope=WorldCatDiscoveryAPI'
      stub_request(:post, url).to_return(:body => mock_file_contents("errorTokenInvalidService.json"), :status => 403)
      stub_request(:get, "https://beta.worldcat.org/discovery/offer/oclc/30780581?heldBy=OCPSB").
        to_return(:status => 200, :body => mock_file_contents("offer_set_30780581.rdf"))
      get '/catalog/30780581'
      @doc = Nokogiri::HTML(last_response.body)
      @status = last_response.status
    end
    
    it "should raise an error when calling the find() method on the Bib class" do
      expect(@status).to eq(500)
      error_codes = @doc.xpath("//td[@class='code']/div/text()")
      error_codes = error_codes.map {|error_code| error_code.to_s}
      expect(error_codes).to include('#&lt;OCLC::Auth::Exception: Invalid scope(s): WorldCatDiscoveryAPI (WorldCat Discovery API) [Not on key]&gt;')
    end
  end
  
  context "when using a WSKey not for the appropriate institutions" do
    before(:all) do
      url = 'https://authn.sd00.worldcat.org/oauth2/accessToken?authenticatingInstitutionId=128807&contextInstitutionId=128807&grant_type=client_credentials&scope=WorldCatDiscoveryAPI'
      stub_request(:post, url).to_return(:body => mock_file_contents("errorTokenInvalidInstitution.json"), :status => 403)
      stub_request(:get, "https://beta.worldcat.org/discovery/offer/oclc/30780581?heldBy=OCPSB").
        to_return(:status => 200, :body => mock_file_contents("offer_set_30780581.rdf"))
      get '/catalog/30780581'
      @doc = Nokogiri::HTML(last_response.body)
      @status = last_response.status
    end
    
    it "should raise an error when calling the find() method on the Bib class" do
      expect(@status).to eq(500)
      error_codes = @doc.xpath("//td[@class='code']/div/text()")
      error_codes = error_codes.map {|error_code| error_code.to_s}
      expect(error_codes).to include("#&lt;OCLC::Auth::Exception: clientId {testKey} doesn't have access to contextIntitutionId {128807}&gt;")
    end
      
  end
  
  context "when using an access token that is not valid" do
    before(:all) do
      url = 'https://authn.sd00.worldcat.org/oauth2/accessToken?authenticatingInstitutionId=128807&contextInstitutionId=128807&grant_type=client_credentials&scope=WorldCatDiscoveryAPI'
      stub_request(:post, url).to_return(:body => mock_file_contents("token.json"), :status => 200)
      stub_request(:get, "https://beta.worldcat.org/discovery/offer/oclc/30780581?heldBy=OCPSB").
        to_return(:status => 401, :body => mock_file_contents("error_response_bad_access_token.rdf"))
      get '/catalog/30780581'
      @doc = Nokogiri::HTML(last_response.body)
    end
    
    it "should display the error section" do
      expect(@doc.xpath("//span[@id='error-heading'][text()='Sorry, there was an authentication error']").size).to eq(1)
    end
  end
  
  context "when using an access token that is not for the right web service" do
    before(:all) do
      url = 'https://authn.sd00.worldcat.org/oauth2/accessToken?authenticatingInstitutionId=128807&contextInstitutionId=128807&grant_type=client_credentials&scope=WorldCatDiscoveryAPI'
      stub_request(:post, url).to_return(:body => mock_file_contents("token.json"), :status => 200)
      stub_request(:get, "https://beta.worldcat.org/discovery/offer/oclc/30780581?heldBy=OCPSB").
        to_return(:status => 403, :body => mock_file_contents("error_response_access_token_wrong_service.rdf"))
      get '/catalog/30780581'
      @doc = Nokogiri::HTML(last_response.body)
    end
    
    it "should display the error section" do
      expect(@doc.xpath("//span[@id='error-heading'][text()='Sorry, there was an authorization error']").size).to eq(1)
    end
  end
  
  context "when sending an empty query" do
    before(:all) do
      url = 'https://authn.sd00.worldcat.org/oauth2/accessToken?authenticatingInstitutionId=128807&contextInstitutionId=128807&grant_type=client_credentials&scope=WorldCatDiscoveryAPI'
      stub_request(:post, url).to_return(:body => mock_file_contents("token.json"), :status => 200)
      stub_request(:get, "https://beta.worldcat.org/discovery/bib/search?q=&heldBy=OCPSB&facetFields=creator:10&dbIds=638").
        to_return(:status => 400, :body => mock_file_contents("error_response_empty_query.rdf"))
      get '/catalog?q='
      @doc = Nokogiri::HTML(last_response.body)
    end

    it "should display the error section" do
      expect(@doc.xpath("//span[@id='error-heading'][text()='Please be sure that your query is not blank.']").size).to eq(1)
    end
  end
  
  context "when trying to display an OCLC number that does not exist" do
    before(:all) do
      url = 'https://authn.sd00.worldcat.org/oauth2/accessToken?authenticatingInstitutionId=128807&contextInstitutionId=128807&grant_type=client_credentials&scope=WorldCatDiscoveryAPI'
      stub_request(:post, url).to_return(:body => mock_file_contents("token.json"), :status => 200)
      stub_request(:get, "https://beta.worldcat.org/discovery/offer/oclc/99999999999999?heldBy=OCPSB").
        to_return(:status => 404, :body => mock_file_contents("error_response_not_found.rdf"))
      get '/catalog/99999999999999'
      @doc = Nokogiri::HTML(last_response.body)
    end

    it "should display the error section" do
      expect(@doc.xpath("//span[@id='error-heading'][text()='Sorry, but the requested record was not found.']").size).to eq(1)
    end

  end
    
end
