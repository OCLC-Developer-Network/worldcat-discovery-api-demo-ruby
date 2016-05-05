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
  context "when displaying a music album (226390945)" do
    before(:all) do
      stub_request(:get, "https://beta.worldcat.org/discovery/bib/data/226390945").
        to_return(:status => 200, :body => mock_file_contents("226390945.rdf"))
      get '/record/883876185'
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

    it "should display the artists" do
      @artists = @doc.xpath("//ul[@id='artists']/li/span/a/text()")
      expect(@artists).to include("Rock music")
      expect(@artists).to include("Folk music")
      expect(@artists).to include("Folk-rock music")
    end
    
    it "should display the see_alsos" do
      @see_alsos = @doc.xpath("//ul[@id='see_alsos']/li/span/a/text()")
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
      expect(@subjects).to include("Rock music")
      expect(@subjects).to include("Folk music")
      expect(@subjects).to include("Folk-rock music")
    end
    
    it "should display the format" do
      #this is busted
      xpath = "//span[@id='format'][text()='Music Album, Compact Disc']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the language" do
      #this is busted
      xpath = "//span[@id='language'][text()='English']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the publication places" do
      @publiciationPlaces = @doc.xpath("//span[@property='library:placeOfPublication']/text()")
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
      expect(@descriptions).to eq(2)
      File.open("#{File.expand_path(File.dirname(__FILE__))}/../../support/text/226390945_descriptions.txt").each do |line|
        expect(@descriptions).to include(line.chomp)
      end
    end
    
    it "should have the right music_by" do
      #this is wrong in the template
      xpath = "//h2[@id='author-name']/a[text()='Burns, Randy.']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should have the right by_artists" do
      @by_artists = @doc.xpath("//ul[@id='by_artists']/li/span/a/text()")
      expect(@by_artists.size).to == 7
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
      stub_request(:get, "https://beta.worldcat.org/discovery/bib/data/38027615").
        to_return(:status => 200, :body => mock_file_contents("38027615.rdf"))
      get '/record/883876185'
      @doc = Nokogiri::HTML(last_response.body)
    end

    it "should have the right alternate name" do
      @bib.alternate_name.should == "Angels on high"
    end

    it "should have the right parts" do
      parts = @bib.parts
      parts.each {|part| part.class.should == WorldCat::Discovery::Bib}

      part_ids = parts.map {|part| part.id}
      expect(part_ids).to include(RDF::URI('http://experiment.worldcat.org/entity/work/data/772816333#CreativeWork/first_nowell'))
      expect(part_ids).to include(RDF::URI('http://experiment.worldcat.org/entity/work/data/772816333#CreativeWork/carol_of_the_birds'))
      expect(part_ids).to include(RDF::URI('http://experiment.worldcat.org/entity/work/data/772816333#CreativeWork/veni_emmanuel'))
      expect(part_ids).to include(RDF::URI('http://experiment.worldcat.org/entity/work/data/772816333#CreativeWork/what_is_this_lovely_fragrance'))
      expect(part_ids).to include(RDF::URI('http://experiment.worldcat.org/entity/work/data/772816333#CreativeWork/als_ich_bei_meinen_schafen_wacht'))

      part_names = parts.map {|part| part.name}
      expect(part_names).to include("First Nowell.")
      expect(part_names).to include("Carol of the birds.")
      expect(part_names).to include("Veni Emmanuel.")
      expect(part_names).to include("What is this lovely fragrance?")
      expect(part_names).to include("Als ich bei meinen Schafen wacht.")
    end
    
    it "should have the right see_alsos" do
      see_alsos = @bib.see_alsos
      see_alsos.each {|see_also| see_also.class.should == WorldCat::Discovery::Bib}

      see_also_ids = see_alsos.map {|see_also| see_also.id}
      expect(see_also_ids).to include(RDF::URI('http://experiment.worldcat.org/entity/work/data/772816333#CreativeWork/musae_sioniae'))
      expect(see_also_ids).to include(RDF::URI('http://experiment.worldcat.org/entity/work/data/772816333#CreativeWork/hymn_to_the_virgin'))
      expect(see_also_ids).to include(RDF::URI('http://experiment.worldcat.org/entity/work/data/772816333#CreativeWork/musique'))
      expect(see_also_ids).to include(RDF::URI('http://experiment.worldcat.org/entity/work/data/772816333#CreativeWork/weihnachts_oratorium'))
      expect(see_also_ids).to include(RDF::URI('http://experiment.worldcat.org/entity/work/data/772816333#CreativeWork/alleluia'))
      expect(see_also_ids).to include(RDF::URI('http://experiment.worldcat.org/entity/work/data/772816333#CreativeWork/carol_anthems'))
      expect(see_also_ids).to include(RDF::URI('http://experiment.worldcat.org/entity/work/data/772816333#CreativeWork/ave_maria'))
      expect(see_also_ids).to include(RDF::URI('http://experiment.worldcat.org/entity/work/data/772816333#CreativeWork/o_magnum_mysterium'))
      expect(see_also_ids).to include(RDF::URI('http://experiment.worldcat.org/entity/work/data/772816333#CreativeWork/adeste_fideles'))
      expect(see_also_ids).to include(RDF::URI('http://experiment.worldcat.org/entity/work/data/772816333#CreativeWork/svete_tikhii'))
      expect(see_also_ids).to include(RDF::URI('http://experiment.worldcat.org/entity/work/data/772816333#CreativeWork/ceremony_of_carols'))  

      see_also_names = see_alsos.map {|see_also| see_also.name}
      expect(see_also_names).to include("Musae Sioniae,")
      expect(see_also_names).to include("Hymn to the Virgin.")
      expect(see_also_names).to include("Musique.")
      expect(see_also_names).to include("Weihnachts-Oratorium.")
      expect(see_also_names).to include("Alleluia.")
      expect(see_also_names).to include("Carol-anthems.")
      expect(see_also_names).to include("Ave Maria.")
      expect(see_also_names).to include("O magnum mysterium.")
      expect(see_also_names).to include("Adeste fideles.")
      expect(see_also_names).to include("Svete tikhiĭ.")
      expect(see_also_names).to include("Ceremony of carols.")
    end             
  end

  context "when displaying a music album (609569619)" do
    before(:all) do
      stub_request(:get, "https://beta.worldcat.org/discovery/bib/data/609569619").
        to_return(:status => 200, :body => mock_file_contents("609569619.rdf"))
      get '/record/883876185'
      @doc = Nokogiri::HTML(last_response.body)
    end
    
    it "should have the right performers" do
      performers = @bib.performers
      expect(performers.size).to == 2
      
      grace_potter = performers.reduce(nil) do |p, performer| 
        p = performer if performer.id == RDF::URI('http://viaf.org/viaf/26851551')
        p
      end
      grace_potter.class.should == WorldCat::Discovery::Person
      grace_potter.type.should == 'http://schema.org/Person'
      grace_potter.name.should == 'Potter, Grace, 1983-'

      nocturnals = performers.reduce(nil) do |p, performer|
        p = performer if performer.id == RDF::URI('http://viaf.org/viaf/157486407')
        p
      end
      nocturnals.class.should == WorldCat::Discovery::Organization
      nocturnals.type.should == 'http://schema.org/Organization'
      nocturnals.name.should == 'Nocturnals (Musical group)'
    end
  end
end
