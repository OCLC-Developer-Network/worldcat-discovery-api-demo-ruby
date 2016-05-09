# Copyright 2014 OCLC
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

require_relative '../../../spec_helper'

describe WorldCat::Discovery::MusicAlbum do
  
  context "when loading bibliographic data" do
    before(:all) do
      wskey = OCLC::Auth::WSKey.new('api-key', 'api-key-secret', :services => ['WorldCatDiscoveryAPI'])
      WorldCat::Discovery.configure(wskey, 128807, 128807)
      url = 'https://authn.sd00.worldcat.org/oauth2/accessToken?authenticatingInstitutionId=128807&contextInstitutionId=128807&grant_type=client_credentials&scope=WorldCatDiscoveryAPI'
      stub_request(:post, url).to_return(:body => body_content("token.json"), :status => 200)
    end

    context "from a single resource from the RDF data for Song for an uncertain lady" do
      before(:all) do
        url = 'https://beta.worldcat.org/discovery/bib/data/226390945'
        stub_request(:get, url).to_return(:body => body_content("226390945.rdf"), :status => 200)
        @bib = WorldCat::Discovery::Bib.find(226390945)
      end

      it "should have the right id" do
        @bib.id.should == "http://www.worldcat.org/oclc/226390945"
      end

      it "should have the right name" do
        @bib.name.should == "Song for an uncertain lady"
      end
      
      it "should have the right alternate name" do
        @bib.alternate_name.should == "Songs for an uncertain lady"
      end

      it "should have the right OCLC number" do
        @bib.oclc_number.should == 226390945
      end

      it "should have the right work URI" do
        @bib.work_uri.should == RDF::URI.new('http://worldcat.org/entity/work/id/1155934167')
      end

      it "should have the right date published" do
        @bib.date_published.should == "20uu"
      end

      it "should have the right types" do
        @bib.types.should include(RDF::URI.new('http://schema.org/MusicAlbum'))
        @bib.types.should include(RDF::URI.new('http://bibliograph.net/CD'))
      end

      it "should have the right language" do
        @bib.language.should == "en"
      end
      
      it "should have the right composer" do
        @bib.composer.class.should == WorldCat::Discovery::Person
        @bib.composer.name.should == "Randy Burns"        
      end

      it "should have the right publisher" do
        @bib.publisher.class.should == WorldCat::Discovery::Organization
        @bib.publisher.name.should == "ZYX-Music GMBH [distributor]"
      end
      
      it "should have the right publishers" do
        @bib.publishers.size.should == 2
        publishers = @bib.publishers
        
        publishers.each {|publisher| publisher.class.should == WorldCat::Discovery::Organization}
        
        publisher_ids = publishers.map {|publisher| publisher.id}
        publisher_ids.should include(RDF::URI('http://experiment.worldcat.org/entity/work/data/1155934167#Agent/esp_disk'))
        publisher_ids.should include(RDF::URI('http://experiment.worldcat.org/entity/work/data/1155934167#Agent/zyx_music_gmbh_distributor'))

        publisher_names = publishers.map {|publisher| publisher.name}
        publisher_names.should include("ESP Disk")
        publisher_names.should include("ZYX-Music GMBH [distributor]")

      end

      it "should have the right by_artists" do
        @bib.by_artists.size.should == 7
        by_artist = @bib.by_artists.first
        by_artist.class.should == WorldCat::Discovery::Person
        by_artist.name.should == "Bruce Samuels"
      end

      it "should have the right subjects" do
        subjects = @bib.subjects
        subjects.each {|subject| subject.class.should == WorldCat::Discovery::Subject}

        subject_ids = subjects.map {|subject| subject.id}

        subject_ids.should include(RDF::URI('http://id.worldcat.org/fast/930303'))
        subject_ids.should include(RDF::URI('http://id.loc.gov/authorities/subjects/sh87003327'))
        subject_ids.should include(RDF::URI('http://id.worldcat.org/fast/1099204'))
        subject_ids.should include(RDF::URI('http://id.worldcat.org/fast/929383'))
        subject_ids.should include(RDF::URI('http://experiment.worldcat.org/entity/work/data/1155934167#Event/1961_1970'))
        subject_ids.should include(RDF::URI('http://experiment.worldcat.org/entity/work/data/1155934167#Topic/folk_music_1961_1970'))
        subject_ids.should include(RDF::URI('http://experiment.worldcat.org/entity/work/data/1155934167#Topic/folk_rock_music_1961_1970'))

        subject_names = subjects.map {|subject| subject.name}
        subject_names.should include("Folk music--1961-1970")
        subject_names.should include("Rock music")
        subject_names.should include("Folk music")
        subject_names.should include("Rock music--1961-1970")
        subject_names.should include("1961-1970")
        subject_names.should include("Folk-rock music--1961-1970")
        subject_names.should include("Folk-rock music")
      end

      it "should have the right places of publication" do
        places_of_publication = @bib.places_of_publication
        places_of_publication.size.should == 3

        merenberg = places_of_publication.reduce(nil) do |p, place| 
          p = place if place.id == RDF::URI('http://experiment.worldcat.org/entity/work/data/1155934167#Place/merenberg_germany')
          p
        end
        merenberg.class.should == WorldCat::Discovery::Place
        merenberg.type.should == 'http://schema.org/Place'
        merenberg.name.should == 'Merenberg, Germany'

        kingston = places_of_publication.reduce(nil) do |p, place|
          if place.id == RDF::URI('http://experiment.worldcat.org/entity/work/data/1155934167#Place/kingston_n_y')
            p = place 
          end
          p
        end
        kingston.class.should == WorldCat::Discovery::Place
        kingston.type.should == 'http://schema.org/Place'
        kingston.name.should == 'Kingston, N.Y.'

        new_york = places_of_publication.reduce(nil) {|p, place| p = place if place.id == RDF::URI('http://id.loc.gov/vocabulary/countries/nyu'); p}
        new_york.class.should == WorldCat::Discovery::Place
        new_york.type.should == 'http://schema.org/Place'      
      end

      it "should have the right descriptions" do
        descriptions = @bib.descriptions
        descriptions.size.should == 1

        File.open("#{File.expand_path(File.dirname(__FILE__))}/../../../support/text/226390945_descriptions.txt").each do |line|
          descriptions.should include(line.chomp)
        end
      end
      
      it "should have the right format" do
        @bib.format.should include(RDF::URI.new('http://bibliograph.net/CD'))
      end
    end

    context "from a single resource from the RDF data for 38027615" do
      before(:all) do
        url = 'https://beta.worldcat.org/discovery/bib/data/38027615'
        stub_request(:get, url).to_return(:body => body_content("38027615.rdf"), :status => 200)
        @bib = WorldCat::Discovery::Bib.find(38027615)
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
    
    context "from a single resource from the RDF data for 609569619" do
      before(:all) do
        url = 'https://beta.worldcat.org/discovery/bib/data/609569619'
        stub_request(:get, url).to_return(:body => body_content("609569619.rdf"), :status => 200)
        @bib = WorldCat::Discovery::Bib.find(609569619)
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