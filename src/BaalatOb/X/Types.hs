module BaalatOb.X.Types
    ( XUser(..)
    , XPost(..)
    , xUserFromResponse
    , xPostFromData
    , xPostsFromResponse
    ) where

import BaalatOb.X.ApiTypes
    ( XPostData(..)
    , XPostsResponse(..)
    , XUserData(..)
    , XUserResponse(..)
    )

import Data.Text (unpack)
import Data.Time (UTCTime)

-- Represents an X account used by the bot.
data XUser = XUser
    { xUserId   :: String
    , xUserName :: String
    }
    deriving (Eq, Show)

-- Represents one post returned by the X API.
data XPost = XPost
    { xPostId        :: String
    , xPostText      :: String
    , xPostCreatedAt :: UTCTime
    }
    deriving (Eq, Show)

-- Converts the external X API representation into
-- the internal domain representation used by the bot.
xUserFromResponse :: XUserResponse -> XUser
xUserFromResponse response =
    let user =
            userData response
    in
        XUser
            { xUserId = unpack (userId user)
            , xUserName = unpack (userUsername user)
            }

-- Converts one post from the X API representation
-- into the internal domain representation used by the bot.
xPostFromData :: XPostData -> XPost
xPostFromData post =
    XPost
        { xPostId = unpack (postId post)
        , xPostText = unpack (postText post)
        , xPostCreatedAt = postCreatedAt post
        }

-- Converts a complete X posts response into domain posts.
xPostsFromResponse :: XPostsResponse -> [XPost]
xPostsFromResponse response =
    map xPostFromData (postsData response)
