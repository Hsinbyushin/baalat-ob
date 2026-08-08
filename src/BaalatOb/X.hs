{-# LANGUAGE OverloadedStrings #-}

module BaalatOb.X
    ( lookupUserByUsername
    ) where

import BaalatOb.X.ApiTypes
    ( XUserResponse
    )

import BaalatOb.X.Types
    ( XUser
    , xUserFromResponse
    )

import Data.Aeson
    ( eitherDecode
    )

import qualified Data.ByteString.Char8 as BS

import Network.HTTP.Simple
    ( getResponseBody
    , getResponseStatusCode
    , httpLBS
    , parseRequest
    , setRequestHeader
    )


import qualified Data.ByteString.Lazy as LBS

lookupUserByUsername :: String -> String -> IO XUser
lookupUserByUsername accessToken username = do
    requestWithoutHeaders <-
        parseRequest $
            "GET https://api.x.com/2/users/by/username/"
                ++ username

    let request =
            setRequestHeader
                "Authorization"
                [BS.pack ("Bearer " ++ accessToken)]
                requestWithoutHeaders

    response <-
        httpLBS request

    let status =
            getResponseStatusCode response

    if status < 200 || status >= 300
        then
            fail $
                "X API request failed with status "
                    ++ show status
                    ++ ": "
                    ++ BS.unpack
                        (LBS.toStrict (getResponseBody response))

        else
            case eitherDecode (getResponseBody response) of
                Left err ->
                    fail $
                        "Could not decode X user response: "
                            ++ err

                Right apiResponse ->
                    pure $
                        xUserFromResponse
                            (apiResponse :: XUserResponse)
