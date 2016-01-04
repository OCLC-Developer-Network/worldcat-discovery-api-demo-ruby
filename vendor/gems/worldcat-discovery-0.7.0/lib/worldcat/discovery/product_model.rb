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
    # [isbn] RDF predicate: http://schema.org/isbn; returns: RDF::URI
    # [name] RDF predicate: http://schema.org/name; returns: String
    # [types] RDF predicate: http://www.w3.org/1999/02/22-rdf-syntax-ns#type; returns: Enumerable of RDF::URI objects
    
    class ProductModel < Spira::Base
      
      property :name, :predicate => SCHEMA_NAME, :type => XSD.string
      property :isbn, :predicate => SCHEMA_ISBN, :type => XSD.string
      has_many :types, :predicate => RDF.type, :type => RDF::URI
      has_many :isbns, :predicate => SCHEMA_ISBN, :type => XSD.string 
      
      # call-seq:
      #   id() => RDF::URI
      # 
      # Will return the RDF::URI object that serves as the RDF subject of the current ProductModel
      def id
        self.subject
      end
      
      
      # call-seq:
      #   type() => RDF::URI
      # 
      # Will return the primary type as RDF::URI object as http://schema.org/ProductModel
      def type
        SCHEMA_PRODUCT_MODEL
      end
      
    end
  end
end