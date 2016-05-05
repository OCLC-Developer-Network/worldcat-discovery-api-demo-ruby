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
    get '/'
    @doc = Nokogiri::HTML(last_response.body)
  end
  
  it "should display the library name" do
    xpath = "//h1[text()='OCLC Sandbox Library']"
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
  
  it "should have scope radio buttons" do
    scope_values = @doc.xpath("//input[@name='scope']/@value")
    expect(scope_values).not_to be_empty
    scope_values = scope_values.map {|scope_value| scope_value.value}
    expect(scope_values).to include("my_library")
    expect(scope_values).to include("worldcat")  
  end  
  
  it "should display the advanced search form link" do
    xpath = "//span[@id='advanced-search']/a[text()='Advanced Search']"
    expect(@doc.xpath(xpath).size).to eq(1)
  end
  
  it "should display the right link to the advanced search form" do
    advanced_search_link = @doc.xpath("//span[@id='advanced-search']/a/@href")
    uri = URI.parse(advanced_search_link.first.value)
    expect(uri.path).to eq('/advanced')
  end
  
end
