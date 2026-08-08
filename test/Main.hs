{-# LANGUAGE OverloadedStrings #-}

module Main where

-- Functions and data types related to people.
--
-- Person(..) means that we import:
--   * the Person type
--   * the Person constructor
--   * its record fields, such as `name` and `dateOfDeath`
import BaalatOb.Person
    ( Person(..)
    , diedWithinYears
    , findMemorialCandidates
    , hasDeathAnniversary
    , isMemorialCandidate
    )

-- Functions and data types related to X posts.
import BaalatOb.Post
    ( Post(..)
    , selectMemorialPosts
    )

-- Types and functions for working with dates and times.
import Data.Time
    ( UTCTime(..)
    , fromGregorian
    , secondsToDiffTime
    )

import BaalatOb.Wikidata.Types
    ( SparqlValue(..)
    )

import Data.Aeson (decode)
import qualified Data.ByteString.Lazy.Char8 as LBS

-- We use `unless` to implement our small assertion helper.
import Control.Monad (unless)

import qualified BaalatOb.Wikidata.Types as WD

import BaalatOb.Wikidata
    ( bindingToPerson
    )

-- The entry point of our test suite.
--
-- Cabal executes this function when we run:
--
--     cabal test
--
main :: IO ()
main = do

    ------------------------------------------------------------------
    -- Test data: people
    ------------------------------------------------------------------

    -- David Bowie is used for a simple death-anniversary test.
    let davidBowie =
          Person
              { name = "David Bowie"
              , dateOfDeath = fromGregorian 2016 1 10
              , xUsername = "DavidBowieReal"
              }

    -- A fixed "current" date for our tests.
    --
    -- We deliberately do NOT use the real system date here.
    -- Tests should be deterministic: running them tomorrow should
    -- produce exactly the same result as running them today.
    let today =
            fromGregorian 2026 8 8

    -- Someone who died exactly 19 years before our test date.
    let died19YearsAgo =
            Person
                { name = "19 years"
                , dateOfDeath = fromGregorian 2007 8 8
                , xUsername = "test"
                }

    -- Someone who died exactly 20 years before our test date.
    -- This represents the boundary of our 20-year rule.
    let died20YearsAgo =
            Person
                { name = "20 years"
                , dateOfDeath = fromGregorian 2006 8 8
                , xUsername = "test"
                }

    -- Someone who died 21 years ago.
    -- This person should no longer qualify for our memorial bot.
    let died21YearsAgo =
            Person
                { name = "21 years"
                , dateOfDeath = fromGregorian 2005 8 8
                , xUsername = "test"
                }

    -- This person died within the last 20 years,
    -- but the death anniversary is tomorrow rather than today.
    let wrongDay =
            Person
                { name = "Wrong day"
                , dateOfDeath = fromGregorian 2016 8 9
                , xUsername = "test"
                }

    -- A small fake data set that plays the role of the list
    -- we will eventually receive from Wikidata.
    let people =
            [ died19YearsAgo
            , died20YearsAgo
            , died21YearsAgo
            , wrongDay
            ]

    -- Apply our memorial-selection logic to the fake data set.
    --
    -- We expect only died19YearsAgo and died20YearsAgo
    -- to survive the filter.
    let candidates =
            findMemorialCandidates today people


    ------------------------------------------------------------------
    -- Test data: X posts
    ------------------------------------------------------------------

    -- These posts simulate an X account's timeline.
    --
    -- The post IDs are deliberately simple strings because we only
    -- care about their identity for now.
    --
    -- UTCTime consists of:
    --   * a calendar date
    --   * the amount of time since midnight
    --
    -- secondsToDiffTime 0 therefore means exactly midnight.

    let post1 =
            Post
                "1"
                (UTCTime
                    (fromGregorian 2020 1 1)
                    (secondsToDiffTime 0))

    let post2 =
            Post
                "2"
                (UTCTime
                    (fromGregorian 2021 1 1)
                    (secondsToDiffTime 0))

    let post3 =
            Post
                "3"
                (UTCTime
                    (fromGregorian 2022 1 1)
                    (secondsToDiffTime 0))

    let post4 =
            Post
                "4"
                (UTCTime
                    (fromGregorian 2023 1 1)
                    (secondsToDiffTime 0))

    let post5 =
            Post
                "5"
                (UTCTime
                    (fromGregorian 2024 1 1)
                    (secondsToDiffTime 0))

    -- We simulate the order in which X returns a user's timeline:
    -- newest post first, oldest post last.
    let timeline =
            [ post5
            , post4
            , post3
            , post2
            , post1
            ]


    ------------------------------------------------------------------
    -- Tests: death anniversary
    ------------------------------------------------------------------

    -- David Bowie died on January 10.
    -- January 10 in another year should therefore match.
    assert
        "death anniversary should match"
        (hasDeathAnniversary
            (fromGregorian 2026 1 10)
            davidBowie)

    -- January 11 should not match a January 10 death date.
    assert
        "different day should not match"
        (not $
            hasDeathAnniversary
                (fromGregorian 2026 1 11)
                davidBowie)


    ------------------------------------------------------------------
    -- Tests: 20-year limit
    ------------------------------------------------------------------

    -- 19 years is inside our allowed range.
    assert
        "19 years ago should be included"
        (diedWithinYears 20 today died19YearsAgo)

    -- Exactly 20 years should still be allowed.
    -- This tests an important boundary condition.
    assert
        "20 years ago should be included"
        (diedWithinYears 20 today died20YearsAgo)

    -- 21 years exceeds our configured limit.
    assert
        "21 years ago should be excluded"
        (not $ diedWithinYears 20 today died21YearsAgo)


    ------------------------------------------------------------------
    -- Tests: complete memorial-candidate rule
    ------------------------------------------------------------------

    -- The person died 19 years ago AND today is the anniversary.
    assert
        "19 year old death on today's date should be a candidate"
        (isMemorialCandidate today died19YearsAgo)

    -- Exactly 20 years ago is still accepted.
    assert
        "20 year old death on today's date should be a candidate"
        (isMemorialCandidate today died20YearsAgo)

    -- The date matches, but 21 years is outside our range.
    assert
        "21 year old death should not be a candidate"
        (not $ isMemorialCandidate today died21YearsAgo)

    -- The person died recently enough, but today is not
    -- their death anniversary.
    assert
        "recent death on another date should not be a candidate"
        (not $ isMemorialCandidate today wrongDay)


    ------------------------------------------------------------------
    -- Tests: filtering a list of people
    ------------------------------------------------------------------

    -- Only two people in our fake data set should qualify.
    assert
        "should find exactly two memorial candidates"
        (length candidates == 2)

    -- Checking only the length is not enough:
    -- we also verify that the correct people were selected.
    assert
        "should select the correct memorial candidates"
        (candidates == [died19YearsAgo, died20YearsAgo])


    ------------------------------------------------------------------
    -- Tests: selecting posts
    ------------------------------------------------------------------

    -- The timeline is newest -> oldest:
    --
    --     post5, post4, post3, post2, post1
    --
    -- We want the three newest posts, but Ba'alat 'Ob should
    -- repost them oldest -> newest throughout the memorial day.
    --
    -- Therefore we expect:
    --
    --     post3, post4, post5
    assert
        "should select three posts oldest first"
        (selectMemorialPosts 3 timeline
            == [post3, post4, post5])

    -- Asking for more posts than exist should simply return
    -- all available posts in chronological order.
    assert
        "requesting more posts than available should return all"
        (selectMemorialPosts 10 timeline
            == [post1, post2, post3, post4, post5])

    -- Asking for zero posts should produce an empty list.
    assert
        "requesting zero posts should return none"
        (selectMemorialPosts 0 timeline == [])

    ------------------------------------------------------------------
    -- Tests: Wikidata JSON decoding
    ------------------------------------------------------------------

    -- This JSON represents a simplified value returned by the
    -- Wikidata SPARQL endpoint.
    let json =
            LBS.pack
                "{ \"type\": \"uri\", \"value\": \"http://www.wikidata.org/entity/Q42\" }"

    -- `decode` does not return SparqlValue directly.
    --
    -- JSON decoding can fail, so Aeson returns:
    --
    --     Maybe SparqlValue
    --
    -- A successful result is wrapped in `Just`.
    -- Invalid JSON produces `Nothing`.
    let decoded =
            decode json :: Maybe SparqlValue

    assert
        "should decode a SPARQL value"
        (decoded
            == Just
                (SparqlValue
                    "http://www.wikidata.org/entity/Q42"))


      ------------------------------------------------------------------
    -- Tests: complete Wikidata response decoding
    ------------------------------------------------------------------

    -- This is a minimal but structurally realistic SPARQL response.
        ------------------------------------------------------------------
    -- Tests: complete Wikidata response decoding
    ------------------------------------------------------------------

    -- This is a minimal but structurally realistic SPARQL response.
    let responseJson =
          LBS.pack $
              concat
                  [ "{"
                  , "\"results\": {"
                  , "\"bindings\": ["
                  , "{"
                  , "\"person\": {"
                  , "\"type\": \"uri\","
                  , "\"value\": \"http://www.wikidata.org/entity/Q42\""
                  , "},"
                  , "\"personLabel\": {"
                  , "\"type\": \"literal\","
                  , "\"value\": \"Douglas Adams\""
                  , "},"
                  , "\"dateOfDeath\": {"
                  , "\"type\": \"literal\","
                  , "\"value\": \"2001-05-11T00:00:00Z\""
                  , "},"
                  , "\"xUsername\": {"
                  , "\"type\": \"literal\","
                  , "\"value\": \"DouglasNoelAdams\""
                  , "}"
                  , "}"
                  , "]"
                  , "}"
                  , "}"
                  ]

    let decodedResponse =
         decode responseJson :: Maybe WD.WikidataResponse

    let expectedResponse =
                  WD.WikidataResponse
                    (WD.WikidataResults
                        [ WD.WikidataBinding
                            (WD.SparqlValue
                                "http://www.wikidata.org/entity/Q42")
                            (WD.SparqlValue
                                "Douglas Adams")
                            (WD.SparqlValue
                                "2001-05-11T00:00:00Z")
                            (WD.SparqlValue
                                "DouglasNoelAdams")
                        ])

    assert
        "should decode a complete Wikidata response"
        (decodedResponse == Just expectedResponse)

    ------------------------------------------------------------------
    -- Tests: converting Wikidata data into domain data
    ------------------------------------------------------------------

    -- This binding represents the Wikidata data from which
    -- we want to construct our own Person value.
    let douglasAdamsBinding =
          WD.WikidataBinding
              (WD.SparqlValue
                  "http://www.wikidata.org/entity/Q42")
              (WD.SparqlValue
                  "Douglas Adams")
              (WD.SparqlValue
                  "2001-05-11T00:00:00Z")
              (WD.SparqlValue
                  "DouglasNoelAdams")

    let expectedDouglasAdams =
            Person
                { name = "Douglas Adams"
                , dateOfDeath = fromGregorian 2001 5 11
                , xUsername = "DouglasNoelAdams"
                }

    assert
        "should convert a Wikidata binding into a Person"
        (bindingToPerson douglasAdamsBinding
            == Just expectedDouglasAdams)

    -- Invalid Wikidata dates must not produce invalid Person values.
    let invalidDateBinding =
          WD.WikidataBinding
              (WD.SparqlValue
                  "http://www.wikidata.org/entity/Q42")
              (WD.SparqlValue
                  "Douglas Adams")
              (WD.SparqlValue
                  "not-a-date")
              (WD.SparqlValue
                  "DouglasNoelAdams")

    assert
        "should reject a Wikidata binding with an invalid date"
        (bindingToPerson invalidDateBinding == Nothing)

    ------------------------------------------------------------------
    -- Success
    ------------------------------------------------------------------

    -- If execution reaches this point, none of the assertions
    -- above have failed.
    putStrLn "All tests passed."


----------------------------------------------------------------------
-- Minimal assertion helper
----------------------------------------------------------------------

-- Our tests currently do not use a dedicated testing framework.
--
-- `assert` receives:
--
--     1. an error message
--     2. a Boolean condition
--
-- If the condition is True, nothing happens.
-- If it is False, `error` terminates the test program.
--
-- Cabal sees that non-successful termination and marks the
-- test suite as failed.
assert :: String -> Bool -> IO ()
assert message condition =
    unless condition $
        error message
