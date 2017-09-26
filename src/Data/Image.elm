module Data.Image
    exposing
        ( Image
        , imageDecoder
        , imagesDecoder
        )

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline exposing (custom, decode, hardcoded, required)


type alias Image =
    { contentType : String
    , description : String
    , fileSize : Int
    , filename : String
    , id : Int
    , originalFilename : String
    , uploadedBy : String
    , url : String
    }



-- SERIALIZATION --


imageDecoder : Decoder Image
imageDecoder =
    decode Image
        |> required "content_type" Decode.string
        |> required "description" Decode.string
        |> required "file_size" Decode.int
        |> required "filename" Decode.string
        |> required "id" Decode.int
        |> required "original_filename" Decode.string
        |> required "uploaded_by" Decode.string
        |> required "url" Decode.string


imagesDecoder : Decoder (List Image)
imagesDecoder =
    Decode.list imageDecoder
