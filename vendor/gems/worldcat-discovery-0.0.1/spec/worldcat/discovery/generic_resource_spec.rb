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