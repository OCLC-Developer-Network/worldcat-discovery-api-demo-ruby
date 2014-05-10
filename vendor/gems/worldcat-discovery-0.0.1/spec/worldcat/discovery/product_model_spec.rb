require_relative '../../spec_helper'

describe WorldCat::Discovery::ProductModel do
  context "when loading an author as a Person resource from RDF data" do
    before(:all) do
      rdf = body_content("30780581.rdf")
      Spira.repository = RDF::Repository.new.from_rdfxml(rdf)
      
      philosophy = RDF::URI.new('http://www.worldcat.org/isbn/9780631193623')
      @product_model = philosophy.as(WorldCat::Discovery::ProductModel)
    end
    
    it "should produce have the right class" do 
      @product_model.class.should == WorldCat::Discovery::ProductModel
    end
        
    it "should have the right id" do
      @product_model.id.should == 'http://www.worldcat.org/isbn/9780631193623'
    end
    
    it "should have the right type" do
      @product_model.type.should == 'http://schema.org/ProductModel'
    end
    
    it "should have the right ISBN" do
      @product_model.isbn.should == '9780631193623'
    end
  end
end