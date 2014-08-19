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
    
    RDF_TYPE               = RDF::URI.new('http://www.w3.org/1999/02/22-rdf-syntax-ns#type')
    GENERIC_RESOURCE       = RDF::URI.new('http://www.w3.org/2006/gen/ont#ContentTypeGenericResource')
    SCHEMA_ABOUT           = RDF::URI.new('http://schema.org/about')
    SCHEMA_AUTHOR          = RDF::URI.new('http://schema.org/author')
    SCHEMA_CONTRIBUTOR     = RDF::URI.new('http://schema.org/contributor')
    SCHEMA_CREATOR         = RDF::URI.new('http://schema.org/creator')
    SCHEMA_NAME            = RDF::URI.new('http://schema.org/name')
    SCHEMA_BOOK            = RDF::URI.new('http://schema.org/Book')
    SCHEMA_PERSON          = RDF::URI.new('http://schema.org/Person')
    SCHEMA_ORGANIZATION    = RDF::URI.new('http://schema.org/Organization')
    SCHEMA_INTANGIBLE      = RDF::URI.new('http://schema.org/Intangible')
    SCHEMA_PRODUCT_MODEL   = RDF::URI.new('http://schema.org/ProductModel')
    SCHEMA_WORK_EXAMPLE    = RDF::URI.new('http://schema.org/workExample')
    SCHEMA_ISBN            = RDF::URI.new('http://schema.org/isbn')
    SCHEMA_EXAMPLE_OF_WORK = RDF::URI.new('http://schema.org/exampleOfWork')
    SCHEMA_NUMBER_OF_PAGES = RDF::URI.new('http://schema.org/numberOfPages')
    SCHEMA_DATE_PUBLISHED  = RDF::URI.new('http://schema.org/datePublished')
    SCHEMA_IN_LANGUAGE     = RDF::URI.new('http://schema.org/inLanguage')
    SCHEMA_PUBLISHER       = RDF::URI.new('http://schema.org/publisher')
    SCHEMA_DESCRIPTION     = RDF::URI.new('http://schema.org/description')
    SCHEMA_REVIEW          = RDF::URI.new('http://schema.org/reviews')
    SCHEMA_REVIEW_BODY     = RDF::URI.new('http://schema.org/reviewBody')
    SCHEMA_SEARCH_RES_PAGE = RDF::URI.new('http://schema.org/SearchResultsPage')
    SCHEMA_BOOK_EDITION    = RDF::URI.new('http://schema.org/bookEdition')
    SCHEMA_ITEM_OFFERED    = RDF::URI.new('http://schema.org/itemOffered')
    SCHEMA_SOME_PRODUCTS   = RDF::URI.new('http://schema.org/SomeProducts')
    SCHEMA_LIBRARY         = RDF::URI.new('http://schema.org/Library')
    SCHEMA_MODEL           = RDF::URI.new('http://schema.org/model')
    SCHEMA_IS_PART_OF      = RDF::URI.new('http://schema.org/isPartOf')
    OWL_SAME_AS            = RDF::URI.new('http://www.w3.org/2002/07/owl#sameAs')
    DCTERMS_HAS_PART       = RDF::URI.new('http://purl.org/dc/terms/hasPart')
    DCTERMS_COLLECTION     = RDF::URI.new('http://purl.org/dc/terms/Collection')
    LIB_OCLC_NUMBER        = RDF::URI.new('http://purl.org/library/oclcnum')
    LIB_OCLC_SYMBOL        = RDF::URI.new('http://purl.org/library/oclcSymbol')
    LIB_MANAGES            = RDF::URI.new('http://purl.org/library/manages')
    WCR_MANAGED_BY         = RDF::URI.new('http://purl.org/oclc/ontology/wcir/managedBy')
    LIB_PLACE_OF_PUB       = RDF::URI.new('http://purl.org/library/placeOfPublication')
    DISCOVERY_TOTAL_RESULTS  = RDF::URI.new('http://worldcat.org/vocab/discovery/totalResults')
    DISCOVERY_ITEMS_PER_PAGE = RDF::URI.new('http://worldcat.org/vocab/discovery/itemsPerPage')
    DISCOVERY_START_INDEX    = RDF::URI.new('http://worldcat.org/vocab/discovery/startIndex')
    DISCOVERY_FACET          = RDF::URI.new('http://worldcat.org/vocab/discovery/facet')
    DISCOVERY_FACET_INDEX    = RDF::URI.new('http://worldcat.org/vocab/discovery/facetIndex')
    DISCOVERY_FACET_COUNT    = RDF::URI.new('http://worldcat.org/vocab/discovery/count')
    DISCOVERY_FACET_VALUE    = RDF::URI.new('http://worldcat.org/vocab/discovery/facetValue')
    DISCOVERY_SEARCH_RESULTS = RDF::URI.new('http://worldcat.org/vocab/discovery/SearchResults')
    GOOD_RELATIONS_POSITION  = RDF::URI.new('http://purl.org/goodrelations/v1#displayPosition')
    
  end
end