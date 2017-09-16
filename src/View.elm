module View exposing (view)

import Html exposing (Html, button, div, img, text)
import Html.Attributes exposing (class, src)
import Model exposing (..)


view : Model -> Html msg
view model =
    div []
        [ img [ src "/logo.svg" ] []
        , div []
            [ button [ class "mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect mdl-button--accent" ]
                [ text "Button" ]
            ]
        ]
