module Request.Image exposing (list, single, slug)

import Data.AuthToken as AuthToken exposing (AuthToken, withAuthorization)
import Data.Image as Image exposing (Image)
import Http
import HttpBuilder exposing (RequestBuilder, withBody, withExpect, withQueryParams)
import Json.Encode as Encode
import Util exposing ((=>))


-- SINGLE --


single : String -> Int -> Http.Request Image
single apiUrl collectionId imageId =
    let
        expect =
            Image.imageDecoder
                |> Http.expectJson
    in
    (apiUrl ++ "/collections/" ++ toString collectionId ++ "/images/" ++ toString imageId)
        |> HttpBuilder.get
        |> HttpBuilder.withExpect expect
        |> HttpBuilder.toRequest



-- LIST --


list : String -> Http.Request (List Image)
list apiUrl collectionId =
    let
        expect =
            Image.imagesDecoder
                |> Http.expectJson
    in
    (apiUrl ++ "/collections/" ++ toString collectionId ++ "/images")
        |> HttpBuilder.get
        |> HttpBuilder.withExpect expect
        |> HttpBuilder.toRequest



-- CREATE / UPDATE / DELETE --


type alias UpdateData data =
    { data
        | original_filename : String
        , file_size : Int
        , description : String
        , content_type : String
        , uploaded_by : String
    }


create : String -> Int -> UpdateData data -> Http.Request Image
create apiUrl collectionId data =
    let
        expect =
            Image.imageDecoder
                |> Http.expectJson

        image =
            Encode.object
                [ "original_filename" => Encode.string data.name
                , "file_size" => Encode.int data.file_size
                , "description" => Encode.string data.description
                , "content_type" => Encode.string data.content_type
                , "uploaded_by" => Encode.string data.uploaded_by
                ]

        body =
            Encode.object [ "image" => image ]
                |> Http.jsonBody
    in
    (apiUrl ++ "/collections/" ++ toString collectionId ++ "/images")
        |> HttpBuilder.post
        |> withBody body
        |> withExpect expect
        |> HttpBuilder.toRequest
