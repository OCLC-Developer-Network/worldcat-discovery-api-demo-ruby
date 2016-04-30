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

describe WorldCat::Discovery::Configuration do
  context "when constructing the Configuration as a singleton" do
    it "should create raise an error when using the new() constructor" do
      lambda { config = WorldCat::Discovery::Configuration.new }.should raise_error(NoMethodError)
    end
    
    it "should return the same instance for each time it is called" do
      first = WorldCat::Discovery::Configuration.instance()
      second = WorldCat::Discovery::Configuration.instance()
      second.should == first
    end
    
    it "multiple instances should always return the same key" do 
      first_key = OCLC::Auth::WSKey.new('api-key', 'api-key-secret')
      second_key = OCLC::Auth::WSKey.new('api-key', 'api-key-secret')
      second_key.should_not equal first_key
      
      first = WorldCat::Discovery::Configuration.instance
      first.api_key = first_key
      second = WorldCat::Discovery::Configuration.instance
      second.api_key = second_key
      
      first.api_key.should equal second_key
    end
  end
end