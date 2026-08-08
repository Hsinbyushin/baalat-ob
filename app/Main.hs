module Main where

import BaalatOb.Person
    ( Person(..)
    )

import BaalatOb.Wikidata
    ( fetchDeathAnniversaries
    )

import Data.Time
    ( getCurrentTime
    , toGregorian
    , utctDay
    )

import Control.Monad (forM_)

import Data.List (sortOn)




main :: IO ()
main = do
    putStrLn "Ba'alat 'Ob"
    putStrLn "Dry run"
    putStrLn ""

    now <- Data.Time.getCurrentTime

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

    printSummary (sortByDeathYear people)


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

-- Sorts memorial candidates by year of death, oldest first.
sortByDeathYear :: [Person] -> [Person]
sortByDeathYear =
    sortOn deathYear


-- Extracts the year of death from a person.
deathYear :: Person -> Integer
deathYear person =
    let (year, _, _) =
            toGregorian (dateOfDeath person)
    in year
