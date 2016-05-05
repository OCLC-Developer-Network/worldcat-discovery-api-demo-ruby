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

describe "the home page" do
  before do
    url = 'https://authn.sd00.worldcat.org/oauth2/accessToken?authenticatingInstitutionId=128807&contextInstitutionId=128807&grant_type=client_credentials&scope=WorldCatDiscoveryAPI'
    stub_request(:post, url).to_return(:body => mock_file_contents("token.json"), :status => 200)
    stub_request(:get, "https://beta.worldcat.org/discovery/database/list").
      to_return(:status => 200, :body => mock_file_contents("database_list.rdf"))
    get '/advanced'
    @doc = Nokogiri::HTML(last_response.body)
  end
  
  it "should display the library name" do
    xpath = "//h1[text()='OCLC Sandbox Library']"
    expect(@doc.xpath(xpath)).not_to be_empty
  end
  
  it "should display the form name" do
    xpath = "//h2[text()='Advanced Search']"
    expect(@doc.xpath(xpath)).not_to be_empty    
  end
  
  it "should display the search form" do
    @form_element = @doc.xpath("//form[@id='search-form']")
    expect(@form_element).not_to be_empty
  end
  
  it "should have a form that submits the correct action" do
    submit_location = @doc.xpath("//form[@id='search-form']/@action")
    uri = URI.parse(submit_location.first.value)
    expect(uri.path).to eq('/catalog')
  end
  
  it "should have a match dropdown box" do
    dropdown = @doc.xpath("//select[@name='operator']")
    expect(dropdown).not_to be_empty
    
    drop_down_values = @doc.xpath("//select[@name='operator']/option/text()")
    expect(drop_down_values.count).to eq(2)
    
    drop_down_values = drop_down_values.map {|drop_down_value| drop_down_value.to_s}
    expect(drop_down_values).to include("All")
    expect(drop_down_values).to include("Any")     
  end
  
  it "should have a keyword input box" do
    keyword = @doc.xpath("//input[@name='kw']")
    expect(keyword).not_to be_empty    
  end

  it "should have a name/title input box" do
    title = @doc.xpath("//input[@name='name']")
    expect(title).not_to be_empty    
  end  

  it "should have an author input box" do
    author = @doc.xpath("//input[@name='creator']")
    expect(author).not_to be_empty    
  end  
    
  it "should have a subject input box" do
    subject = @doc.xpath("//input[@name='about']")
    expect(subject).not_to be_empty    
  end
  
  it "should have scope radio buttons" do
    scope_values = @doc.xpath("//input[@name='scope']/@value")
    expect(scope_values).not_to be_empty
    scope_values = scope_values.map {|scope_value| scope_value.value}
    expect(scope_values).to include("my_library")
    expect(scope_values).to include("worldcat")  
  end
  
  
  it "should have a form with the right databases" do
    databases = @doc.xpath("//p[@id='databases']/label/span[@id='database-name']/text()")
    expect(databases.count).to eq(6)
    databases = databases.map {|database| database.to_s.gsub("\n", '').squeeze(' ').strip}
    expect(databases).to include("African American Experience")
    expect(databases).to include("American Economic Association Journals")
    expect(databases).to include("OAIster")
    expect(databases).to include("Wiley Online Library")
    expect(databases).to include("WorldCat")
    expect(databases).to include("WorldCat.org") 
  end
  
end
