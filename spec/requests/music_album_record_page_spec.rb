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
  context "when displaying a music album (226390945)" do
    before(:all) do
      stub_request(:get, "https://beta.worldcat.org/discovery/offer/oclc/226390945?heldBy=OCPSB").
        to_return(:status => 200, :body => mock_file_contents("offer_set_226390945.rdf"))
      get '/catalog/226390945'
      @doc = Nokogiri::HTML(last_response.body)
    end     
    
    it "should display the title" do
      xpath = "//h1[@id='bibliographic-resource-name'][text()='Song for an uncertain lady']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the alternate name" do
      xpath = "//p[@property='schema:alternateName'][text()='Songs for an uncertain lady']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end

    it "should display the see_alsos" do
      @see_alsos = @doc.xpath("//ul[@id='see_alsos']/li/span/a/text()")
      expect(@see_alsos.count).to eq(11)
      @see_alsos = @see_alsos.map {|see_also| see_also.to_s.gsub("\n", '').squeeze(' ').strip} 
      expect(@see_alsos).to include("Sorrow's children.")
      expect(@see_alsos).to include("Lisa.")
      expect(@see_alsos).to include("Autumn on your mind.")
      expect(@see_alsos).to include("Waiting for an old friend.")
      expect(@see_alsos).to include("Maybelline.")
      expect(@see_alsos).to include("Song for an uncertain lady.")
      expect(@see_alsos).to include("Child for now.")
      expect(@see_alsos).to include("Africa.")
      expect(@see_alsos).to include("One I thought was there.")
      expect(@see_alsos).to include("Only time will make you see.")
      expect(@see_alsos).to include("Let tomorrow be.")
    end
        
    it "should display the subjects" do
      @subjects = @doc.xpath("//ul[@id='subjects']/li/span/a/text()")
      expect(@subjects.count).to eq(3)
      @subjects = @subjects.map {|subject_value| subject_value.to_s} 
      expect(@subjects).to include("Rock music")
      expect(@subjects).to include("Folk music")
      expect(@subjects).to include("Folk-rock music")
    end
    
    it "should display the format" do
      xpath = "//span[@id='format'][text()='Music Album, Compact Disc']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the language" do
      xpath = "//span[@id='language'][text()='English']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the publication places" do
      @publiciationPlaces = @doc.xpath("//span[@property='library:placeOfPublication']/text()")
      expect(@publiciationPlaces.count).to eq(3)
      @publiciationPlaces = @publiciationPlaces.map {|publiciationPlace| publiciationPlace.to_s}
      expect(@publiciationPlaces).to include("Merenberg, Germany :")
      expect(@publiciationPlaces).to include("Kingston, N.Y. :")
    end
    
    it "should display the publisher" do
      xpath = "//span[@property='schema:publisher']/span[@property='schema:name'][text()='ZYX-Music GMBH [distributor]']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the date published" do
      xpath = "//span[@property='schema:datePublished'][text()='20uu']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the OCLC Number" do
      xpath = "//span[@property='library:oclcnum'][text()='226390945']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the descriptions" do
      @descriptions = @doc.xpath("//p[@property='schema:description']/text()")
      expect(@descriptions.size).to eq(1)
      @descriptions = @descriptions.map {|description| description.to_s}
      File.open("#{File.expand_path(File.dirname(__FILE__))}/../text/226390945_descriptions.txt").each do |line|
        expect(@descriptions).to include(line.chomp)
      end
    end
    
    it "should have the right music_by" do
      author_name = @doc.xpath("//h2[@id='author-name']/a/text()")
      expect(author_name.to_s.gsub("\n", '').squeeze(' ').strip).to be == "Randy Burns"
    end
    
    it "should have the right by_artists" do
      @by_artists = @doc.xpath("//ul[@id='artists']/li/span/a/text()")
      expect(@by_artists.size).to eq(7)
      @by_artists = @by_artists.map {|by_artist| by_artist.to_s.gsub("\n", '').squeeze(' ').strip}
      expect(@by_artists).to include("Bruce Samuels")
      expect(@by_artists).to include("Randy Burns")
      expect(@by_artists).to include("Bob Sheehan")
      expect(@by_artists).to include("Matt Kastner")
      expect(@by_artists).to include("John O'Leary")
      expect(@by_artists).to include("Bergert Roberts")
      expect(@by_artists).to include("Andy 'Dog' Merwin")

    end
    
  end
  
  context "when displaying a music album (38027615)" do
    before(:all) do
      stub_request(:get, "https://beta.worldcat.org/discovery/offer/oclc/38027615?heldBy=OCPSB").
        to_return(:status => 200, :body => mock_file_contents("offer_set_38027615.rdf"))
      get '/catalog/38027615'
      @doc = Nokogiri::HTML(last_response.body)
    end

    it "should have the right alternate name" do
      xpath = "//p[@property='schema:alternateName'][text()='Angels on high']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end

    it "should have the right parts" do
      @parts = @doc.xpath("//ul[@id='parts']/li/span/a/text()")
      expect(@parts.size).to eq(5)
      @parts = @parts.map {|part| part.to_s.gsub("\n", '').squeeze(' ').strip}

      expect(@parts).to include("First Nowell.")
      expect(@parts).to include("Carol of the birds.")
      expect(@parts).to include("Veni Emmanuel.")
      expect(@parts).to include("What is this lovely fragrance?")
      expect(@parts).to include("Als ich bei meinen Schafen wacht.")
    end
    
    it "should have the right see_alsos" do
      @see_alsos = @doc.xpath("//ul[@id='see_alsos']/li/span/a/text()")
      expect(@see_alsos.size).to eq(11)
      @see_alsos = @see_alsos.map {|see_also| see_also.to_s.gsub("\n", '').squeeze(' ').strip}
      
      expect(@see_alsos).to include("Musae Sioniae,")
      expect(@see_alsos).to include("Hymn to the Virgin.")
      expect(@see_alsos).to include("Musique.")
      expect(@see_alsos).to include("Weihnachts-Oratorium.")
      expect(@see_alsos).to include("Alleluia.")
      expect(@see_alsos).to include("Carol-anthems.")
      expect(@see_alsos).to include("Ave Maria.")
      expect(@see_alsos).to include("O magnum mysterium.")
      expect(@see_alsos).to include("Adeste fideles.")
      expect(@see_alsos).to include("Svete tikhiĭ.")
      expect(@see_alsos).to include("Ceremony of carols.")
    end             
  end

  context "when displaying a music album (609569619)" do
    before(:all) do
      stub_request(:get, "https://beta.worldcat.org/discovery/offer/oclc/609569619?heldBy=OCPSB").
        to_return(:status => 200, :body => mock_file_contents("offer_set_609569619.rdf"))
      get '/catalog/609569619'
      @doc = Nokogiri::HTML(last_response.body)
    end
    
    it "should have the right performers" do
      @performers = @doc.xpath("//ul[@id='performers']/li/span/a/text()")
      expect(@performers.size).to eq(2)
      
      @performers = @performers.map {|performer| performer.to_s.gsub("\n", '').squeeze(' ').strip}
      expect(@performers).to include("Grace Potter, 1983-")
      expect(@performers).to include("Nocturnals (Musical group)")
      'Potter, Grace, 1983-'
    end
  end
end
