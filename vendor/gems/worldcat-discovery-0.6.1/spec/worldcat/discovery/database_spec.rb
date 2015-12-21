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

describe WorldCat::Discovery::Database do
  
  context "when retrieving my list of databases" do
    before(:all) do
      wskey = OCLC::Auth::WSKey.new('api-key', 'api-key-secret', :services => ['WorldCatDiscoveryAPI'])
      WorldCat::Discovery.configure(wskey, 128807, 128807)
      
      access_token_request_url = "https://authn.sd00.worldcat.org/oauth2/accessToken?" + 
          "authenticatingInstitutionId=128807&contextInstitutionId=128807&" + 
          "grant_type=client_credentials&scope=WorldCatDiscoveryAPI"
      stub_request(:post, access_token_request_url).to_return(:body => body_content("access_token.json"), :status => 200)

      url = 'https://beta.worldcat.org/discovery/database/list'
      stub_request(:get, url).to_return(:body => body_content("database_list_128807.rdf"), :status => 200)
      @list = WorldCat::Discovery::Database.list
    end
    
    it "should return a database list" do
      @list.class.should == WorldCat::Discovery::DatabaseList
    end

    it "should have the right number of databases" do
      @list.databases.size.should == 6
    end
    
    it "should return a list of Database objects" do
      @list.databases.each {|database| database.class.should == WorldCat::Discovery::Database}
    end
    
    it "should return the databases sorted by name" do
      @list.databases[0].name.should == 'African American Experience'
      @list.databases[1].name.should == 'American Economic Association Journals'
      @list.databases[2].name.should == 'OAIster'
      @list.databases[3].name.should == 'Wiley Online Library'
      @list.databases[4].name.should == 'WorldCat'
      @list.databases[5].name.should == 'WorldCat.org'
    end
    
    context "when inspecting the first database" do
      before(:all) do
        @database = @list.databases.first
      end

      it "should have the correct type" do
        @database.type.should == RDF::URI.new('http://purl.org/dc/dcmitype/Dataset')
      end

      it "should have the correct database ID" do
        @database.database_id.should == 1877
      end
      
      it "should have the correct name" do
        @database.name.should == 'African American Experience'
      end
      
      it "should have the correct description" do
        @database.description.should == 'The widest depth and breadth of information available of any ' + 
            'online database collection on African American history and culture.'
      end
      
      it "should have the correct authentication requirement" do
        @database.requires_authentication.should == false
      end
    end
    
    context "when inspecting a database with the requires authentication property" do
      it "should have the correct authentication requirement" do
        @list.databases.last.requires_authentication.should == false
      end
    end
  end
  
end