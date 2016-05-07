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
  before(:all) do
    url = 'https://authn.sd00.worldcat.org/oauth2/accessToken?authenticatingInstitutionId=128807&contextInstitutionId=128807&grant_type=client_credentials&scope=WorldCatDiscoveryAPI'
    stub_request(:post, url).to_return(:body => mock_file_contents("token.json"), :status => 200)
  end
  context "when loading any record" do
    before(:all) do
      stub_request(:get, "https://beta.worldcat.org/discovery/offer/oclc/30780581?heldBy=OCPSB").
        to_return(:status => 200, :body => mock_file_contents("offer_set_30780581.rdf"))
      get '/catalog/30780581'
      @doc = Nokogiri::HTML(last_response.body)
    end
        
    it "should display the library name" do
      xpath = "//h1[text()='OCLC Sandbox Library']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the search form" do
      @form_element = @doc.xpath("//form[@id='search-form']")
      expect(@form_element).not_to be_empty
    end
  end
  
  context "when displaying record for a book" do
    before(:all) do
      stub_request(:get, "https://beta.worldcat.org/discovery/offer/oclc/30780581?heldBy=OCPSB").
        to_return(:status => 200, :body => mock_file_contents("offer_set_30780581.rdf"))
      get '/catalog/30780581'
      @doc = Nokogiri::HTML(last_response.body)
    end
    
    it "should display the title" do
      xpath = "//h1[@id='bibliographic-resource-name'][text()='The Wittgenstein reader']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the author" do
      author_name = @doc.xpath("//h2[@id='author-name']/a/text()")
      expect(author_name.to_s.gsub("\n", '').squeeze(' ').strip).to be == "Ludwig Wittgenstein, 1889-1951"
    end
    
    it "should display the contributors" do
      @contributors = @doc.xpath("//ul[@id='contributors']/li/span/a/text()")
      expect(@contributors.size).to eq(1)
      expect(@contributors).not_to be_empty
    end
    
    it "should display the subjects" do
      @subjects = @doc.xpath("//ul[@id='subjects']/li/span/a/text()")
      
      expect(@subjects.count).to eq(1)
      @subjects = @subjects.map {|subject_value| subject_value.to_s}
      expect(@subjects).to include("Philosophy")
    end
    
    it "should display the format" do
      xpath = "//span[@id='format'][text()='http://bibliograph.net/PrintBook']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the language" do
      xpath = "//span[@id='language'][text()='English']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the edition" do
      xpath = "//span[@id='edition']"
      expect(@doc.xpath(xpath)).to be_empty
    end
    
    it "should display the publication places" do
      @publiciation_places = @doc.xpath("//span[@property='library:placeOfPublication']/text()")
      
      expect(@publiciation_places.count).to eq(3)
      @publiciation_places = @publiciation_places.map {|publiciation_place| publiciation_place.to_s}
      expect(@publiciation_places).to include("Cambridge, Mass., USA :")
      expect(@publiciation_places).to include("Oxford, UK :")
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
      expect(@descriptions.count).to eq(2)
      @descriptions = @descriptions.map {|description| description.to_s}
      File.open("#{File.expand_path(File.dirname(__FILE__))}/../text/30780581_descriptions.txt").each do |line|
        expect(@descriptions).to include(line.chomp)
      end
    end
  end
  
  context "when displaying record for a book with awards (41266045)" do
    before(:all) do
      stub_request(:get, "https://beta.worldcat.org/discovery/offer/oclc/41266045?heldBy=OCPSB").
        to_return(:status => 200, :body => mock_file_contents("offer_set_41266045.rdf"))
      get '/catalog/41266045'
      @doc = Nokogiri::HTML(last_response.body)
    end
    
    it "should have the right awards" do
     @awards = @doc.xpath("//ul[@id='awards']/li/text()")
     expect(@awards.count).to eq(2)
     @awards = @awards.map {|award| award.to_s}
     expect(@awards).to include("ALA Notable Children's Book, 2000.")
     expect(@awards).to include("Whitbread Children's Book of the Year, 1999.")
    end
    
    it "should have the right content_rating" do
      xpath = "//p/span[@property='schema:contentRating'][text()='Middle School.']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
  end
  
  context "when displaying record for a book with genres (7977212)" do
    before(:all) do
      stub_request(:get, "https://beta.worldcat.org/discovery/offer/oclc/7977212?heldBy=OCPSB").
        to_return(:status => 200, :body => mock_file_contents("offer_set_7977212.rdf"))
      get '/catalog/7977212'
      @doc = Nokogiri::HTML(last_response.body)
    end
    
    it "should display the genres" do
      @genres = @doc.xpath("//ul[@id='genres']/li/a/text()")  
      
      expect(@genres.count).to eq(1)
      @genres = @genres.map {|genres_value| genres_value.to_s}
      expect(@genres).to include("Poetry")
    end
  end 
  
  context "when displaying record for a book with illustrators (15317067)" do
    before(:all) do
      stub_request(:get, "https://beta.worldcat.org/discovery/offer/oclc/15317067?heldBy=OCPSB").
        to_return(:status => 200, :body => mock_file_contents("offer_set_15317067.rdf"))
      get '/catalog/15317067'
      @doc = Nokogiri::HTML(last_response.body)
    end
    
    it "should display the illustrators" do
      @illustrators = @doc.xpath("//ul[@id='illustrators']/li/span/a/text()")
      expect(@illustrators.size).to eq(1)
      @illustrators = @illustrators.map {|illustrator| illustrator.to_s.gsub("\n", '').squeeze(' ').strip}
      expect(@illustrators).to include("Bernadette Watts")
    end
    
    it "should have the right audience" do
      xpath = "//span[@property='schema:audience'][text()='Juvenile']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end 
    
    it "should display the format" do
      xpath = "//span[@id='format'][text()='http://bibliograph.net/PrintBook']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
  end  
  
  context "when displaying record for a book with editors (1004282)" do
    before(:all) do
      stub_request(:get, "https://beta.worldcat.org/discovery/offer/oclc/1004282?heldBy=OCPSB").
        to_return(:status => 200, :body => mock_file_contents("offer_set_1004282.rdf"))
      get '/catalog/1004282'
      @doc = Nokogiri::HTML(last_response.body)
    end
    
    it "should display the editors" do
      @editors = @doc.xpath("//ul[@id='editors']/li/span/a/text()")
      expect(@editors.size).to eq(1)
      @editors = @editors.map {|editor| editor.to_s.gsub("\n", '').squeeze(' ').strip}
      expect(@editors).to include("Jacob Piatt Dunn, 1855-1924")
    end
  end 
  
  context "when displaying record for a book with reviews (57422379)" do
    before(:all) do
      stub_request(:get, "https://beta.worldcat.org/discovery/offer/oclc/57422379?heldBy=OCPSB").
        to_return(:status => 200, :body => mock_file_contents("offer_set_57422379.rdf"))
      get '/catalog/57422379'
      @doc = Nokogiri::HTML(last_response.body)
    end
    
    it "should display the reviews" do
      @reviews = @doc.xpath("//span[@property='schema:reviewBody']/text()")
      expect(@reviews.size).to eq(1)
      @reviews = @reviews.map {|review| review.to_s}
      File.open("#{File.expand_path(File.dirname(__FILE__))}/../text/57422379_reviews.txt").each do |line|
        expect(@reviews).to include(line.chomp)
      end      
    end
  end
end
