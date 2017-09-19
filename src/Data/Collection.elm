module Data.Collection
    exposing
        ( Collection
        , Slug
        , collectionDecoder
        , collectionsDecoder
        , slugParser
        , slugToString
        , stringToSlug
        )

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline exposing (custom, decode, hardcoded, required)
import UrlParser


type alias Collection =
    { description : String
    , id : Int
    , name : String
    , slug : Slug
    , votingActive : Bool
    }



-- SERIALIZATION --


collectionDecoder : Decoder Collection
collectionDecoder =
    decode Collection
        |> required "description" Decode.string
        |> required "id" Decode.int
        |> required "name" Decode.string
        |> required "slug" (Decode.map Slug Decode.string)
        |> required "voting_active" Decode.bool


collectionsDecoder : Decoder (List Collection)
collectionsDecoder =
    Decode.list collectionDecoder



-- IDENTIFIERS --


type Slug
    = Slug String


slugParser : UrlParser.Parser (Slug -> a) a
slugParser =
    UrlParser.custom "SLUG" (Ok << Slug)


slugToString : Slug -> String
slugToString (Slug slug) =
    slug


stringToSlug : String -> Slug
stringToSlug slug =
    Slug slug
