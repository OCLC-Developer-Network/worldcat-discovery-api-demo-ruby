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

describe "the record page" do
  context "when loading any record" do
    before(:all) do
      stub_request(:get, "https://beta.worldcat.org/discovery/bib/data/30780581").
        to_return(:status => 200, :body => mock_file_contents("30780581.rdf"))
      get '/record/30780581'
      @doc = Nokogiri::HTML(last_response.body)
    end
        
    it "should display the library name" do
      xpath = "//div[@id='header']/h1[text()='OCLC Sandbox Library']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the search form" do
      @form_element = @doc.xpath("//form[@id='record-form']")
      expect(@form_element).not_to be_empty
    end

  end
  
  context "when displaying record for a book" do
    before(:all) do
      stub_request(:get, "https://beta.worldcat.org/discovery/bib/data/30780581").
        to_return(:status => 200, :body => mock_file_contents("30780581.rdf"))
      get '/record/30780581'
      @doc = Nokogiri::HTML(last_response.body)
    end
    
    it "should display the title" do
      xpath = "//h1[@id='bibliographic-resource-name'][text()='The Wittgenstein reader']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the author" do
      xpath = "//h2[@id='author-name']/a[text()='Wittgenstein, Ludwig, 1889-1951.']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the contributors" do
      @contributors = @doc.xpath("//ul[@id='contributors']/li/span/a/text()")
      expect(@contributors.size).to eq(1)
      expect(@contributors).not_to be_empty
    end
    
    it "should display the subjects" do
      @subjects = @doc.xpath("//ul[@id='subjects']/li/span/a/text()")
      expect(@subjects).to include("Philosophy")
    end
    
    it "should display the format" do
      #this is busted
      xpath = "//span[@id='format'][text()='http://bibliograph.net/PrintBook']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the language" do
      #this is busted
      xpath = "//span[@id='language'][text()='English']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the publication places" do
      @publiciationPlaces = @doc.xpath("//span[@property='library:placeOfPublication']/text()")
      expect(@publiciationPlaces).to include("Cambridge, Mass., USA :")
      expect(@publiciationPlaces).to include("Oxford, UK :")
    end
    
    it "should display the publisher" do
      xpath = "//span[@property='schema:publisher']/span[@property='schema:name'][text()='B. Blackwell']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the date published" do
      xpath = "//span[@property='schema:datePublished'][text()='1994']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the ISBNs" do
      xpath = "//span[@property='schema:isbn'][text()='0631193618, 0631193626, 9780631193616, 9780631193623']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the OCLC Number" do
      xpath = "//span[@property='library:oclcnum'][text()='30780581']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the descriptions" do
      @descriptions = @doc.xpath("//p[@property='schema:description']/text()")
      expect(@descriptions).to eq(2)
      File.open("#{File.expand_path(File.dirname(__FILE__))}/../../support/text/30780581_descriptions.txt").each do |line|
        expect(@descriptions).to include(line.chomp)
      end
    end
  end
  
  context "when displaying record for a book with awards (41266045)" do
    before(:all) do
      stub_request(:get, "https://beta.worldcat.org/discovery/bib/data/41266045").
        to_return(:status => 200, :body => mock_file_contents("41266045.rdf"))
      get '/record/41266045'
      @doc = Nokogiri::HTML(last_response.body)
    end
    
    it "should have the right awards" do
      #template has to be altered
     @awards = @doc.xpath("//ul[@id='awards']/li/span/a")
     expect(@awards).to include("ALA Notable Children's Book, 2000.")
     expect(@awards).to include("Whitbread Children's Book of the Year, 1999.")
    end
    
    it "should have the right content_rating" do
      #template has to be altered
      xpath = "//span[@property='schema:contentRating'][text()='Middle School.']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
  end
  
  context "when displaying record for a book with genres (7977212)" do
    before(:all) do
      stub_request(:get, "https://beta.worldcat.org/discovery/bib/data/7977212").
        to_return(:status => 200, :body => mock_file_contents("7977212.rdf"))
      get '/record/7977212'
      @doc = Nokogiri::HTML(last_response.body)
    end
    
    it "should display the genres" do
      @genres = @doc.xpath("//ul[@id='genres']/li/span/a/text()")
      expect(@genres).to include("Poetry")
    end
  end 
  
  context "when displaying record for a book with illustrators (15317067)" do
    before(:all) do
      stub_request(:get, "https://beta.worldcat.org/discovery/bib/data/15317067").
        to_return(:status => 200, :body => mock_file_contents("15317067.rdf"))
      get '/record/15317067'
      @doc = Nokogiri::HTML(last_response.body)
    end
    
    it "should display the illustrators" do
      #template needs to be altered
      @illustrators = @doc.xpath("//ul[@id='illustrators']/li/a/text()")
      expect(@illustrators.size).to eq(1)
      expect(@illustrators).not_to be_empty
      expect(@illustrators).to include("Bernadette Watts")
    end
    
    it "should have the right audience" do
      #template has to be altered
      xpath = "//span[@property='schema:audience'][text()='Juvenile']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end 
    
    it "should return the right book_format" do
      #template has to be altered
      xpath = "//span[@property='schema:bookFormat'][text()='http://bibliograph.net/PrintBook']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end 
  end  
  
  context "when displaying record for a book with editors (1004282)" do
    before(:all) do
      stub_request(:get, "https://beta.worldcat.org/discovery/bib/data/1004282").
        to_return(:status => 200, :body => mock_file_contents("1004282.rdf"))
      get '/record/1004282'
      @doc = Nokogiri::HTML(last_response.body)
    end
    
    it "should display the editors" do
      #template needs to be altered
      @editors = @doc.xpath("//ul[@id='editors']/li/a/text()")
      expect(@editors.size).to eq(1)
      expect(@editors).not_to be_empty
      expect(@editors).to include("Dunn, Jacob Piatt, 1855-1924.")
    end
  end 
  
  context "when displaying record for a book with reviews (57422379)" do
    before(:all) do
      stub_request(:get, "https://beta.worldcat.org/discovery/bib/data/57422379").
        to_return(:status => 200, :body => mock_file_contents("57422379.rdf"))
      get '/record/57422379'
      @doc = Nokogiri::HTML(last_response.body)
    end
    
    it "should display the reviews" do
      @reviews = @doc.xpath("//span[@property='reviewBody']/text()")
      expect(@reviews.size).to eq(1)
      expect(@reviews).not_to be_empty
    end
  end
end
