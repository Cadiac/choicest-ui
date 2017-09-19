module Main exposing (..)

import Html exposing (Html)
import Json.Decode as Decode exposing (Value)
import Navigation exposing (Location)
import Page.About as About
import Page.Errored as Errored exposing (PageLoadError)
import Page.Home as Home
import Page.NotFound as NotFound
import Route exposing (..)
import Task
import View.Page as Page exposing (ActivePage)


---- MODEL ----


type alias Flags =
    { apiUrl : String }


type alias Model =
    { pageState : PageState
    , apiUrl : String
    }


type Page
    = Blank
    | NotFound
    | Home Home.Model
    | About About.Model
    | Errored PageLoadError


type PageState
    = Loaded Page
    | TransitioningFrom Page



---- UPDATE ----


type Msg
    = SetRoute (Maybe Route)
    | HomeLoaded (Result PageLoadError Home.Model)
    | HomeMsg Home.Msg
    | AboutMsg About.Msg


setRoute : Maybe Route -> Model -> ( Model, Cmd Msg )
setRoute route model =
    let
        -- not used yet
        transition toMsg task =
            { model | pageState = TransitioningFrom (getPage model.pageState) }
                ! [ Task.attempt toMsg task ]

        errored =
            pageErrored model
    in
    case route of
        Nothing ->
            -- TODO Load 404 page not found
            ( model, Cmd.none )

        Just Route.Home ->
            transition HomeLoaded (Home.init model.apiUrl)

        Just Route.About ->
            ( { model | pageState = Loaded (About About.init) }, Cmd.none )


pageErrored : Model -> ActivePage -> String -> ( Model, Cmd msg )
pageErrored model activePage errorMessage =
    let
        error =
            Errored.pageLoadError activePage errorMessage
    in
    { model | pageState = Loaded (Errored error) } ! []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    updatePage (getPage model.pageState) msg model


updatePage : Page -> Msg -> Model -> ( Model, Cmd Msg )
updatePage page msg model =
    let
        toPage toModel toMsg subUpdate subMsg subModel =
            let
                ( newModel, newCmd ) =
                    subUpdate subMsg subModel
            in
            ( { model | pageState = Loaded (toModel newModel) }, Cmd.map toMsg newCmd )
    in
    case ( msg, page ) of
        -- Update for page transitions
        ( SetRoute route, _ ) ->
            setRoute route model

        ( HomeLoaded (Ok subModel), _ ) ->
            { model | pageState = Loaded (Home subModel) } ! []

        ( HomeLoaded (Err error), _ ) ->
            { model | pageState = Loaded (Errored error) } ! []

        -- Update for page specfic msgs
        ( HomeMsg subMsg, Home subModel ) ->
            toPage Home HomeMsg Home.update subMsg subModel

        ( AboutMsg subMsg, About subModel ) ->
            toPage About AboutMsg About.update subMsg subModel

        ( _, NotFound ) ->
            -- Disregard incoming messages when we're on the
            -- NotFound page.
            model ! []

        ( _, _ ) ->
            -- Disregard incoming messages that arrived for the wrong page
            model ! []


getPage : PageState -> Page
getPage pageState =
    case pageState of
        Loaded page ->
            page

        TransitioningFrom page ->
            page



---- VIEW ----


view : Model -> Html Msg
view model =
    case model.pageState of
        Loaded page ->
            viewPage False page

        TransitioningFrom page ->
            viewPage True page


viewPage : Bool -> Page -> Html Msg
viewPage isLoading page =
    let
        layout =
            Page.layout
    in
    case page of
        NotFound ->
            layout Page.Other NotFound.view

        Blank ->
            -- This is for the very intial page load, while we are loading
            -- data via HTTP. We could also render a spinner here.
            Html.text ""
                |> layout Page.Other

        Errored subModel ->
            Errored.view subModel
                |> layout Page.Other

        Home subModel ->
            Home.view subModel
                |> layout Page.Home
                |> Html.map HomeMsg

        About subModel ->
            About.view subModel
                |> layout Page.About
                |> Html.map AboutMsg



---- PROGRAM ----


initialPage : Page
initialPage =
    Blank


init : Flags -> Location -> ( Model, Cmd Msg )
init flags location =
    setRoute (Route.fromLocation location)
        { pageState = Loaded initialPage
        , apiUrl = flags.apiUrl
        }


main : Program Flags Model Msg
main =
    Navigation.programWithFlags (Route.fromLocation >> SetRoute)
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }
