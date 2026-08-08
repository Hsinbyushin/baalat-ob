{-# LANGUAGE OverloadedStrings #-}

module BaalatOb.Http
    ( fetchExample
    ) where

import Network.HTTP.Simple
    ( getResponseStatusCode
    , httpLBS
    , parseRequest
    , setRequestHeader
    )

fetchExample :: IO Int
fetchExample = do
    requestWithoutHeaders <-
        parseRequest "GET https://www.wikidata.org"

    let request =
            setRequestHeader
                "User-Agent"
                ["baalat-ob/0.1 (learning project)"]
                requestWithoutHeaders

    response <-
        httpLBS request

    pure (getResponseStatusCode response)
