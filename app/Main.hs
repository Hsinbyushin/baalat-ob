module Main where

import BaalatOb.Memorial
    ( MemorialPlan(..)
    , createMemorialPlan
    )

import BaalatOb.Person
    ( Person(..)
    )

import BaalatOb.Wikidata
    ( fetchDeathAnniversaries
    )

import BaalatOb.X.Types
    ( XPost(..)
    )

import Control.Monad
    ( forM_
    )

import Data.List
    ( sortOn
    )

import Data.Time
    ( UTCTime(..)
    , fromGregorian
    , getCurrentTime
    , secondsToDiffTime
    , toGregorian
    , utctDay
    )


main :: IO ()
main = do
    putStrLn "Ba'alat 'Ob"
    putStrLn "Dry run"
    putStrLn ""

    now <- getCurrentTime

    let today =
            utctDay now

    putStrLn $
        "Date: "
            ++ show today

    putStrLn ""
    putStrLn "Fetching memorial candidates from Wikidata..."
    putStrLn ""

    people <-
        fetchDeathAnniversaries today

    let sortedPeople =
            sortByDeathYear people

    printSummary sortedPeople

    ------------------------------------------------------------------
    -- Fake X posts for the offline dry run
    ------------------------------------------------------------------

    let fakePosts =
            [ XPost
                { xPostId = "103"
                , xPostText = "Third post"
                , xPostCreatedAt =
                    UTCTime
                        (fromGregorian 2026 8 8)
                        (secondsToDiffTime (18 * 60 * 60))
                }

            , XPost
                { xPostId = "102"
                , xPostText = "Second post"
                , xPostCreatedAt =
                    UTCTime
                        (fromGregorian 2026 8 8)
                        (secondsToDiffTime (12 * 60 * 60))
                }

            , XPost
                { xPostId = "101"
                , xPostText = "First post"
                , xPostCreatedAt =
                    UTCTime
                        (fromGregorian 2026 8 8)
                        (secondsToDiffTime (8 * 60 * 60))
                }
            ]

    putStrLn ""
    putStrLn "Creating offline memorial plans..."
    putStrLn ""

    if null sortedPeople
        then
            putStrLn "No memorial candidates found."

        else
            forM_ sortedPeople $ \person -> do
                let plan =
                        createMemorialPlan
                            3
                            person
                            fakePosts

                printMemorialPlan plan
                putStrLn ""


-- Sorts memorial candidates by year of death, oldest first.
sortByDeathYear :: [Person] -> [Person]
sortByDeathYear =
    sortOn deathYear


-- Extracts the year of death from a person.
deathYear :: Person -> Integer
deathYear person =
    let (year, _, _) =
            toGregorian (dateOfDeath person)
    in
        year


-- Prints a human-readable dry-run summary.
printSummary :: [Person] -> IO ()
printSummary people = do
    putStrLn $
        "Found "
            ++ show (length people)
            ++ " memorial candidate(s)."

    putStrLn ""

    forM_ people printPerson


-- Prints one memorial candidate in a readable format.
printPerson :: Person -> IO ()
printPerson person = do
    putStrLn (name person)

    putStrLn $
        "  Died: "
            ++ show (dateOfDeath person)

    putStrLn $
        "  X: @"
            ++ xUsername person

    putStrLn ""


-- Prints a memorial plan in a human-readable dry-run format.
printMemorialPlan :: MemorialPlan -> IO ()
printMemorialPlan plan = do
    let person =
            memorialPerson plan

    putStrLn $
        "Memorial plan for "
            ++ name person

    putStrLn $
        "X account: @"
            ++ xUsername person

    putStrLn $
        "Selected posts: "
            ++ show (length (memorialPosts plan))

    putStrLn ""

    forM_ (memorialPosts plan) printMemorialPost

    putStrLn "DRY RUN - no posts were reposted."


-- Prints one post contained in a memorial plan.
printMemorialPost :: XPost -> IO ()
printMemorialPost post = do
    putStrLn $
        "  "
            ++ show (xPostCreatedAt post)

    putStrLn $
        "  "
            ++ xPostText post

    putStrLn ""
