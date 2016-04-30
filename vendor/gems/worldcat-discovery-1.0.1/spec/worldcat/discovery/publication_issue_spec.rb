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

describe WorldCat::Discovery::PublicationIssue do
  
  context "when loading bibliographic data" do
    before(:all) do
      wskey = OCLC::Auth::WSKey.new('api-key', 'api-key-secret', :services => ['WorldCatDiscoveryAPI'])
      WorldCat::Discovery.configure(wskey, 128807, 128807)
      url = 'https://authn.sd00.worldcat.org/oauth2/accessToken?authenticatingInstitutionId=128807&contextInstitutionId=128807&grant_type=client_credentials&scope=WorldCatDiscoveryAPI'
      stub_request(:post, url).to_return(:body => body_content("token.json"), :status => 200)
    end

    context "from a single resource from the RDF data for an article with an issue and volume" do
      before(:all) do
        url = 'https://beta.worldcat.org/discovery/bib/data/5131938809'
        stub_request(:get, url).to_return(:body => body_content("5131938809.rdf"), :status => 200)
        @bib = WorldCat::Discovery::Bib.find(5131938809)
        @issue = @bib.issue
      end
      
      it "should have the right issue" do
        @issue.class.should == WorldCat::Discovery::PublicationIssue
      end      
      
      it "should have the right Periodical" do
        @issue.periodical.class.should == WorldCat::Discovery::Periodical
      end
      
    end
  end
  
  context "from a single resource from the RDF data for an article with an issue and no volume" do
    before(:all) do
      #url = 'https://beta.worldcat.org/discovery/bib/data/5131938809'
      #stub_request(:get, url).to_return(:body => body_content("5131938809.rdf"), :status => 200)
      #@bib = WorldCat::Discovery::Bib.find(5131938809)
      #@issue = @bib.issue
    end
    
    it "should have the right issue" do
      #@issue.class.should == WorldCat::Discovery::PublicationIssue
    end      
    
    it "should have the right Periodical" do
      #@issue.periodical.should == WorldCat::Discovery::Periodical
    end
    
  end

  
end