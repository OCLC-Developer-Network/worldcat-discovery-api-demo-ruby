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
      @subjects.should include("Young women")
      @subjects.should include("Social conditions")
      @subjects.should include("Courtship")
      @subjects.should include("Jane Austen")
      @subjects.should include("(Fictitious character) Fitzwilliam Darcy")
      @subjects.should include("Man-woman relationships")
      @subjects.should include("(Fictitious character) Elizabeth Bennet")
      @subjects.should include("Social classes")
      @subjects.should include("Women--Social conditions")
      @subjects.should include("Sisters")
      @subjects.should include("Manners and customs")
      @subjects.should include("England")
    end

    it "should display the genres" do
      @genres = @doc.xpath("//ul[@id='genres']/li/span/a/text()")  
      @genres.should include("Melodrama, English")    
      @genres.should include("Drama")
      @genres.should include("Melodrama")
      @genres.should include("Feature films")
      @genres.should include("Romance films")
      @genres.should include("Film adaptations")
      @genres.should include("Fiction films")
      @genres.should include("Romantic plays")
      @genres.should include("Video recordings for the hearing impaired")
      @genres.should include("Romance")
      @genres.should include("Fiction")
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
      @publiciationPlaces.should include("Universal City, CA :")
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
        @descriptions.should include(line.chomp)
      end
    end
    
    it "should display the actors" do
      @actors = @doc.xpath("//ul[@id='actors']/li/span/a/text()")
      expect(@actors.size).to eq(8)
      expect(@actors).not_to be_empty
      @actors.should include("Tom Hollander, 1967-")
      @actors.should include("Brenda Blethyn, 1946-")
      @actors.should include("Matthew Macfadyen, 1974-")
      @actors.should include("Donald Sutherland, 1935-")
      @actors.should include("Judi Dench, 1934-")
      @actors.should include("Keira Knightley, 1985-")
      @actors.should include("Jena Malone, 1984-")
      @actors.should include("Rosamund Pike, 1979-")
    end
    
    it "should display the director" do
      @director = @doc.xpath("//ul[@id='director']/li/span/a/text()")
      expect(@director.size).to eq(1)
      expect(@director).not_to be_empty
      expect(@director).should include("Joe Wright, 1972-")
    end
    
    it "should display the producers" do
      @producers = @doc.xpath("//ul[@id='producers']/li/span/a/text()")
      expect(@producers.size).to eq(3)
      expect(@producers).not_to be_empty
      @producers.should include("Paul Webster, 1952 September 19-")
      @producers.should include("Tim Bevan")
      @producers.should include("Eric Fellner") 
    end
    
  end
  
end
