module Main where

import BaalatOb.Wikidata
    ( fetchDeathAnniversaries
    )

import Data.Time
    ( getCurrentTime
    , utctDay
    )

main :: IO ()
main = do
    putStrLn "Ba'alat 'Ob"

    now <- getCurrentTime

    let today =
            utctDay now

    putStrLn $
        "Fetching death anniversaries for "
            ++ show today
            ++ "..."

    people <-
        fetchDeathAnniversaries today

    print people
