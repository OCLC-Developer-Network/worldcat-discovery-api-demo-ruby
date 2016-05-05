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
      @artists.should include("Rock music")
      @artists.should include("Folk music")
      @artists.should include("Folk-rock music")
    end
    
    it "should display the see_alsos" do
      @see_alsos = @doc.xpath("//ul[@id='see_alsos']/li/span/a/text()")
      @see_alsos.should include("Sorrow's children.")
      @see_alsos.should include("Lisa.")
      @see_alsos.should include("Autumn on your mind.")
      @see_alsos.should include("Waiting for an old friend.")
      @see_alsos.should include("Maybelline.")
      @see_alsos.should include("Song for an uncertain lady.")
      @see_alsos.should include("Child for now.")
      @see_alsos.should include("Africa.")
      @see_alsos.should include("One I thought was there.")
      @see_alsos.should include("Only time will make you see.")
      @see_alsos.should include("Let tomorrow be.")
    end
        
    it "should display the subjects" do
      @subjects = @doc.xpath("//ul[@id='subjects']/li/span/a/text()")
      @subjects.should include("Rock music")
      @subjects.should include("Folk music")
      @subjects.should include("Folk-rock music")
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
      @publiciationPlaces.should include("Merenberg, Germany :")
      @publiciationPlaces.should include("Kingston, N.Y. :")
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
        @descriptions.should include(line.chomp)
      end
    end
    
    it "should have the right music_by" do
      #this is wrong in the template
      xpath = "//h2[@id='author-name']/a[text()='Burns, Randy.']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should have the right by_artists" do
      @by_artists = @doc.xpath("//ul[@id='by_artists']/li/span/a/text()")
      @by_artists.size.should == 7
      @by_artists.should include("Bruce Samuels")
      @by_artists.should include("Randy Burns")
      @by_artists.should include("Bob Sheehan")
      @by_artists.should include("Matt Kastner")
      @by_artists.should include("John O'Leary")
      @by_artists.should include("Bergert Roberts")
      @by_artists.should include("Andy 'Dog' Merwin")

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
      part_ids.should include(RDF::URI('http://experiment.worldcat.org/entity/work/data/772816333#CreativeWork/first_nowell'))
      part_ids.should include(RDF::URI('http://experiment.worldcat.org/entity/work/data/772816333#CreativeWork/carol_of_the_birds'))
      part_ids.should include(RDF::URI('http://experiment.worldcat.org/entity/work/data/772816333#CreativeWork/veni_emmanuel'))
      part_ids.should include(RDF::URI('http://experiment.worldcat.org/entity/work/data/772816333#CreativeWork/what_is_this_lovely_fragrance'))
      part_ids.should include(RDF::URI('http://experiment.worldcat.org/entity/work/data/772816333#CreativeWork/als_ich_bei_meinen_schafen_wacht'))

      part_names = parts.map {|part| part.name}
      part_names.should include("First Nowell.")
      part_names.should include("Carol of the birds.")
      part_names.should include("Veni Emmanuel.")
      part_names.should include("What is this lovely fragrance?")
      part_names.should include("Als ich bei meinen Schafen wacht.")
    end
    
    it "should have the right see_alsos" do
      see_alsos = @bib.see_alsos
      see_alsos.each {|see_also| see_also.class.should == WorldCat::Discovery::Bib}

      see_also_ids = see_alsos.map {|see_also| see_also.id}
      see_also_ids.should include(RDF::URI('http://experiment.worldcat.org/entity/work/data/772816333#CreativeWork/musae_sioniae'))
      see_also_ids.should include(RDF::URI('http://experiment.worldcat.org/entity/work/data/772816333#CreativeWork/hymn_to_the_virgin'))
      see_also_ids.should include(RDF::URI('http://experiment.worldcat.org/entity/work/data/772816333#CreativeWork/musique'))
      see_also_ids.should include(RDF::URI('http://experiment.worldcat.org/entity/work/data/772816333#CreativeWork/weihnachts_oratorium'))
      see_also_ids.should include(RDF::URI('http://experiment.worldcat.org/entity/work/data/772816333#CreativeWork/alleluia'))
      see_also_ids.should include(RDF::URI('http://experiment.worldcat.org/entity/work/data/772816333#CreativeWork/carol_anthems'))
      see_also_ids.should include(RDF::URI('http://experiment.worldcat.org/entity/work/data/772816333#CreativeWork/ave_maria'))
      see_also_ids.should include(RDF::URI('http://experiment.worldcat.org/entity/work/data/772816333#CreativeWork/o_magnum_mysterium'))
      see_also_ids.should include(RDF::URI('http://experiment.worldcat.org/entity/work/data/772816333#CreativeWork/adeste_fideles'))
      see_also_ids.should include(RDF::URI('http://experiment.worldcat.org/entity/work/data/772816333#CreativeWork/svete_tikhii'))
      see_also_ids.should include(RDF::URI('http://experiment.worldcat.org/entity/work/data/772816333#CreativeWork/ceremony_of_carols'))  

      see_also_names = see_alsos.map {|see_also| see_also.name}
      see_also_names.should include("Musae Sioniae,")
      see_also_names.should include("Hymn to the Virgin.")
      see_also_names.should include("Musique.")
      see_also_names.should include("Weihnachts-Oratorium.")
      see_also_names.should include("Alleluia.")
      see_also_names.should include("Carol-anthems.")
      see_also_names.should include("Ave Maria.")
      see_also_names.should include("O magnum mysterium.")
      see_also_names.should include("Adeste fideles.")
      see_also_names.should include("Svete tikhiĭ.")
      see_also_names.should include("Ceremony of carols.")
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
      performers.size.should == 2
      
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
end
