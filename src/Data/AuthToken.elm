module Data.AuthToken
    exposing
        ( AuthToken
        , JwtResponse
        , decodeTokenFromFlags
        , decoder
        , encode
        , loginDecoder
        , withAuthorization
        )

import HttpBuilder exposing (RequestBuilder, withHeader)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline exposing (custom, decode, hardcoded, required)
import Json.Encode as Encode exposing (Value)


type AuthToken
    = AuthToken String


type alias JwtResponse =
    { jwt : AuthToken }


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


loginDecoder : Decoder JwtResponse
loginDecoder =
    decode JwtResponse
        |> required "jwt" decoder
