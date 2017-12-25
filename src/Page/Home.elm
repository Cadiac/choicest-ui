module Page.Home exposing (Model, Msg, init, update, view)

import Data.Collection as Collection exposing (Collection, stringToSlug)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (class, src)
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
    div [ class "mdl-cell mdl-cell--3-col mdl-card mdl-shadow--2dp" ]
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
    div []
        [ img [ src "/logo.svg" ] []
        , h1 [] [ text model.pageTitle ]
        , text (toString model.counter)
        , viewCollections model.collections
        , div []
            [ button
                [ onClick Increment
                , class "mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect mdl-button--accent"
                ]
                [ text "Button" ]
            ]
        ]
