module Page.Home exposing (Model, Msg, init, update, view)

import Data.Collection as Collection exposing (Collection, stringToSlug)
import Html exposing (Html, button, div, h1, h2, img, text)
import Html.Attributes exposing (class, src)
import Html.Events exposing (onClick)
import Http
import Page.Errored as Errored exposing (PageLoadError, pageLoadError)
import Request.Collection
import Task exposing (Task)
import View.Page as Page


---- MODEL ----


type alias Model =
    { pageTitle : String
    , pageBody : String
    , counter : Int
    , collection : Collection
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
        loadCollection =
            Request.Collection.slug apiUrl (stringToSlug "test-collection")
                |> Http.toTask

        handleLoadError _ =
            pageLoadError Page.Other "Collection is currently unavailable."
    in
    Task.map (Model "Home" "This is the homepage" 1) loadCollection
        |> Task.mapError handleLoadError


view : Model -> Html Msg
view model =
    div []
        [ img [ src "/logo.svg" ] []
        , h1 [] [ text model.pageTitle ]
        , h2 [] [ text model.collection.name ]
        , text (toString model.counter)
        , div []
            [ button
                [ onClick Increment
                , class "mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect mdl-button--accent"
                ]
                [ text "Button" ]
            ]
        ]
