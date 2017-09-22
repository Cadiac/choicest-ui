module View.Page exposing (ActivePage(..), layout)

import Data.Collection as Collection exposing (stringToSlug)
import Html exposing (..)
import Route exposing (Route)


type ActivePage
    = Other
    | Home
    | Collection
    | About


{-| Take a page's Html and layout it with a header and footer.
isLoading can be used to slow loading during slow transitions
-}
layout : ActivePage -> Html msg -> Html msg
layout page content =
    div []
        [ viewHeader page
        , div [] [ content ]
        , viewFooter
        ]


viewHeader : ActivePage -> Html msg
viewHeader page =
    nav []
        [ div []
            [ a [ Route.href Route.Home ]
                [ text "Home" ]
            , text " | "
            , a [ Route.href Route.About ]
                [ text "About" ]
            , text " | "
            , a [ Route.href (Route.Collection (stringToSlug "the-best-collection")) ]
                [ text "Collection" ]
            ]
        , hr [] []
        ]


viewFooter : Html msg
viewFooter =
    footer []
        [ div [] []
        ]
