{-# LANGUAGE OverloadedStrings #-}

module BaalatOb.Wikidata
    ( fetchDeathAnniversariesRaw
    , fetchDeathAnniversaries
    , bindingToPerson
    ) where

import Data.ByteString.Lazy (ByteString)

import Network.HTTP.Simple
    ( getResponseBody
    , httpLBS
    , parseRequest
    , setRequestHeader
    , setRequestQueryString
    )

import qualified Data.ByteString.Char8 as BS


import BaalatOb.Person (Person(..))

import qualified BaalatOb.Wikidata.Types as WD

import Data.Text (unpack)

import Data.Time
    ( Day
    , defaultTimeLocale
    , fromGregorian
    , parseTimeM
    , toGregorian
    )

import Data.Aeson (eitherDecode)
import Data.Maybe (mapMaybe)
import qualified Data.ByteString.Lazy.Char8 as LBS

fetchDeathAnniversariesRaw :: Day -> IO ByteString
fetchDeathAnniversariesRaw today = do
    requestWithoutQuery <-
        parseRequest "GET https://query.wikidata.org/sparql"

    let dates =
            anniversaryDates today 20

    let query =
         BS.pack $
              unlines
                  [ "SELECT ?person ?personLabel ?dateOfDeath ?xUsername"
                  , "WHERE {"
                  , buildDateValues dates
                  , ""
                  , "  ?person wdt:P31 wd:Q5;"
                  , "          wdt:P570 ?dateOfDeath;"
                  , "          wdt:P2002 ?xUsername."
                  , ""
                  , "  SERVICE wikibase:label {"
                  , "    bd:serviceParam wikibase:language \"en,de\"."
                  , "  }"
                  , "}"
                  , "LIMIT 50"
                  ]

        request =
            setRequestHeader
                "User-Agent"
                ["baalat-ob/0.1 (learning project)"]
            $ setRequestHeader
                "Accept"
                ["application/sparql-results+json"]
            $ setRequestQueryString
                [("query", Just query)]
                requestWithoutQuery

    response <- httpLBS request

    pure (getResponseBody response)

anniversaryDates :: Day -> Int -> [Day]
anniversaryDates today years =
    let (currentYear, month, day) = toGregorian today
    in
        [ fromGregorian (currentYear - fromIntegral offset) month day
        | offset <- [1 .. years]
        ]

formatDateForSparql :: Day -> String
formatDateForSparql day =
    "\"" ++ show day ++ "T00:00:00Z\"^^xsd:dateTime"

buildDateValues :: [Day] -> String
buildDateValues dates =
    unlines
        [ "VALUES ?dateOfDeath {"
        , unlines (map ("  " ++) (map formatDateForSparql dates))
        , "}"
        ]

bindingToPerson :: WD.WikidataBinding -> Maybe Person
bindingToPerson binding = do
    deathDay <-
        parseTimeM
            True
            defaultTimeLocale
            "%Y-%m-%dT%H:%M:%SZ"
            (unpack (WD.value (WD.dateOfDeath binding)))

    pure
        Person
            { name = unpack (WD.value (WD.personLabel binding))
            , dateOfDeath = deathDay
            , xUsername = unpack (WD.value (WD.xUsername binding))
            }

fetchDeathAnniversaries :: Day -> IO [Person]
fetchDeathAnniversaries today = do
    body <- fetchDeathAnniversariesRaw today

    case eitherDecode body of
        Left err -> do
            putStrLn "Could not decode Wikidata response."
            putStrLn "Raw response:"
            LBS.putStrLn body
            fail ("JSON decoding failed: " ++ err)

        Right response ->
            pure $
                mapMaybe
                    bindingToPerson
                    (WD.bindings (WD.results response))
