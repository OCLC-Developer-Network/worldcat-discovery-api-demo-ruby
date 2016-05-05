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
  context "when displaying a movie (62774704)" do
    before(:all) do
      stub_request(:get, "https://beta.worldcat.org/discovery/bib/data/62774704").
        to_return(:status => 200, :body => mock_file_contents("62774704.rdf"))
      get '/record/883876185'
      @doc = Nokogiri::HTML(last_response.body)
    end     
    
    it "should display the title" do
      xpath = "//h1[@id='bibliographic-resource-name'][text()='Pride & prejudice']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the subjects" do
      @subjects = @doc.xpath("//ul[@id='subjects']/li/span/a/text()")  
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
      @genres = @doc.xpath("//ul[@id='genres']/li/span/a/text()")  
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
      #this is busted
      xpath = "//span[@id='format'][text()='Movie, DVD']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the language" do
      #this is busted
      xpath = "//span[@id='language'][text()='English']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the publication places" do
      @publiciationPlaces = @doc.xpath("//span[@property='library:placeOfPublication']/text()")
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
      expect(@descriptions).to eq(2)
      File.open("#{File.expand_path(File.dirname(__FILE__))}/../../support/text/62774704_descriptions.txt").each do |line|
        expect(@descriptions).to include(line.chomp)
      end
    end
    
    it "should display the actors" do
      @actors = @doc.xpath("//ul[@id='actors']/li/span/a/text()")
      expect(@actors.size).to eq(8)
      expect(@actors).not_to be_empty
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
      @director = @doc.xpath("//ul[@id='director']/li/span/a/text()")
      expect(@director.size).to eq(1)
      expect(@director).not_to be_empty
      expect(@director).to include("Joe Wright, 1972-")
    end
    
    it "should display the producers" do
      @producers = @doc.xpath("//ul[@id='producers']/li/span/a/text()")
      expect(@producers.size).to eq(3)
      expect(@producers).not_to be_empty
      expect(@producers).to include("Paul Webster, 1952 September 19-")
      expect(@producers).to include("Tim Bevan")
      expect(@producers).to include("Eric Fellner") 
    end
    
  end
  
end
