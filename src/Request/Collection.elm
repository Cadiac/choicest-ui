module Request.Collection exposing (get)

import Data.Collection as Collection exposing (Collection)
import Http
import HttpBuilder exposing (RequestBuilder, withBody, withExpect, withQueryParams)
import Json.Decode as Decode
import Request.Helpers exposing (apiUrl)


-- SINGLE --


get : Collection.Slug -> Http.Request Collection
get slug =
    let
        expect =
            Collection.collectionDecoder
                |> Http.expectJson
    in
    apiUrl ("/collections/by_slug/" ++ Collection.slugToString slug)
        |> HttpBuilder.get
        |> HttpBuilder.withExpect expect
        |> HttpBuilder.toRequest



-- LIST --
