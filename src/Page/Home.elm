module Page.Home exposing (Model, Msg, init, update, view)

import Css exposing (..)
import Data.Collection as Collection exposing (Collection, stringToSlug)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (class, css, href, src)
import Html.Styled.Events exposing (onClick)
import Http
import Page.Errored as Errored exposing (PageLoadError, pageLoadError)
import Request.Collection
import Route exposing (Route)
import Task exposing (Task)
import View.Page as Page


---- MODEL ----


type alias Model =
    { pageTitle : String
    , pageBody : String
    , counter : Int
    , collections : List Collection
    }



-- UPDATE --


type Msg
    = Increment


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Increment ->
            ( { model | counter = model.counter + 1 }, Cmd.none )


init : String -> Task PageLoadError Model
init apiUrl =
    let
        loadCollections =
            Request.Collection.list apiUrl
                |> Http.toTask

        handleLoadError _ =
            pageLoadError Page.Other "Collections are currently unavailable."
    in
    Task.map (Model "Home" "This is the homepage" 1) loadCollections
        |> Task.mapError handleLoadError


viewCollections : List Collection -> Html Msg
viewCollections collections =
    div [ class "mdl-grid" ] (List.map viewCollection collections)


viewCollection : Collection -> Html Msg
viewCollection collection =
    div [ class "mdl-cell mdl-cell--3-col mdl-cell--12-col-tablet mdl-cell--12-col-phone mdl-card mdl-shadow--3dp" ]
        [ div [ class "mdl-card__title mdl-card--expand" ]
            [ h2 [ class "mdl-card__title-text" ]
                [ text collection.name ]
            ]
        , div [ class "mdl-card__supporting-text" ]
            [ text collection.description ]
        , div [ class "mdl-card__actions mdl-card--border" ]
            [ a [ Route.href (Route.Collection collection.slug), class "mdl-button mdl-button--colored mdl-js-button mdl-js-ripple-effect" ]
                [ text "Browse collection" ]
            ]
        ]


view : Model -> Html Msg
view model =
    div
        [ css
            [ displayFlex
            , flexDirection column
            , justifyContent spaceBetween
            , alignItems flexStart
            , height (pct 100)
            ]
        ]
        [ div []
            [ h2 [ class "mdl-typography--display-3", css [ padding (px 16) ] ]
                [ text model.pageTitle ]
            , viewCollections model.collections
            ]
        , div [ css [ alignSelf flexEnd, marginBottom (px 64) ] ]
            [ button
                [ class "mdl-button mdl-js-button mdl-button--fab mdl-button--colored" ]
                [ i [ class "material-icons" ]
                    [ text "add" ]
                ]
            ]
        ]
