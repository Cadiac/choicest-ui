module Request.Comparison exposing (create, result, single)

import Data.Comparison as Comparison exposing (Comparison, ImageResult)
import Http
import HttpBuilder exposing (RequestBuilder, withBody, withExpect, withQueryParams)
import Json.Encode as Encode
import Util exposing ((=>))


-- SINGLE --


single : String -> Int -> Int -> Http.Request Comparison
single apiUrl collectionId comparisonId =
    let
        expect =
            Comparison.comparisonDecoder
                |> Http.expectJson
    in
    (apiUrl ++ "/collections/" ++ toString collectionId ++ "/comparisons/" ++ toString comparisonId)
        |> HttpBuilder.get
        |> HttpBuilder.withExpect expect
        |> HttpBuilder.toRequest


result : String -> Int -> Int -> Http.Request ImageResult
result apiUrl collectionId imageId =
    let
        expect =
            Comparison.imageResultDecoder
                |> Http.expectJson
    in
    (apiUrl ++ "/collections/" ++ toString collectionId ++ "/results")
        |> HttpBuilder.get
        |> HttpBuilder.withExpect expect
        |> HttpBuilder.toRequest



-- CREATE --


type alias UpdateData data =
    { data
        | winner_id : Int
        , loser_id : Int
    }


create : String -> Int -> UpdateData data -> Http.Request Comparison
create apiUrl collectionId data =
    let
        expect =
            Comparison.comparisonDecoder
                |> Http.expectJson

        body =
            Encode.object
                [ "winner_id" => Encode.int data.winner_id
                , "loser_id" => Encode.int data.loser_id
                ]
                |> Http.jsonBody
    in
    (apiUrl ++ "/collections/" ++ toString collectionId ++ "/comparisons")
        |> HttpBuilder.post
        |> withBody body
        |> withExpect expect
        |> HttpBuilder.toRequest
