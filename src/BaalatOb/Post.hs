module BaalatOb.Post
    ( selectMemorialPosts
    ) where

import BaalatOb.X.Types
    ( XPost
    )

-- Selects the newest posts from a timeline and returns them
-- in chronological order, oldest first.
--
-- X timelines are expected to be ordered newest first.
selectMemorialPosts :: Int -> [XPost] -> [XPost]
selectMemorialPosts count =
    reverse . take count
