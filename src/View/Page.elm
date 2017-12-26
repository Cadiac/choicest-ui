module View.Page exposing (ActivePage(..), layout)

import Css exposing (..)
import Data.Collection as Collection exposing (stringToSlug)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (class, css, href, src)
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
    div
        [ css
            [ backgroundColor (rgb 92 92 92) ]
        , class "mdl-layout mdl-js-layout"
        ]
        [ viewHeader page
        , main_ [ class "mdl-layout__content" ] [ content ]
        , viewFooter
        ]


viewHeader : ActivePage -> Html msg
viewHeader page =
    div []
        [ header [ class "mdl-layout__header mdl-layout__header--transparent" ]
            [ div [ class "mdl-layout__header-row" ]
                [ span [ class "mdl-layout-title" ]
                    [ text "Choicest" ]
                , div [ class "mdl-layout-spacer" ]
                    []
                , nav [ class "mdl-navigation" ]
                    [ a [ class "mdl-navigation__link", Route.href Route.Home ]
                        [ text "Home" ]
                    , a [ class "mdl-navigation__link", Route.href Route.About ]
                        [ text "About" ]
                    , a [ class "mdl-navigation__link", Route.href (Route.Collection (stringToSlug "test-collection")) ]
                        [ text "Collection" ]
                    ]
                ]
            ]
        , div [ class "mdl-layout__drawer" ]
            [ span [ class "mdl-layout-title" ]
                [ text "Choicest" ]
            , nav [ class "mdl-navigation" ]
                [ a [ class "mdl-navigation__link", Route.href Route.Home ]
                    [ text "Home" ]
                , a [ class "mdl-navigation__link", Route.href Route.About ]
                    [ text "About" ]
                , a [ class "mdl-navigation__link", Route.href (Route.Collection (stringToSlug "test-collection")) ]
                    [ text "Collection" ]
                ]
            ]
        ]


viewFooter : Html msg
viewFooter =
    footer []
        [ div [] []
        ]
