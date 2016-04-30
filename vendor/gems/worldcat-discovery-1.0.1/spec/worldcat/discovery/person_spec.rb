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

describe WorldCat::Discovery::Person do
  context "when loading an author as a Person resource from RDF data" do
    before(:all) do
      rdf = body_content("30780581.rdf")
      Spira.repository = RDF::Repository.new.from_rdfxml(rdf)
      
      gr_uri  = RDF::URI.new('http://www.w3.org/2006/gen/ont#ContentTypeGenericResource')
      generic_resource = Spira.repository.query(:predicate => RDF.type, :object => gr_uri).first
      resource = generic_resource.subject.as(WorldCat::Discovery::GenericResource)
      @person = resource.about.author.subject.as(WorldCat::Discovery::Person)
    end
    
    it "should produce have the right class" do 
      @person.class.should == WorldCat::Discovery::Person
    end
    
    it "should have the right name" do
      @person.name.should == 'Wittgenstein, Ludwig, 1889-1951.'
    end
    
    it "should have the right id" do
      @person.id.should == 'http://viaf.org/viaf/24609378'
    end
    
    it "should have the right type" do
      @person.type.should == 'http://schema.org/Person'
    end
    
    it "should have the right given name" do
      @person.given_name.should == 'Ludwig'
    end
    
    it "should have the right family name" do
      @person.family_name.should == 'Wittgenstein'
    end
    
    it "should have the right birth date" do
      @person.birth_date.should == '1889'
    end
    
    it "should have the right death date" do
      @person.death_date.should == '1951'
    end
  end
end