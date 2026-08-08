{-# LANGUAGE OverloadedStrings #-}

module BaalatOb.Wikidata.Types
    ( SparqlValue(..)
    , WikidataBinding(..)
    , WikidataResults(..)
    , WikidataResponse(..)
    ) where

import Data.Aeson
    ( FromJSON(..)
    , withObject
    , (.:)
    )

import Data.Text (Text)


-- Represents a single value returned by the SPARQL endpoint.
data SparqlValue = SparqlValue
    { value :: Text
    }
    deriving (Eq, Show)

instance FromJSON SparqlValue where
    parseJSON =
        withObject "SparqlValue" $ \object ->
            SparqlValue
                <$> object .: "value"


-- Represents one row in the SPARQL result set.
data WikidataBinding = WikidataBinding
    { person      :: SparqlValue
    , personLabel :: SparqlValue
    , dateOfDeath :: SparqlValue
    , xUsername   :: SparqlValue
    }
    deriving (Eq, Show)

instance FromJSON WikidataBinding where
    parseJSON =
        withObject "WikidataBinding" $ \object ->
            WikidataBinding
                <$> object .: "person"
                <*> object .: "personLabel"
                <*> object .: "dateOfDeath"
                <*> object .: "xUsername"


-- Represents the "results" object in a SPARQL response.
data WikidataResults = WikidataResults
    { bindings :: [WikidataBinding]
    }
    deriving (Eq, Show)

instance FromJSON WikidataResults where
    parseJSON =
        withObject "WikidataResults" $ \object ->
            WikidataResults
                <$> object .: "bindings"


-- Represents the complete SPARQL response.
data WikidataResponse = WikidataResponse
    { results :: WikidataResults
    }
    deriving (Eq, Show)

instance FromJSON WikidataResponse where
    parseJSON =
        withObject "WikidataResponse" $ \object ->
            WikidataResponse
                <$> object .: "results"
