module Page.Collection exposing (Model, Msg, init, loadImages, update, view)

import Data.Collection as Collection exposing (Collection, stringToSlug)
import Data.Image as Image exposing (Image)
import Html exposing (Html, button, div, h1, h2, img, text)
import Html.Attributes exposing (class, src)
import Html.Events exposing (onClick)
import Http
import Page.Errored as Errored exposing (PageLoadError, pageLoadError)
import Request.Collection
import Request.Image
import Task exposing (Task)
import View.Page as Page


---- MODEL ----


type alias Model =
    { counter : Int
    , images : List Image
    , collection : Collection
    }



-- UPDATE --


type Msg
    = Increment
    | LoadImages String
    | ImagesLoaded (Result Http.Error (List Image))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Increment ->
            ( { model | counter = model.counter + 1 }, Cmd.none )

        LoadImages apiUrl ->
            ( model, loadImages apiUrl model.collection.id )

        ImagesLoaded (Ok loadedImages) ->
            ( { model | images = loadedImages }, Cmd.none )

        ImagesLoaded (Err error) ->
            -- In a serious production application, we would log the error to
            -- a logging service so we could investigate later.
            ( { model | images = [] }, Cmd.none )


loadImages : String -> Int -> Cmd Msg
loadImages apiUrl collectionId =
    Request.Image.list apiUrl collectionId
        |> Http.toTask
        |> Task.attempt ImagesLoaded


init : String -> Collection.Slug -> Task PageLoadError Model
init apiUrl slug =
    let
        loadCollection =
            Request.Collection.slug apiUrl slug
                |> Http.toTask

        handleLoadError _ =
            pageLoadError Page.Other "Collection is currently unavailable."
    in
    Task.map (Model 1 []) loadCollection
        |> Task.mapError handleLoadError


view : Model -> Html Msg
view model =
    div []
        [ img [ src "/logo.svg" ] []
        , h1 [] [ text "foobar" ]
        , text (toString model.counter)
        , div []
            [ button
                [ onClick Increment
                , class "mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect mdl-button--accent"
                ]
                [ text "Button" ]
            ]
        ]
