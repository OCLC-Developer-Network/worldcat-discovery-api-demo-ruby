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

describe WorldCat::Discovery::Article do
  
  context "when loading bibliographic data" do
    before(:all) do
      wskey = OCLC::Auth::WSKey.new('api-key', 'api-key-secret', :services => ['WorldCatDiscoveryAPI'])
      WorldCat::Discovery.configure(wskey, 128807, 128807)
      url = 'https://authn.sd00.worldcat.org/oauth2/accessToken?authenticatingInstitutionId=128807&contextInstitutionId=128807&grant_type=client_credentials&scope=WorldCatDiscoveryAPI'
      stub_request(:post, url).to_return(:body => body_content("token.json"), :status => 200)
    end

    context "from a single resource from the RDF data for an article" do
      before(:all) do
        url = 'https://beta.worldcat.org/discovery/bib/data/5131938809'
        stub_request(:get, url).to_return(:body => body_content("5131938809.rdf"), :status => 200)
        @bib = WorldCat::Discovery::Bib.find(5131938809)
      end

      it "should have the right id" do
        @bib.id.should == "http://www.worldcat.org/oclc/5131938809"
      end

      it "should have the right name" do
        @bib.name.should == "How Much Would US Style Fiscal Integration Buffer European Unemployment and Income Shocks? (A Comparative Empirical Analysis)"
      end

      it "should have the right OCLC number" do
        @bib.oclc_number.should == 5131938809
      end

      it "should have the right work URI" do
        @bib.work_uri.should == RDF::URI.new('http://worldcat.org/entity/work/id/1354473038')
      end

      it "should have the right date published" do
        @bib.date_published.should == "2013-05-01"
      end

      it "should have the right type" do
        @bib.type.should == RDF::URI.new('http://schema.org/Article')
      end

      it "should have the right language" do
        @bib.language.should == "en"
      end

      it "should have the right author" do
        @bib.author.class.should == WorldCat::Discovery::Person
        @bib.author.name.should == "Feyrer, James"
      end

      it "should have the right publisher" do
        @bib.publisher.class.should == WorldCat::Discovery::Organization
        @bib.publisher.name.should == "American Economic Association"
      end

      it "should have the right contributors" do
        @bib.contributors.size.should == 1
        contributor = @bib.contributors.first
        contributor.class.should == WorldCat::Discovery::Person
        contributor.name.should == "Sacerdote, Bruce"
      end

      it "should have the right descriptions" do
        descriptions = @bib.descriptions
        descriptions.size.should == 1

        File.open("#{File.expand_path(File.dirname(__FILE__))}/../../../support/text/5131938809_descriptions.txt").each do |line|
          descriptions.should include(line.chomp)
        end
      end
      
      it "should have the right page_start" do
        @bib.page_start.should == 125
      end
      
      it "should have the right page_end" do
        @bib.page_end.should == 128
      end
      
      it "should have the right periodical_name" do
        @bib.periodical_name.should == "American Economic Review"
      end
      
      it "should have the right volume_number" do
        @bib.volume_number.should == 103
      end
      
      it "should have the right issue_number" do
        @bib.issue_number.should == 3
      end
      
      it "should have the right is_part_of" do
        @bib.is_part_of.class.should == WorldCat::Discovery::PublicationIssue
        @bib.is_part_of.issue_number.should == 3
        
        volume = @bib.is_part_of.volume
        volume.class.should == WorldCat::Discovery::PublicationVolume
        volume.volume_number.should == 103
        
        periodical = volume.periodical
        periodical.class.should == WorldCat::Discovery::Periodical
        periodical.id == "http://worldcat.org/issn/0002-8282"
        periodical.name == "American Economic Review" 
      end
      
      it "should have the right same_as" do
        @bib.same_as.should == "http://dx.doi.org/10.1257/aer.103.3.125"
      end

    end
  end
  
  context "when loading bibliographic data for article with no issue/volume (777986070)" do
    before(:all) do
      wskey = OCLC::Auth::WSKey.new('api-key', 'api-key-secret', :services => ['WorldCatDiscoveryAPI'])
      WorldCat::Discovery.configure(wskey, 128807, 128807)
      url = 'https://authn.sd00.worldcat.org/oauth2/accessToken?authenticatingInstitutionId=128807&contextInstitutionId=128807&grant_type=client_credentials&scope=WorldCatDiscoveryAPI'
      stub_request(:post, url).to_return(:body => body_content("token.json"), :status => 200)
    end
    
    context "from a single resource from the RDF data for an article" do
      before(:all) do
        url = 'https://beta.worldcat.org/discovery/bib/data/777986070'
        stub_request(:get, url).to_return(:body => body_content("777986070.rdf"), :status => 200)
        @bib = WorldCat::Discovery::Bib.find(777986070)
      end
    
      it "should have the right id" do
        @bib.id.should == "http://www.worldcat.org/oclc/777986070"
      end
    
      it "should have the right name" do
        @bib.name.should == "MapFAST a FAST geographic authorities mashup with Google Maps"
      end
    
      it "should have the right OCLC number" do
        @bib.oclc_number.should == 777986070
      end
    
      it "should have the right work URI" do
        @bib.work_uri.should == RDF::URI.new('http://worldcat.org/entity/work/id/1081877596')
      end
          
      #it "should have the right date published" do
      #  @bib.date_published.should == "2013-05-01"
      #end
      
      it "should be the right class" do
        @bib.class.should == WorldCat::Discovery::Article
      end
      
      it "should have the right language" do
        @bib.language.should == "en"
      end
      
      it "should have the right author" do
        @bib.author.class.should == WorldCat::Discovery::Person
        @bib.author.name.should == "Rick Bennet"
      end
      
      it "should have the right contributors" do
        @bib.contributors.size.should == 4
        contributor = @bib.contributors.first
        contributor.class.should == WorldCat::Discovery::Person
        contributor.name.should == "OCLC Research."
      end
      
      it "should have the right descriptions" do
        descriptions = @bib.descriptions
        descriptions.size.should == 1
      
        File.open("#{File.expand_path(File.dirname(__FILE__))}/../../../support/text/777986070_descriptions.txt").each do |line|
          descriptions.should include(line.chomp)
        end
      end
      
      it "should have the right pagination" do
        @bib.pagination.should == "issue 14 (July 25, 2011)"
      end
      
      it "should have the right periodical_name" do
        @bib.periodical_name.should == "Code4lib journal"
      end
      
      it "should have the right is_part_of" do
        @bib.is_part_of.class.should == WorldCat::Discovery::Periodical
        @bib.is_part_of.id.should == "http://worldcat.org/issn/1940-5758"
        @bib.is_part_of.issn.should == "1940-5758"
      end
      
      it "should have the right url" do
        @bib.url.should == "http://journal.code4lib.org/articles/5645"
      end
          
      end
    end 
end