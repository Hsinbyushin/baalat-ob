module BaalatOb.Post
    ( Post(..)
    , selectMemorialPosts
    ) where

import Data.Time (UTCTime)

data Post = Post
    { postId        :: String
    , postCreatedAt :: UTCTime
    }
    deriving (Eq, Show)

selectMemorialPosts :: Int -> [Post] -> [Post]
selectMemorialPosts amount posts =
    reverse (take amount posts)
