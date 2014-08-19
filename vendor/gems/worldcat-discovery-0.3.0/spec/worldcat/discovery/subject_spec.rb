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

describe WorldCat::Discovery::Subject do
  context "when loading an author as a Person resource from RDF data" do
    before(:all) do
      rdf = body_content("30780581.rdf")
      Spira.repository = RDF::Repository.new.from_rdfxml(rdf)
      
      philosophy = RDF::URI.new('http://id.worldcat.org/fast/1060777')
      @subject = philosophy.as(WorldCat::Discovery::Subject)
    end
    
    it "should produce have the right class" do 
      @subject.class.should == WorldCat::Discovery::Subject
    end
    
    it "should have the right name" do
      @subject.name.should == 'Philosophy'
    end
    
    it "should have the right id" do
      @subject.id.should == 'http://id.worldcat.org/fast/1060777'
    end
    
    it "should have the right type" do
      @subject.type.should == 'http://schema.org/Intangible'
    end
  end
end