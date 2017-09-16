module View exposing (view)

import Html exposing (Html, div, img, text)
import Html.Attributes exposing (src)
import Model exposing (..)


view : Model -> Html msg
view model =
    div []
        [ img [ src "/logo.svg" ] []
        , div [] [ text "Your Elm App is working!" ]
        ]
