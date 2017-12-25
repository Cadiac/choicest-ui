module Route exposing (Route(..), fromLocation, href, modifyUrl)

import Data.Collection as Collection exposing (Collection)
import Html.Styled exposing (Attribute)
import Html.Styled.Attributes as Attr
import Navigation exposing (Location)
import UrlParser as Url exposing ((</>), Parser, oneOf, parseHash, s, string)


-- ROUTING --


type Route
    = Home
    | About
    | Collection Collection.Slug



--    When needing parameters on the form base/item/id
--   | Item String


routeMatcher : Parser (Route -> a) a
routeMatcher =
    oneOf
        [ Url.map Home (s "")
        , Url.map About (s "about")
        , Url.map Collection (s "collections" </> Collection.slugParser)

        --    When needing parameters on the form base/item/3
        --    , Url.map Item (s "item" </> string)
        ]



-- INTERNAL --


routeToString : Route -> String
routeToString page =
    let
        pagePath =
            case page of
                Home ->
                    []

                About ->
                    [ "about" ]

                Collection slug ->
                    [ "collections", Collection.slugToString slug ]

        --      When needing parameters on the form base/item/3
        --      Item id ->
        --          [ "item",  id ]
    in
    "#/" ++ String.join "/" pagePath



-- PUBLIC HELPERS --


href : Route -> Attribute msg
href route =
    Attr.href (routeToString route)


modifyUrl : Route -> Cmd msg
modifyUrl =
    routeToString >> Navigation.modifyUrl


fromLocation : Location -> Maybe Route
fromLocation location =
    if String.isEmpty location.hash then
        Just Home
    else
        parseHash routeMatcher location
