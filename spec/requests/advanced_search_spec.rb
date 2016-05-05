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
    get '/advanced_search'
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
    submit_location = @form_element.attr('action')
    uri = URI.parse(submit_location)
    expect(uri.path).to eq('/catalog')
  end
  
  it "should have a match dropdown box" do
    drop_down = @form_element.xpath("//select[@name='operator]")
    expect(dropdown).not_to be_empty
    
    drop_down_values = @form_element.xpath("//select[@name='operator]/option/text()")
    expect(drop_down_values.count).to eq(2)
    expect(drop_down_values).to include("All")
    expect(drop_down_values).to include("Any")     
  end
  
  it "should have a keyword input box" do
    keyword = @form_element.xpath("//input[@name='kw']")
    expect(keyword).not_to be_empty    
  end

  it "should have a name/title input box" do
    title = @form_element.xpath("//input[@name='name']")
    expect(title).not_to be_empty    
  end  

  it "should have an author input box" do
    author = @form_element.xpath("//input[@name='creator']")
    expect(author).not_to be_empty    
  end  
    
  it "should have a subject input box" do
    subject = @form_element.xpath("//input[@name='about']")
    expect(subject).not_to be_empty    
  end
  
  it "should have scope radio buttons" do
    scope_values = @form_element.xpath("//input[@name='scope']/@value")
    expect(scope_values).not_to be_empty
    expect(scope_values).to include("my_library")
    expect(scope_values).to include("worldcat")  
  end
  
  
  it "should have a form with the right databases" do
    databases = @doc.xpath("//p[@id='databases'/label/text()")
    expect(databases).to include("African American Experience")
    expect(databases).to include("American Economic Association Journals")
    expect(databases).to include("OAIster")
    expect(databases).to include("Wiley Online Library")
    expect(databases).to include("WorldCat")
    expect(databases).to include("WorldCat.org") 
  end
  
end
