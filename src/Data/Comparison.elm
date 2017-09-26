module Data.Comparison
    exposing
        ( Comparison
        , ImageResult
        , Result
        , comparisonDecoder
        , imageResultDecoder
        )

import Data.Image as Image exposing (Image, imageDecoder)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline exposing (custom, decode, hardcoded, required)


type alias Comparison =
    { id : Int
    , insertedAt : String
    , loser : Image
    , winner : Image
    }


type alias Result =
    { id : Int
    , image : Image
    , timestamp : String
    }


type alias ImageResult =
    { lostAgainst : List Result
    , wonAgainst : List Result
    }



-- SERIALIZATION --


comparisonDecoder : Decoder Comparison
comparisonDecoder =
    decode Comparison
        |> required "id" Decode.int
        |> required "inserted_at" Decode.string
        |> required "loser" imageDecoder
        |> required "winner" imageDecoder


resultDecoder : Decoder Result
resultDecoder =
    decode Result
        |> required "id" Decode.int
        |> required "image" imageDecoder
        |> required "timestamp" Decode.string


resultsDecoder : Decoder (List Result)
resultsDecoder =
    Decode.list resultDecoder


imageResultDecoder : Decoder ImageResult
imageResultDecoder =
    decode ImageResult
        |> required "lostAgainst" resultsDecoder
        |> required "wonAgainst" resultsDecoder
