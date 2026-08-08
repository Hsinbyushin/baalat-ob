{-# LANGUAGE OverloadedStrings #-}

module BaalatOb.X.ApiTypes
    ( XUserResponse(..)
    , XUserData(..)
    , XPostsResponse(..)
    , XPostData(..)
    ) where

import Data.Aeson
    ( FromJSON(..)
    , withObject
    , (.:)
    )

import Data.Text (Text)
import Data.Time (UTCTime)


-- Represents the top-level response returned by the X API
-- when looking up a user.
data XUserResponse = XUserResponse
    { userData :: XUserData
    }
    deriving (Eq, Show)


-- Represents the user information contained in an X API response.
data XUserData = XUserData
    { userId       :: Text
    , userName     :: Text
    , userUsername :: Text
    }
    deriving (Eq, Show)


instance FromJSON XUserResponse where
    parseJSON =
        withObject "XUserResponse" $ \object ->
            XUserResponse
                <$> object .: "data"


instance FromJSON XUserData where
    parseJSON =
        withObject "XUserData" $ \object ->
            XUserData
                <$> object .: "id"
                <*> object .: "name"
                <*> object .: "username"

-- Represents the top-level response returned by the X API
-- when retrieving posts from a user.
data XPostsResponse = XPostsResponse
    { postsData :: [XPostData]
    }
    deriving (Eq, Show)


-- Represents one post contained in an X API response.
data XPostData = XPostData
    { postId        :: Text
    , postText      :: Text
    , postCreatedAt :: UTCTime
    }
    deriving (Eq, Show)

instance FromJSON XPostsResponse where
    parseJSON =
        withObject "XPostsResponse" $ \object ->
            XPostsResponse
                <$> object .: "data"


instance FromJSON XPostData where
    parseJSON =
        withObject "XPostData" $ \object ->
            XPostData
                <$> object .: "id"
                <*> object .: "text"
                <*> object .: "created_at"
