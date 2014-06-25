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

describe WorldCat::Discovery::GenericResource do
  context "when loading a resource from RDF data" do
    before(:all) do
      rdf = body_content("30780581.rdf")
      Spira.repository = RDF::Repository.new.from_rdfxml(rdf)
      
      gr_uri  = RDF::URI.new('http://www.w3.org/2006/gen/ont#ContentTypeGenericResource')
      generic_resource = Spira.repository.query(:predicate => RDF.type, :object => gr_uri).first
      @resource = generic_resource.subject.as(WorldCat::Discovery::GenericResource)
    end
    
    it "should produce have the right class" do 
      @resource.class.should == WorldCat::Discovery::GenericResource
    end
    
    it "should reference the Bib with the right subject URI" do
      @resource.about.subject.should == 'http://www.worldcat.org/oclc/30780581'
    end
  end
end