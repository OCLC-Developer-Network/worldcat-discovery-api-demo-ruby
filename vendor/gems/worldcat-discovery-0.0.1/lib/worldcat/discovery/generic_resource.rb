module WorldCat
  module Discovery
    class GenericResource < Spira::Base
      
      property :about, :predicate => SCHEMA_ABOUT, :type => 'Bib'
      
    end
  end
end