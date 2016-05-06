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

describe "the article record page" do
  before(:all) do
    url = 'https://authn.sd00.worldcat.org/oauth2/accessToken?authenticatingInstitutionId=128807&contextInstitutionId=128807&grant_type=client_credentials&scope=WorldCatDiscoveryAPI'
    stub_request(:post, url).to_return(:body => mock_file_contents("token.json"), :status => 200)
  end
  context "when displaying an article with an issue and volume (5131938809)" do
    before(:all) do
      stub_request(:get, "https://beta.worldcat.org/discovery/offer/oclc/5131938809?heldBy=OCPSB").
        to_return(:status => 200, :body => mock_file_contents("offer_set_5131938809.rdf"))
      get '/record/5131938809'
      @doc = Nokogiri::HTML(last_response.body)
    end    
  end
  
  context "when displaying an article with no issue (204144725)" do
    before(:all) do
      stub_request(:get, "https://beta.worldcat.org/discovery/offer/oclc/204144725?heldBy=OCPSB").
        to_return(:status => 200, :body => mock_file_contents("offer_set_204144725.rdf"))
      get '/record/204144725'
      @doc = Nokogiri::HTML(last_response.body)
    end    
  end
  
  context "when displaying an article with no issue or volume  (777986070)" do
    before(:all) do
      stub_request(:get, "https://beta.worldcat.org/discovery/offer/oclc/777986070?heldBy=OCPSB").
        to_return(:status => 200, :body => mock_file_contents("offer_set_777986070.rdf"))
      get '/record/777986070'
      @doc = Nokogiri::HTML(last_response.body)
    end     
  end
end
