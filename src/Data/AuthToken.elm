module Data.AuthToken exposing (AuthToken, decodeTokenFromFlags, decoder, encode, withAuthorization)

import HttpBuilder exposing (RequestBuilder, withHeader)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)


type AuthToken
    = AuthToken String


encode : AuthToken -> Value
encode (AuthToken token) =
    Encode.string token


decoder : Decoder AuthToken
decoder =
    Decode.string
        |> Decode.map AuthToken


decodeTokenFromFlags : Maybe String -> Maybe AuthToken
decodeTokenFromFlags token =
    case token of
        Just string ->
            Decode.decodeString decoder string
                |> Result.toMaybe

        Nothing ->
            Nothing


withAuthorization : Maybe AuthToken -> RequestBuilder a -> RequestBuilder a
withAuthorization maybeToken builder =
    case maybeToken of
        Just (AuthToken token) ->
            builder
                |> withHeader "authorization" ("Bearer " ++ token)

        Nothing ->
            builder
