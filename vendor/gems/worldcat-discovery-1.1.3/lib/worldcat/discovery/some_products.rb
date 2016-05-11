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

module WorldCat
  module Discovery
    
    # == Properties mapped from RDF data
    #
    # RDF properties are mapped via an ORM style mapping.
    # 
    class SomeProducts < Spira::Base
      
      property :type, :predicate => RDF.type, :type => RDF::URI
      property :collection, :predicate => SCHEMA_IS_PART_OF, :type => 'Collection'
      
      # call-seq:
      #   id() => RDF::URI
      # 
      # Will return the RDF::URI object that serves as the RDF subject of the current ProductModel
      def id
        self.subject
      end
      
      # call-seq:
      #   bib() => WorldCat::Discovery::Bib
      # 
      # Will return a subclass of Bib
      def bib
        generic_resource = Spira.repository.query(:predicate => RDF.type, :object => GENERIC_RESOURCE).first
        bib = generic_resource.subject.as(GenericResource).about
        case
        when bib.types.include?(RDF::URI(SCHEMA_ARTICLE))
          bib.subject.as(Article)  
        when bib.types.include?(RDF::URI(SCHEMA_MUSIC_ALBUM))
          bib.subject.as(MusicAlbum)
        when bib.types.include?(RDF::URI(SCHEMA_MOVIE))
          bib.subject.as(Movie)
        when bib.types.include?(RDF::URI(SCHEMA_PERIODICAL))
          bib.subject.as(Periodical)  
        else
          bib
        end
      end
      
    end
  end
end