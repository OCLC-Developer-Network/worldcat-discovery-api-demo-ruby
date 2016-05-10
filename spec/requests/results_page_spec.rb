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

describe "the results page" do
  before(:all) do
    url = 'https://authn.sd00.worldcat.org/oauth2/accessToken?authenticatingInstitutionId=128807&contextInstitutionId=128807&grant_type=client_credentials&scope=WorldCatDiscoveryAPI'
    stub_request(:post, url).to_return(:body => mock_file_contents("token.json"), :status => 200)
  end
  context "when displaying search results with facets" do
    before(:all) do
      url = 'https://beta.worldcat.org/discovery/bib/search?q=wittgenstein%2Breader&heldBy=OCPSB&facetFields=creator:10&dbIds=638'
      stub_request(:get, url).to_return(:body => mock_file_contents("bib_search.rdf"), :status => 200)
      get '/catalog?q=wittgenstein%2Breader'
      @doc = Nokogiri::HTML(last_response.body)
    end
    
    it "should display the search form" do
      @form_element = @doc.xpath("//form[@id='search-form']")
      expect(@form_element).not_to be_empty
    end
    
    it "should have a form that submits the correct action" do
      submit_location = @doc.xpath("//form[@id='search-form']/@action")
      uri = URI.parse(submit_location.first.value)
      expect(uri.path).to eq('/catalog')
    end
    
    it "should have a form with the previous query in the input box" do
      search_input = @doc.xpath("//input[@name='q'][@value='wittgenstein+reader']")
      expect(search_input).not_to be_empty
    end
    
    it "should display your search query heading" do
      xpath = "//div[@id='your-search']/div/div/h2[text()='Your Search']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display your search query" do
      xpath = "//p[@class='active-items']/span/span[@class='value not-removable'][text()='wittgenstein+reader']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the results" do
      @results = @doc.xpath("//div[@id='search-results']/ol/li")
      expect(@results.count).to eq(10)
    end
    
    it "should display the title for a result" do
      result_title = @doc.xpath("//div[@id='search-results']/ol/li/h3/a/text()").first
      expect(result_title.to_s).to eq("The Wittgenstein reader")
    end
    
    it "should display the date for a result" do
      result_date = @doc.xpath("//div[@id='search-results']/ol/li/h3/span/text()").first
      expect(result_date.to_s).to eq("1994")
    end
    
    it "should display the author for a result" do
      result_author = @doc.xpath("//div[@id='search-results']/ol/li/p[@class='author']/text()").first
      expect(result_author.to_s.gsub("\n", '').squeeze(' ').strip).to eq("Ludwig Wittgenstein, 1889-1951")
    end
    
    it "should display the format for a results" do
      result_format = @doc.xpath("//div[@id='search-results']/ol/li/p[@class='format']/span[@class='value']/text()").first
      expect(result_format.to_s).to eq("Creative Work")
    end
    
    it "should display the facets names" do
      @facets = @doc.xpath("//div[@id='facets']/h3/text()")
      expect(@facets.count).to eq(3)
      @facets = @facets.map {|facet| facet.to_s.gsub("\n", '').squeeze(' ').strip}
      expect(@facets).to include("Format")
      expect(@facets).to include("Author/Creator")
      expect(@facets).to include("Language")
    end
    
    it "should display the facet values" do
      @facet_values = @doc.xpath("//ul[@class='facet-items'][1]/li/a/text()")
      @facet_values = @facet_values.map {|facet_value| facet_value.to_s.gsub("\n", '').squeeze(' ').strip}
      expect(@facet_values.count).to eq(2)
      expect(@facet_values).to include("Article/Chapter")
      expect(@facet_values).to include("Book")
    end
    
    it "should display the facet value counts" do  
      @facet_values_count = @doc.xpath("//ul[@class='facet-items'][1]/li/span/text()")
      expect(@facet_values_count.count).to eq(2)
      @facet_values_count = @facet_values_count.map {|facet_value_count| facet_value_count.to_s.gsub("\n", '').squeeze(' ').strip}
      expect(@facet_values_count).to include("(420)")
      expect(@facet_values_count).to include("(3)")
    end
    
    it "should display the result paging text" do
      paging_text = @doc.xpath("//div[@id='search-results']/div[@class='search-page-navigation span-18 last']/div[@class='numbering span-6']/text()")
      expect(paging_text.to_s.gsub("\n", '').squeeze(' ').strip).to eq("1 - 10 of 423")
    end
    
    it "should display an inactive previous page link" do
      previous_link = @doc.xpath("//div[@id='search-results']/div[@class='search-page-navigation span-18 last']/div/span[@class='inactive-link']/text()")
      expect(previous_link.to_s).to include("Previous")
    end
    
    it "should display an active next page link" do
      next_link = @doc.xpath("//div[@id='search-results']/div[@class='search-page-navigation span-18 last']/div[@class='next span-6 last']/a/text()")
      expect(next_link.to_s).to include("Next")
    end
    
  end
  
  context "when displaying search results with results filtered by facet" do
    before(:all) do
      url = 'https://beta.worldcat.org/discovery/bib/search?q=wittgenstein%2Breader&heldBy=OCPSB&facetFields=creator:10&dbIds=638'
      url += '&facetQueries=itemType:book'
      stub_request(:get, url).to_return(:body => mock_file_contents("bib_search_facet_limit.rdf"), :status => 200)
      get '/catalog?q=wittgenstein%2Breader&facetQueries=itemType%3Abook'
      @doc = Nokogiri::HTML(last_response.body)
    end
    
    it "should display the search form" do
      @form_element = @doc.xpath("//form[@id='search-form']")
      expect(@form_element).not_to be_empty
    end
    
    it "should have a form that submits the correct action" do
      submit_location = @doc.xpath("//form[@id='search-form']/@action")
      uri = URI.parse(submit_location.first.value)
      expect(uri.path).to eq('/catalog')
    end
    
    it "should have a form with the previous query in the input box" do
      search_input = @doc.xpath("//input[@name='q'][@value='wittgenstein+reader']")
      expect(search_input).not_to be_empty
    end
    
    it "should display your search query heading" do
      xpath = "//div[@id='your-search']/div/div/h2[text()='Your Search']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display your search query" do
      xpath = "//p[@class='active-items']/span/span[@class='value not-removable'][text()='wittgenstein+reader']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display your search limit" do
      xpath = "//p[@class='active-items']/span[@class='active-search-item']/span[@class='value'][text()='Book']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should make your search limit removable" do
      xpath = "//p[@class='active-items']/span[@class='active-search-item']/a[@class='remove-item'][text()='Remove facet']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the results" do
       @results = @doc.xpath("//div[@id='search-results']/ol/li")
       expect(@results.count).to eq(3)
    end
    
    it "should display the facets" do
      @facets = @doc.xpath("//div[@id='facets']/h3/text()")
      expect(@facets.count).to eq(3)
      @facets = @facets.map {|facet| facet.to_s.gsub("\n", '').squeeze(' ').strip}
      expect(@facets).to include("Format")
      expect(@facets).to include("Author/Creator")
      expect(@facets).to include("Language")
      
      @facet_values = @doc.xpath("//ul[@class='facet-items'][1]/li/a/text()")
      @facet_values = @facet_values.map {|facet_value| facet_value.to_s.gsub("\n", '').squeeze(' ').strip}
      expect(@facet_values.count).to eq(3)
      expect(@facet_values).to include("Mcguinness, Brian")
      expect(@facet_values).to include("Tejedor, Chon")
      expect(@facet_values).to include("Wittgenstein, Ludwig")
      
      @facet_values_count = @doc.xpath("//ul[@class='facet-items'][1]/li/span/text()")
      expect(@facet_values_count.count).to eq(3)
      @facet_values_count = @facet_values_count.map {|facet_value_count| facet_value_count.to_s.gsub("\n", '').squeeze(' ').strip}
      expect(@facet_values_count).to include("(1)")
      expect(@facet_values_count).to include("(1)")
      expect(@facet_values_count).to include("(1)")
    end    
    
  end
  
  context "when displaying search results neither first or last page" do
    before(:all) do
      url = 'https://beta.worldcat.org/discovery/bib/search?q=wittgenstein%2Breader&heldBy=OCPSB&facetFields=creator:10&dbIds=638'
      url += '&startIndex=10'
      stub_request(:get, url).to_return(:body => mock_file_contents("bib_search_start_index.rdf"), :status => 200)
      get '/catalog?q=wittgenstein%2Breader&startIndex=10'
      @doc = Nokogiri::HTML(last_response.body)
    end
    
    it "should display the results" do
      @results = @doc.xpath("//div[@id='search-results']/ol/li")
      expect(@results.count).to eq(10)
    end
    
    it "should display the result paging text" do
      paging_text = @doc.xpath("//div[@id='search-results']/div[@class='search-page-navigation span-18 last']/div[@class='numbering span-6']/text()")
      expect(paging_text.to_s.gsub("\n", '').squeeze(' ').strip).to eq("11 - 20 of 423")
    end
    
    it "should display an active previous page link" do
      previous_link = @doc.xpath("//div[@id='search-results']/div[@class='search-page-navigation span-18 last']/div[@class='previous span-6 first']/a/text()")
      expect(previous_link.to_s).to include("Previous")
    end
    
    it "should display an active next page link" do
      next_link = @doc.xpath("//div[@id='search-results']/div[@class='search-page-navigation span-18 last']/div[@class='next span-6 last']/a/text()")
      expect(next_link.to_s).to include("Next")
    end
    
  end
  
  context "when displaying search results last page" do
    before(:all) do
      url = 'https://beta.worldcat.org/discovery/bib/search?q=wittgenstein%2Breader&heldBy=OCPSB&facetFields=creator:10&dbIds=638'
      url += '&startIndex=420'
      stub_request(:get, url).to_return(:body => mock_file_contents("bib_search_last_page.rdf"), :status => 200)
      get '/catalog?q=wittgenstein%2Breader&startIndex=420'
      @doc = Nokogiri::HTML(last_response.body)
    end
    
    it "should display the results" do
      @results = @doc.xpath("//div[@id='search-results']/ol/li")
      expect(@results.count).to eq(3)
    end
    
    it "should display the result paging text" do
      paging_text = @doc.xpath("//div[@id='search-results']/div[@class='search-page-navigation span-18 last']/div[@class='numbering span-6']/text()")
      expect(paging_text.to_s.gsub("\n", '').squeeze(' ').strip).to eq("421 - 423 of 423")
    end
    
    it "should display an active previous page link" do
      previous_link = @doc.xpath("//div[@id='search-results']/div[@class='search-page-navigation span-18 last']/div[@class='previous span-6 first']/a/text()")
      expect(previous_link.to_s).to include("Previous")
    end
    
    it "should display an inactive next page link" do
      next_link = @doc.xpath("//div[@id='search-results']/div[@class='search-page-navigation span-18 last']/div[@class='next span-6 last']/span[@class='inactive-link']")
      expect(next_link.to_s).to include("Next")
    end
  end
  
end
