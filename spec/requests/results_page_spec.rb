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
  context "when displaying search results with facets" do
    before(:all) do
      url = 'https://beta.worldcat.org/discovery/bib/search?q=wittgenstein+reader&facetFields=creator:10&facetFields=inLanguage:10&facetFields=itemType:10&dbIds=638'
      stub_request(:get, url).to_return(:body => body_content("bib_search.rdf"), :status => 200)
      get '/catalog?q=wittgenstein%2Breader&scope=my_library'
      @doc = Nokogiri::HTML(last_response.body)
    end
    
    it "should display the search form" do
      @form_element = @doc.xpath("//form[@id='record-form']")
      expect(@form_element).not_to be_empty
    end
    
    it "should have a form that submits the correct action" do
      submit_location = @form_element.attr('action')
      uri = URI.parse(submit_location)
      expect(uri.path).to eq('/catalog')
    end
    
    it "should have a form with the previous query in the input box" do
      search_input = @form_element.xpath("../p/input[@value='wittgenstein+reader']")
      expect(search_input).not_to be_empty
    end
    
    it "should display your search query heading" do
      xpath = "//div[@id='your-search']/div/div/h2[text()='Your Search']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display your search query" do
      xpath = "//div[@id='your-search']/p/span/span[@class='value not-removable'][text()='wittgenstein+reader']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the results" do
      @results = @doc.xpath("//div[@id='search-results']/ol/li")
      expect(@results.count).to eq(10)
    end
    
    it "should display the title for a result" do
      result_title = @results.xpath("../h3/a/text()").first
      expect(result_title).to eq("The Wittgenstein reader")
    end
    
    it "should display the date for a result" do
      result_date = @results.xpath("../h3/span/text()").first
      expect(result_date).to eq("1994")
    end
    
    it "should display the author for a result" do
      result_author = @results.xpath("../p[@class='author']/text()").first
      expect(result_author).to eq("Ludwig Wittgenstein, 1889-1951 ")
    end
    
    it "should display the format for a results" do
      result_format = @results.xpath("../p[@class='format']/span[@class='value']/text()").first
      expect(result_format).to eq("Creative Work")
    end
    
    it "should display the facets" do
      @facets = @doc.xpath("//div[@id='facets']/h3/text()")
      expect(@facets.count).to eq(3)
      expect(@facets).to include("Format")
      expect(@facets).to include("Author/Creator")
      expect(@facets).to include("Language")
      
      @facet_values = @doc.xpath("//ul[@id='facets-items']/first()/li/a")
      expect(@facet_values.count).to eq(2)
      expect(@facet_values).to include("Article/Chapter")
      expect(@facets).to include("Book")
      
      @facet_values_count = @doc.xpath("//ul[@id='facets-items']/first()/li/span")
      expect(@facet_values_count.count).to eq(2)
      expect(@facet_values_count).to include(" (420)")
      expect(@facets).to include("(2)")
    end
    
    it "should display the result paging text" do
      paging_text = @doc.xpath("//div[@id='search-results']/div[@class='search-page-navigation span-18 last']/div[@class='numbering span-6']/text()")
      expect(paging_text).to eq("1 - 10 of 422")
    end
    
    it "should display an inactive previous page link" do
      previous_link = @doc.xpath("//div[@id='search-results']/div[@class='search-page-navigation span-18 last']/div[@class='previous span-6 first'/span[@class='inactive-link']")
      expect(previous_link.not_to be_empty)
      expect(previous_link.xpath('../text()')).to eq("&laquo; Previous")
    end
    
    it "should display an active next page link" do
      next_link = @doc.xpath("//div[@id='search-results']/div[@class='search-page-navigation span-18 last']/div[@class='next span-6 last'/a")
      expect(next_link.not_to be_empty)
      expect(next_link.xpath('../text()')).to eq("Next &raquo;")
    end
    
  end
  
  context "when displaying search results with results filtered by facet" do
    before(:all) do
      url = 'https://beta.worldcat.org/discovery/bib/search?q=wittgenstein+reader&facetFields=creator:10&facetFields=inLanguage:10&itemType:10&dbIds=638'
      url += '&facetQueries=itemType:book'
      stub_request(:get, url).to_return(:body => body_content("bib_search_facet_limit.rdf"), :status => 200)
      get '/catalog?q=wittgenstein reader&scope=my_library&facetQueries=itemType%3Abook', params={}, rack_env={ 'rack.session' => {:token => @access_tokend} }
      @doc = Nokogiri::HTML(last_response.body)
    end
    
    it "should display the search form" do
      @form_element = @doc.xpath("//form[@id='record-form']")
      expect(@form_element).not_to be_empty
    end
    
    it "should have a form that submits the correct action" do
      submit_location = @form_element.attr('action')
      uri = URI.parse(submit_location)
      expect(uri.path).to eq('/catalog')
    end
    
    it "should have a form with the previous query in the input box" do
      search_input = @form_element.xpath("../p/input[@value='wittgenstein+reader']")
      expect(search_input).not_to be_empty
    end
    
    it "should display your search query heading" do
      xpath = "//div[@id='your-search']/div/div/h2[text()='Your Search']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display your search query" do
      xpath = "//div[@id='your-search']/p/span/span[@class='value not-removable'][text()='wittgenstein+reader']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display your search limit" do
      #need to change template to test this
      xpath = "//div[@id='your-search']/p/span[@id='format-limit']/span[text()='Book']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should make your search limit removable" do
      xpath = "//div[@id='your-search']/p/span/a[@class='remove-item'][text()='Remove']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the results" do
       @results = @doc.xpath("//div[@id='search-results']/ol/li")
       expect(@results.count).to eq(2)
    end
    
    it "should display the facets" do
      @facets = @doc.xpath("//div[@id='facets']/h3/text()")
      expect(@facets.count).to eq(3)
      expect(@facets).to include("Format")
      expect(@facets).to include("Author/Creator")
      expect(@facets).to include("Language")
      
      @facet_values = @doc.xpath("//ul[@id='facets-items'][1]/li/a")
      expect(@facet_values.count).to eq(1)
      expect(@facets).to include("Book")
      
      @facet_values_count = @doc.xpath("//ul[@id='facets-items'][1]/li/span")
      expect(@facet_values_count.count).to eq(1)
      expect(@facets).to include("(2)")
    end    
    
  end
  
  context "when displaying search results neither first or last page" do
    before(:all) do
      url = 'https://beta.worldcat.org/discovery/bib/search?q=wittgenstein+reader&facetFields=creator:10&facetFields=inLanguage:10&itemType:10&dbIds=638'
      url += '&startIndex=10'
      stub_request(:get, url).to_return(:body => body_content("bib_search_start_index.rdf"), :status => 200)
      get '/catalog?q=wittgenstein reader&scope=my_library&startIndex=10', params={}, rack_env={ 'rack.session' => {:token => @access_tokend} }
      @doc = Nokogiri::HTML(last_response.body)
    end
    
    it "should display the results" do
      @results = @doc.xpath("//div[@id='search-results']/ol/li")
      expect(@results.count).to eq(10)
    end
    
    it "should display the result paging text" do
      paging_text = @doc.xpath("//div[@id='search-results']/div[@class='search-page-navigation span-18 last']/div[@class='numbering span-6']/text()")
      expect(paging_text).to eq("11 - 20 of 422")
    end
    
    it "should display an active previous page link" do
      previous_link = @doc.xpath("//div[@id='search-results']/div[@class='search-page-navigation span-18 last']/div[@class='previous span-6 first'/a")
      expect(previous_link).not_to be_empty
      expect(previous_link.xpath('../text()')).to eq("&laquo; Previous")
    end
    
    it "should display an active next page link" do
      next_link = @doc.xpath("//div[@id='search-results']/div[@class='search-page-navigation span-18 last']/div[@class='next span-6 last'/a")
      expect(next_link).not_to be_empty
      expect(next_link.xpath('../text()')).to eq("Next &raquo;")
    end
    
  end
  
  context "when displaying search results last page" do
    before(:all) do
      url = 'https://beta.worldcat.org/discovery/bib/search?q=wittgenstein+reader&facetFields=creator:10&facetFields=inLanguage:10&itemType:10&dbIds=638'
      url += '&startIndex=420'
      stub_request(:get, url).to_return(:body => body_content("bib_search_last_page.rdf"), :status => 200)
      get '/catalog?q=wittgenstein reader&scope=my_library&startIndex=410', params={}, rack_env={ 'rack.session' => {:token => @access_tokend} }
      @doc = Nokogiri::HTML(last_response.body)
    end
    
    it "should display the results" do
      @results = @doc.xpath("//div[@id='search-results']/ol/li")
      expect(@results.count).to eq(2)
    end
    
    it "should display the result paging text" do
      paging_text = @doc.xpath("//div[@id='search-results']/div[@class='search-page-navigation span-18 last']/div[@class='numbering span-6']/text()")
      expect(paging_text).to eq("421 - 422 of 422")
    end
    
    it "should display an active previous page link" do
      previous_link = @doc.xpath("//div[@id='search-results']/div[@class='search-page-navigation span-18 last']/div[@class='previous span-6 first'/a")
      expect(previous_link).not_to be_empty
      expect(previous_link.xpath('../text()')).to eq("&laquo; Previous")
    end
    
    it "should display an inactive next page link" do
      next_link = @doc.xpath("//div[@id='search-results']/div[@class='search-page-navigation span-18 last']/div[@class='next span-6 last'/span[@class='inactive-link']")
      expect(next_link).not_to be_empty
      expect(next_link.xpath('../text()')).to eq("Next &raquo;")
    end
  end
  
end
