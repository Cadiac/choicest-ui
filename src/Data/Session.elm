module Data.Session exposing (Session, attempt)

import Data.AuthToken as AuthToken exposing (AuthToken)
import Util exposing ((=>))


type alias Session =
    { token : Maybe AuthToken }


attempt : String -> (AuthToken -> Cmd msg) -> Session -> ( List String, Cmd msg )
attempt attemptedAction toCmd session =
    case session.token of
        Nothing ->
            [ "Sign in to " ++ attemptedAction ++ "." ] => Cmd.none

        Just token ->
            [] => toCmd token
