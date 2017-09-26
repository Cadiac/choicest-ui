module Request.Collection exposing (list, single, slug)

import Data.AuthToken as AuthToken exposing (AuthToken, withAuthorization)
import Data.Collection as Collection exposing (Collection)
import Http
import HttpBuilder exposing (RequestBuilder, withBody, withExpect, withQueryParams)
import Json.Encode as Encode
import Util exposing ((=>))


-- SINGLE --


single : String -> Int -> Http.Request Collection
single apiUrl collectionId =
    let
        expect =
            Collection.collectionDecoder
                |> Http.expectJson
    in
    (apiUrl ++ "/collections/" ++ toString collectionId)
        |> HttpBuilder.get
        |> HttpBuilder.withExpect expect
        |> HttpBuilder.toRequest


slug : String -> Collection.Slug -> Http.Request Collection
slug apiUrl slug =
    let
        expect =
            Collection.collectionDecoder
                |> Http.expectJson
    in
    (apiUrl ++ "/collections/by_slug/" ++ Collection.slugToString slug)
        |> HttpBuilder.get
        |> HttpBuilder.withExpect expect
        |> HttpBuilder.toRequest



-- LIST --


list : String -> Http.Request (List Collection)
list apiUrl =
    let
        expect =
            Collection.collectionsDecoder
                |> Http.expectJson
    in
    (apiUrl ++ "/collections")
        |> HttpBuilder.get
        |> HttpBuilder.withExpect expect
        |> HttpBuilder.toRequest



-- CREATE / UPDATE / DELETE --


type alias UpdateData data =
    { data
        | name : String
        , description : String
        , voting_active : Bool
        , password : String
    }


create : String -> UpdateData data -> Http.Request Collection
create apiUrl data =
    let
        expect =
            Collection.collectionDecoder
                |> Http.expectJson

        collection =
            Encode.object
                [ "name" => Encode.string data.name
                , "description" => Encode.string data.description
                , "voting_active" => Encode.bool data.voting_active
                , "password" => Encode.string data.password
                ]

        body =
            Encode.object [ "collection" => collection ]
                |> Http.jsonBody
    in
    (apiUrl ++ "/collections")
        |> HttpBuilder.post
        |> withBody body
        |> withExpect expect
        |> HttpBuilder.toRequest


update : String -> Int -> UpdateData data -> AuthToken -> Http.Request Collection
update apiUrl collectionId data token =
    let
        expect =
            Collection.collectionDecoder
                |> Http.expectJson

        collection =
            Encode.object
                [ "name" => Encode.string data.name
                , "description" => Encode.string data.description
                , "voting_active" => Encode.bool data.voting_active
                , "password" => Encode.string data.password
                ]

        body =
            Encode.object [ "collection" => collection ]
                |> Http.jsonBody
    in
    (apiUrl ++ "/collections/" ++ toString collectionId)
        |> HttpBuilder.put
        |> withAuthorization (Just token)
        |> withBody body
        |> withExpect expect
        |> HttpBuilder.toRequest


delete : String -> Int -> AuthToken -> Http.Request ()
delete apiUrl collectionId token =
    (apiUrl ++ "/collections/" ++ toString collectionId)
        |> HttpBuilder.delete
        |> withAuthorization (Just token)
        |> HttpBuilder.toRequest
