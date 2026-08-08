module BaalatOb.Memorial
    ( MemorialPlan(..)
    , createMemorialPlan
    ) where

import BaalatOb.Person
    ( Person
    )

import BaalatOb.Post
    ( selectMemorialPosts
    )

import BaalatOb.X.Types
    ( XPost
    )


-- Represents the actions Ba'alat 'Ob plans for one memorial candidate.
--
-- A memorial plan contains the person being remembered and the posts
-- selected for that person's memorial day.
data MemorialPlan = MemorialPlan
    { memorialPerson :: Person
    , memorialPosts  :: [XPost]
    }
    deriving (Eq, Show)


-- Creates a memorial plan for one person.
--
-- The function selects the requested number of posts and keeps the
-- actual planning logic independent from HTTP requests or other IO.
createMemorialPlan :: Int -> Person -> [XPost] -> MemorialPlan
createMemorialPlan postCount person posts =
    MemorialPlan
        { memorialPerson = person
        , memorialPosts =
            selectMemorialPosts postCount posts
        }
