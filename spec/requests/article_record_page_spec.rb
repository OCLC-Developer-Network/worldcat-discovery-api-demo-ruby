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
  context "when displaying an article with an issue and volume (5131938809)" do
    before(:all) do
      stub_request(:get, "https://beta.worldcat.org/discovery/bib/data/5131938809").
        to_return(:status => 200, :body => mock_file_contents("5131938809.rdf"))
      get '/record/883876185'
      @doc = Nokogiri::HTML(last_response.body)
    end    
  end
  
  context "when displaying an article with no issue (204144725)" do
    before(:all) do
      stub_request(:get, "https://beta.worldcat.org/discovery/bib/data/204144725").
        to_return(:status => 200, :body => mock_file_contents("204144725.rdf"))
      get '/record/883876185'
      @doc = Nokogiri::HTML(last_response.body)
    end    
  end
  
  context "when displaying an article with no issue or volume  (777986070)" do
    before(:all) do
      stub_request(:get, "https://beta.worldcat.org/discovery/bib/data/777986070").
        to_return(:status => 200, :body => mock_file_contents("777986070.rdf"))
      get '/record/883876185'
      @doc = Nokogiri::HTML(last_response.body)
    end     
  end
end
