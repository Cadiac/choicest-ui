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
        [ class "mdl-layout mdl-js-layout"
        , css
            [ backgroundColor (rgb 250 250 250)
            , width (pct 100)
            , height (pct 100)
            , displayFlex
            , flexDirection column
            , justifyContent flexStart
            , alignItems stretch
            ]
        ]
        [ viewHeader page
        , main_
            [ class "mdl-layout__content"
            , css
                [ flex (int 1)
                , minHeight (px 720)
                , paddingLeft (px 64)
                , paddingRight (px 64)
                ]
            ]
            [ content ]
        , viewFooter
        ]


viewHeader : ActivePage -> Html msg
viewHeader page =
    div []
        [ header [ class "mdl-layout__header mdl-layout__header--transparent" ]
            [ div
                [ class "mdl-layout__header-row" ]
                [ a
                    [ class "mdl-layout-title mdl-navigation__link"
                    , css [ important (paddingLeft (px 0)) ]
                    , Route.href Route.Home
                    ]
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
        ]


viewFooter : Html msg
viewFooter =
    footer [ class "mdl-mini-footer", css [ minHeight (px 30), paddingLeft (px 80) ] ]
        [ div [ class "mdl-mini-footer__left-section" ]
            [ ul [ class "mdl-mini-footer__link-list" ]
                [ li []
                    [ a [ href "#" ]
                        [ text "Help" ]
                    ]
                , li []
                    [ a [ href "#" ]
                        [ text "Privacy & Terms" ]
                    ]
                ]
            ]
        ]
