module Request.Session exposing (login)

import Data.AuthToken as AuthToken exposing (JwtResponse)
import Http
import HttpBuilder exposing (RequestBuilder, withBody, withExpect, withQueryParams)
import Json.Encode as Encode
import Util exposing ((=>))


type alias LoginData data =
    { data
        | collectionId : Int
        , password : String
    }


login : String -> LoginData data -> Http.Request JwtResponse
login apiUrl data =
    let
        expect =
            AuthToken.loginDecoder
                |> Http.expectJson

        session =
            Encode.object
                [ "id" => Encode.int data.collectionId
                , "password" => Encode.string data.password
                ]

        body =
            Encode.object [ "session" => session ]
                |> Http.jsonBody
    in
    (apiUrl ++ "/login")
        |> HttpBuilder.post
        |> withBody body
        |> withExpect expect
        |> HttpBuilder.toRequest
