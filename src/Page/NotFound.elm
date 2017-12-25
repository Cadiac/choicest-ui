module Page.NotFound exposing (view)

import Html.Styled exposing (..)


-- VIEW --


view : Html msg
view =
    div []
        [ h1 [] [ text "Not Found" ]
        ]
