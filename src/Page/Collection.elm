module Page.Collection exposing (Model, Msg, init, loadImages, update, view)

import Css exposing (..)
import Data.Collection as Collection exposing (Collection, stringToSlug)
import Data.Image as Image exposing (Image)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (class, css, href, src)
import Html.Styled.Events exposing (onClick)
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



---- UPDATE ----


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



---- VIEW ----


viewImages : List Image -> Html Msg
viewImages images =
    div [ class "mdl-grid" ] (List.map viewImage images)


viewImage : Image -> Html Msg
viewImage picture =
    div
        [ class "demo-card-image mdl-card mdl-shadow--2dp"
        , css
            [ width (px 256)
            , height (px 256)
            , margin (px 16)
            , backgroundImage (url picture.url)
            , backgroundPosition center
            , backgroundSize cover
            ]
        ]
        [ div [ class "mdl-card__title mdl-card--expand" ] []
        , div
            [ class "mdl-card__actions"
            , css
                [ height (px 52)
                , padding (px 16)
                , backgroundColor (rgba 0 0 0 0.2)
                ]
            ]
            [ span
                [ css
                    [ color (rgb 255 255 255)
                    , fontSize (px 14)
                    , fontWeight (int 500)
                    ]
                ]
                [ text picture.filename ]
            ]
        ]


view : Model -> Html Msg
view model =
    div []
        [ img [ src "/logo.svg" ] []
        , h1 [] [ text model.collection.name ]
        , viewImages model.images
        , div []
            [ button
                [ onClick Increment
                , class "mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect mdl-button--accent"
                ]
                [ text "Button" ]
            ]
        ]
