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

describe WorldCat::Discovery::Movie do
  
  context "when loading bibliographic data for a movie" do
    before(:all) do
      wskey = OCLC::Auth::WSKey.new('api-key', 'api-key-secret', :services => ['WorldCatDiscoveryAPI'])
      WorldCat::Discovery.configure(wskey, 128807, 128807)
      url = 'https://authn.sd00.worldcat.org/oauth2/accessToken?authenticatingInstitutionId=128807&contextInstitutionId=128807&grant_type=client_credentials&scope=WorldCatDiscoveryAPI'
      stub_request(:post, url).to_return(:body => body_content("token.json"), :status => 200)
    end

    context "from a single resource from the RDF data for Pride and Prejudice" do
      before(:all) do
        url = 'https://beta.worldcat.org/discovery/bib/data/62774704'
        stub_request(:get, url).to_return(:body => body_content("62774704.rdf"), :status => 200)
        @bib = WorldCat::Discovery::Bib.find(62774704)
      end

      it "should have the right id" do
        @bib.id.should == "http://www.worldcat.org/oclc/62774704"
      end
      
      it "should produce have the right class" do 
        @bib.class.should == WorldCat::Discovery::Movie
      end

      it "should have the right name" do
        @bib.name.should == "Pride & prejudice"
      end

      it "should have the right OCLC number" do
        @bib.oclc_number.should == 62774704
      end

      it "should have the right work URI" do
        @bib.work_uri.should == RDF::URI.new('http://worldcat.org/entity/work/id/1075641079')
      end

      #need to update this so that the test checks all the types
      it "should have the right types" do
        types = @bib.types
        types.size.should == 3
                
        types.should include(RDF::URI('http://schema.org/Movie'))
        types.should include(RDF::URI('http://schema.org/CreativeWork'))
        types.should include(RDF::URI('http://bibliograph.net/DVD'))
      end

      it "should have the right language" do
        @bib.language.should == "en"
      end
      
      it "should have the right author" do
        @bib.author.class.should == WorldCat::Discovery::Person
        @bib.author.name.should == "Deborah Moggach"
      end

      it "should have the right publisher" do
        @bib.publisher.class.should == WorldCat::Discovery::Organization
        @bib.publisher.name.should == "Universal Studios Home Entertainment"
      end

      it "should have the right contributors" do
        @bib.contributors.size.should == 21
        contributor = @bib.contributors.first
        contributor.class.should == WorldCat::Discovery::Person
        contributor.name.should == "Talulah Riley"
      end
      
      it "should have the right actors" do
        @bib.actors.size.should == 8
        actor = @bib.actors.first
        actor.class.should == WorldCat::Discovery::Person
        actor.name.should == "Tom Hollander"
      end
      
      it "should have the right director" do
        @bib.director.class.should == WorldCat::Discovery::Person
        @bib.director.name.should == "Joe Wright"
      end
      
      it "should have the right producers" do
        @bib.producers.size.should == 3
        producer = @bib.producers.first
        producer.class.should == WorldCat::Discovery::Person
        producer.name.should == "Paul Webster"
      end  

      it "should have the right subjects" do
        subjects = @bib.subjects
        subjects.each {|subject| subject.class.should == WorldCat::Discovery::Subject}

        subject_ids = subjects.map {|subject| subject.id}
        subject_ids.should include(RDF::URI('http://id.worldcat.org/fast/1183301'))
        subject_ids.should include(RDF::URI('http://experiment.worldcat.org/entity/work/data/1075641079#Topic/hermanas_inglaterra'))
        subject_ids.should include(RDF::URI('http://id.worldcat.org/fast/1919811'))
        subject_ids.should include(RDF::URI('http://id.worldcat.org/fast/881873'))  
        subject_ids.should include(RDF::URI('http://experiment.worldcat.org/entity/work/data/1075641079#Topic/young_women_england_19th_century'))
        subject_ids.should include(RDF::URI('http://viaf.org/viaf/102333412'))
        subject_ids.should include(RDF::URI('http://viaf.org/viaf/315998608'))
        subject_ids.should include(RDF::URI('http://dewey.info/class/791.4372/e22/'))
        subject_ids.should include(RDF::URI('http://id.worldcat.org/fast/1007080'))
        subject_ids.should include(RDF::URI('http://viaf.org/viaf/315998635'))
        subject_ids.should include(RDF::URI('http://experiment.worldcat.org/entity/work/data/1075641079#Person/austen_jane_1775_1817'))
        subject_ids.should include(RDF::URI('http://experiment.worldcat.org/entity/work/data/1075641079#Topic/women_england_social_conditions_19th_century'))
        subject_ids.should include(RDF::URI('http://experiment.worldcat.org/entity/work/data/1075641079#Place/england'))
        subject_ids.should include(RDF::URI('http://experiment.worldcat.org/entity/work/data/1075641079#Topic/courtship_england_19th_century'))
        subject_ids.should include(RDF::URI('http://experiment.worldcat.org/entity/work/data/1075641079#Topic/matrimonio_costumbres_y_ritos'))
        subject_ids.should include(RDF::URI('http://id.worldcat.org/fast/1122346'))
        subject_ids.should include(RDF::URI('http://id.worldcat.org/fast/1176947'))
        subject_ids.should include(RDF::URI('http://id.worldcat.org/fast/1119758'))
        subject_ids.should include(RDF::URI('http://id.worldcat.org/fast/1007815'))
        subject_ids.should include(RDF::URI('http://experiment.worldcat.org/entity/work/data/1075641079#Topic/social_classes_england_19th_century'))
        subject_ids.should include(RDF::URI('http://id.worldcat.org/fast/1219920'))

        subject_names = subjects.map {|subject| subject.name}
        subject_names.should include("Young women")
        subject_names.should include("Hermanas--Inglaterra")
        subject_names.should include("Social conditions")
        subject_names.should include("Courtship")
        subject_names.should include("Young women--England--19th century")
        subject_names.should include("Jane Austen")
        subject_names.should include("(Fictitious character) Fitzwilliam Darcy")
        subject_names.should include("Man-woman relationships")
        subject_names.should include("(Fictitious character) Elizabeth Bennet")
        subject_names.should include("Women--England--Social conditions--19th century")
        subject_names.should include("England")
        subject_names.should include("Courtship--England--19th century")
        subject_names.should include("Matrimonio--Costumbres y ritos")
        subject_names.should include("Social classes")
        subject_names.should include("Women--Social conditions")
        subject_names.should include("Sisters")
        subject_names.should include("Manners and customs")
        subject_names.should include("Social classes--England--19th century")
      end

      it "should have the right work examples" do
        work_examples = @bib.work_examples
        work_examples.each {|product_model| product_model.class.should == WorldCat::Discovery::ProductModel}

        work_example_uris = work_examples.map {|product_model| product_model.id}
        work_example_uris.should include(RDF::URI('http://worldcat.org/isbn/9781417055067'))
      end

      it "should have the right places of publication" do
        places_of_publication = @bib.places_of_publication
        places_of_publication.size.should == 2

        california = places_of_publication.reduce(nil) do |p, place|
          if place.id == RDF::URI('http://experiment.worldcat.org/entity/work/data/1075641079#Place/universal_city_ca')
            p = place 
          end
          p
        end
        california.class.should == WorldCat::Discovery::Place
        california.type.should == 'http://schema.org/Place'
        california.name.should == 'Universal City, CA'

        ca = places_of_publication.reduce(nil) {|p, place| p = place if place.id == RDF::URI('http://id.loc.gov/vocabulary/countries/cau'); p}
        ca.class.should == WorldCat::Discovery::Place
        ca.type.should == 'http://schema.org/Place'      
      end

      it "should have the right descriptions" do
        descriptions = @bib.descriptions
        descriptions.size.should == 2

        File.open("#{File.expand_path(File.dirname(__FILE__))}/../../../support/text/62774704_descriptions.txt").each do |line|
          descriptions.should include(line.chomp)
        end
      end

      it "should have the right isbns" do
        @bib.isbns.sort.should == ['1417055065','9781417055067']
      end
    end
  end
end