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

require_relative '../../spec_helper'

describe WorldCat::Discovery::Series do
  
  context "when loading bibliographic data for a movie" do
    before(:all) do
      wskey = OCLC::Auth::WSKey.new('api-key', 'api-key-secret', :services => ['WorldCatDiscoveryAPI'])
      WorldCat::Discovery.configure(wskey, 128807, 128807)
      url = 'https://authn.sd00.worldcat.org/oauth2/accessToken?authenticatingInstitutionId=128807&contextInstitutionId=128807&grant_type=client_credentials&scope=WorldCatDiscoveryAPI'
      stub_request(:post, url).to_return(:body => body_content("token.json"), :status => 200)
    end

    context "from a single resource from the RDF data for 155131850" do
      before(:all) do
        url = 'https://beta.worldcat.org/discovery/bib/data/155131850'
        stub_request(:get, url).to_return(:body => body_content("155131850.rdf"), :status => 200)
        @bib = WorldCat::Discovery::Bib.find(155131850)
      end

      it "should have the right id" do
        @bib.id.should == "http://www.worldcat.org/oclc/155131850"
      end
      
      it "should produce have the right class" do 
        @bib.class.should == WorldCat::Discovery::Bib
      end

      it "should have the right name" do
        @bib.name.should == "Harry Potter and the Deathly Hallows"
      end

      it "should have the right OCLC number" do
        @bib.oclc_number.should == 155131850
      end

      it "should have the right work URI" do
        @bib.work_uri.should == RDF::URI.new('http://worldcat.org/entity/work/id/66094243')
      end

      it "should have the right types" do
        types = @bib.types
        types.size.should == 2
                
        types.should include(RDF::URI('http://schema.org/Book'))
        types.should include(RDF::URI('http://schema.org/CreativeWork'))
      end

      it "should have the right language" do
        @bib.language.should == "en"
      end
      
      it "should have the right publisher" do
        @bib.publisher.class.should == WorldCat::Discovery::Organization
        @bib.publisher.name.should == "Arthur A. Levine Books"
      end


      it "should have the right similar to" do
        @bib.similar_to.id.should == "http://www.worldcat.org/oclc/681442588"
        @bib.similar_to.name.should == "Harry Potter and the deathly hallows."
        @bib.similar_to.descriptions.should == ["Online version:"]
        
      end
      
      it "should have the right series information" do
        @bib.parts_of.class == WorldCat::Discovery::Series
        @bib.parts_of.count == 3
        @bib.parts_of.first.name == "Harry Potter series ;"
        @bib.parts_of.first.creator.class == WorldCat::Discovery::Person
        @bib.parts_of.first.creator.name == "J. K. Rowling"
        @bib.parts_of.first.parts.count == 1
        
      end

    end
  end
end