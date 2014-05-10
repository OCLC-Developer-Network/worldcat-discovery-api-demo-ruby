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
  end
end