module BaalatOb.Person
    ( Person(..)
    , hasDeathAnniversary
    , diedWithinYears
    , isMemorialCandidate
    , findMemorialCandidates
    ) where

import Data.Time
    ( Day
    , toGregorian
    )

data Person = Person
    { name        :: String
    , dateOfDeath :: Day
    , xUsername   :: String
    }
    deriving (Eq, Show)

hasDeathAnniversary :: Day -> Person -> Bool
hasDeathAnniversary today person =
    let (_, todayMonth, todayDay) =
            toGregorian today

        (_, deathMonth, deathDay) =
            toGregorian (dateOfDeath person)

    in todayMonth == deathMonth
        && todayDay == deathDay

diedWithinYears :: Integer -> Day -> Person -> Bool
diedWithinYears years today person =
    let (todayYear, _, _) =
            toGregorian today

        (deathYear, _, _) =
            toGregorian (dateOfDeath person)

    in todayYear - deathYear <= years

isMemorialCandidate :: Day -> Person -> Bool
isMemorialCandidate today person =
    hasDeathAnniversary today person
        && diedWithinYears 20 today person

findMemorialCandidates :: Day -> [Person] -> [Person]
findMemorialCandidates today people =
    filter (isMemorialCandidate today) people
