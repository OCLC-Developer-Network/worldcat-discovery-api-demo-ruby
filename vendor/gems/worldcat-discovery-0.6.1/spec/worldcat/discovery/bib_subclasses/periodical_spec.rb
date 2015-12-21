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

describe WorldCat::Discovery::Periodical do
  
  context "when loading bibliographic data for a movie" do
    before(:all) do
      wskey = OCLC::Auth::WSKey.new('api-key', 'api-key-secret', :services => ['WorldCatDiscoveryAPI'])
      WorldCat::Discovery.configure(wskey, 128807, 128807)
      url = 'https://authn.sd00.worldcat.org/oauth2/accessToken?authenticatingInstitutionId=128807&contextInstitutionId=128807&grant_type=client_credentials&scope=WorldCatDiscoveryAPI'
      stub_request(:post, url).to_return(:body => body_content("token.json"), :status => 200)
    end

    context "from a single resource from the RDF data for Journal of academic librarianship" do
      before(:all) do
        url = 'https://beta.worldcat.org/discovery/bib/data/2243594'
        stub_request(:get, url).to_return(:body => body_content("2243594.rdf"), :status => 200)
        @bib = WorldCat::Discovery::Bib.find(2243594)
      end

      it "should have the right id" do
        @bib.id.should == "http://www.worldcat.org/oclc/2243594"
      end
      
      it "should produce have the right class" do 
        @bib.class.should == WorldCat::Discovery::Periodical
      end

      it "should have the right name" do
        @bib.name.should == "Journal of academic librarianship."
      end

      it "should have the right OCLC number" do
        @bib.oclc_number.should == 2243594
      end

      it "should have the right work URI" do
        @bib.work_uri.should == RDF::URI.new('http://worldcat.org/entity/work/id/54524951')
      end

      it "should have the right types" do
        types = @bib.types
        types.size.should == 2
                
        types.should include(RDF::URI('http://schema.org/Periodical'))
        types.should include(RDF::URI('http://schema.org/CreativeWork'))
      end

      it "should have the right language" do
        @bib.language.should == "en"
      end
      
      it "should have the right publisher" do
        @bib.publisher.class.should == WorldCat::Discovery::Organization
        @bib.publisher.name.should == "Elsevier Inc., etc."
      end

      it "should have the right subjects" do
        subjects = @bib.subjects
        subjects.each {|subject| subject.class.should == WorldCat::Discovery::Subject}

        subject_ids = subjects.map {|subject| subject.id}
        subject_ids.should include(RDF::URI('http://experiment.worldcat.org/entity/work/data/54524951#Topic/academic_libraries'))
        subject_ids.should include(RDF::URI('http://dewey.info/class/020.5/'))
        subject_ids.should include(RDF::URI('http://experiment.worldcat.org/entity/work/data/54524951#Topic/library_science'))
        subject_ids.should include(RDF::URI('http://experiment.worldcat.org/entity/work/data/54524951#Topic/information_science'))
        subject_ids.should include(RDF::URI('http://id.worldcat.org/fast/997916'))
        subject_ids.should include(RDF::URI('http://id.worldcat.org/fast/794997'))
        subject_ids.should include(RDF::URI('http://experiment.worldcat.org/entity/work/data/54524951#Topic/libraries'))
        subject_ids.should include(RDF::URI('http://id.loc.gov/authorities/classification/Z671'))

        subject_names = subjects.map {|subject| subject.name}
        subject_names.should include("Academic libraries")
        subject_names.should include("Library science")
        subject_names.should include("Information Science")
        subject_names.should include("Libraries")
      end

      it "should have the right similar to" do
        @bib.similar_to.id.should == "http://www.worldcat.org/oclc/45835833"
        @bib.similar_to.name.should == "Journal of academic librarianship (Online)"
        @bib.similar_to.descriptions.should == ["Online version:"]
        
      end
      
      it "should have the right work examples" do
        work_examples = @bib.work_examples
        work_examples.each {|product_model| product_model.class.should == WorldCat::Discovery::ProductModel}

        work_example_uris = work_examples.map {|product_model| product_model.id}
        work_example_uris.should include(RDF::URI('http://worldcat.org/issn/0099-1333'))
      end
      
      it "should have the right issn" do
        @bib.issn.should == "0099-1333"
      end

      it "should have the right places of publication" do
        places_of_publication = @bib.places_of_publication
        places_of_publication.size.should == 2

        new_york = places_of_publication.reduce(nil) do |p, place|
          if place.id == RDF::URI('http://experiment.worldcat.org/entity/work/data/54524951#Place/new_york_etc')
            p = place 
          end
          p
        end
        new_york.class.should == WorldCat::Discovery::Place
        new_york.type.should == 'http://schema.org/Place'
        new_york.name.should == 'New York, etc.'

        nyu = places_of_publication.reduce(nil) {|p, place| p = place if place.id == RDF::URI('http://id.loc.gov/vocabulary/countries/nyu'); p}
        nyu.class.should == WorldCat::Discovery::Place
        nyu.type.should == 'http://schema.org/Place'      
      end
      
      it "should have the right url" do
        @bib.url.should == "http://www.sciencedirect.com/science/journal/00991333"
      end

    end
  end
end