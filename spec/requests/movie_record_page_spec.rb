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
  context "when displaying a movie (62774704)" do
    before(:all) do
      stub_request(:get, "https://beta.worldcat.org/discovery/offer/oclc/62774704?heldBy=OCPSB").
        to_return(:status => 200, :body => mock_file_contents("offer_set_62774704.rdf"))  
      get '/catalog/62774704'
      @doc = Nokogiri::HTML(last_response.body)
    end     
    
    it "should display the title" do
      xpath = "//h1[@id='bibliographic-resource-name'][text()='Pride & prejudice']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the subjects" do
      @subjects = @doc.xpath("//ul[@id='subjects']/li/span/a/text()") 
      
      expect(@subjects.count).to eq(12)
      @subjects = @subjects.map {|subject_value| subject_value.to_s} 
      expect(@subjects).to include("Young women")
      expect(@subjects).to include("Social conditions")
      expect(@subjects).to include("Courtship")
      expect(@subjects).to include("Jane Austen")
      expect(@subjects).to include("(Fictitious character) Fitzwilliam Darcy")
      expect(@subjects).to include("Man-woman relationships")
      expect(@subjects).to include("(Fictitious character) Elizabeth Bennet")
      expect(@subjects).to include("Social classes")
      expect(@subjects).to include("Women--Social conditions")
      expect(@subjects).to include("Sisters")
      expect(@subjects).to include("Manners and customs")
      expect(@subjects).to include("England")
    end

    it "should display the genres" do
      @genres = @doc.xpath("//ul[@id='genres']/li/a/text()")  
      
      expect(@genres.count).to eq(11)
      @genres = @genres.map {|genres_value| genres_value.to_s} 
      expect(@genres).to include("Melodrama, English")    
      expect(@genres).to include("Drama")
      expect(@genres).to include("Melodrama")
      expect(@genres).to include("Feature films")
      expect(@genres).to include("Romance films")
      expect(@genres).to include("Film adaptations")
      expect(@genres).to include("Fiction films")
      expect(@genres).to include("Romantic plays")
      expect(@genres).to include("Video recordings for the hearing impaired")
      expect(@genres).to include("Romance")
      expect(@genres).to include("Fiction")
    end

    it "should display the format" do
      xpath = "//span[@id='format'][text()='Movie, DVD']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the language" do
      xpath = "//span[@id='language'][text()='English']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the publication places" do
      @publiciationPlaces = @doc.xpath("//span[@property='library:placeOfPublication']/text()")
      expect(@publiciationPlaces.count).to eq(2)
      @publiciationPlaces = @publiciationPlaces.map {|publiciationPlace| publiciationPlace.to_s}
      expect(@publiciationPlaces).to include("Universal City, CA :")
    end
    
    it "should display the publisher" do
      xpath = "//span[@property='schema:publisher']/span[@property='schema:name'][text()='Universal Studios Home Entertainment']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the ISBNs" do
      xpath = "//span[@property='schema:isbn'][text()='1417055065, 9781417055067']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the OCLC Number" do
      xpath = "//span[@property='library:oclcnum'][text()='62774704']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the descriptions" do
      @descriptions = @doc.xpath("//p[@property='schema:description']/text()")
      expect(@descriptions.count).to eq(2)
      @descriptions = @descriptions.map {|description| description.to_s}
      File.open("#{File.expand_path(File.dirname(__FILE__))}/../text/62774704_descriptions.txt").each do |line|
        expect(@descriptions).to include(line.chomp)
      end
    end
    
    it "should display the actors" do
      @actors = @doc.xpath("//ul[@id='actors']/li/span/a/text()")
      expect(@actors.size).to eq(8)
      @actors = @actors.map {|actor| actor.to_s.gsub("\n", '').squeeze(' ').strip}
      expect(@actors).to include("Tom Hollander, 1967-")
      expect(@actors).to include("Brenda Blethyn, 1946-")
      expect(@actors).to include("Matthew Macfadyen, 1974-")
      expect(@actors).to include("Donald Sutherland, 1935-")
      expect(@actors).to include("Judi Dench, 1934-")
      expect(@actors).to include("Keira Knightley, 1985-")
      expect(@actors).to include("Jena Malone, 1984-")
      expect(@actors).to include("Rosamund Pike, 1979-")
    end
    
    it "should display the director" do
      @directors = @doc.xpath("//p/span[@id='director']/span/a/text()")
      expect(@directors.size).to eq(1)
      @directors = @directors.map {|director| director.to_s.gsub("\n", '').squeeze(' ').strip}
      expect(@directors).to include("Joe Wright, 1972-")
    end
    
    it "should display the producers" do
      @producers = @doc.xpath("//ul[@id='producers']/li/span/a/text()")
      expect(@producers.size).to eq(3)
      @producers = @producers.map {|producer| producer.to_s.gsub("\n", '').squeeze(' ').strip}
      expect(@producers).to include("Paul Webster, 1952 September 19-")
      expect(@producers).to include("Tim Bevan")
      expect(@producers).to include("Eric Fellner") 
    end
    
  end
  
end
