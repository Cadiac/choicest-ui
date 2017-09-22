port module Ports exposing (onTokenChange, storeToken)

import Json.Encode exposing (Value)


port storeToken : Maybe String -> Cmd msg


port onTokenChange : (Value -> msg) -> Sub msg
