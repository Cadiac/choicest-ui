module Main exposing (..)

import Data.AuthToken as AuthToken exposing (AuthToken)
import Data.Session as Session exposing (Session)
import Html exposing (Html)
import Json.Decode as Decode exposing (Value, nullable)
import Navigation exposing (Location)
import Page.About as About
import Page.Collection as Collection
import Page.Errored as Errored exposing (PageLoadError)
import Page.Home as Home
import Page.NotFound as NotFound
import Ports
import Route exposing (..)
import Task
import Util exposing ((=>))
import View.Page as Page exposing (ActivePage)


---- MODEL ----


type alias Model =
    { pageState : PageState
    , session : Session
    , apiUrl : String
    }


type Page
    = Blank
    | NotFound
    | Home Home.Model
    | About About.Model
    | Collection Collection.Model
    | Errored PageLoadError


type PageState
    = Loaded Page
    | TransitioningFrom Page



---- UPDATE ----


type Msg
    = SetRoute (Maybe Route)
    | HomeLoaded (Result PageLoadError Home.Model)
    | CollectionLoaded (Result PageLoadError Collection.Model)
    | HomeMsg Home.Msg
    | CollectionMsg Collection.Msg
    | AboutMsg About.Msg
    | SetSession (Maybe AuthToken)


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

        Just (Route.Collection slug) ->
            transition CollectionLoaded (Collection.init model.apiUrl slug)

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

        ( CollectionLoaded (Ok subModel), _ ) ->
            { model | pageState = Loaded (Collection subModel) }
                => Cmd.map CollectionMsg (Collection.loadImages model.apiUrl subModel.collection.id)

        ( CollectionLoaded (Err error), _ ) ->
            { model | pageState = Loaded (Errored error) } ! []

        -- Update for page specfic msgs
        ( HomeMsg subMsg, Home subModel ) ->
            toPage Home HomeMsg Home.update subMsg subModel

        ( CollectionMsg subMsg, Collection subModel ) ->
            toPage Collection CollectionMsg Collection.update subMsg subModel

        ( AboutMsg subMsg, About subModel ) ->
            toPage About AboutMsg About.update subMsg subModel

        ( _, NotFound ) ->
            -- Disregard incoming messages when we're on the
            -- NotFound page.
            model ! []

        ( _, _ ) ->
            -- Disregard incoming messages that arrived for the wrong page
            -- model ! []
            -- Lets just crash for now
            Debug.crash "Incoming message for the wrong page"



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

        Collection subModel ->
            Collection.view subModel
                |> layout Page.Collection
                |> Html.map CollectionMsg

        About subModel ->
            About.view subModel
                |> layout Page.About
                |> Html.map AboutMsg



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ pageSubscriptions (getPage model.pageState)
        , Sub.map SetSession sessionChange
        ]


sessionChange : Sub (Maybe AuthToken)
sessionChange =
    Ports.onTokenChange (Decode.decodeValue AuthToken.decoder >> Result.toMaybe)


getPage : PageState -> Page
getPage pageState =
    case pageState of
        Loaded page ->
            page

        TransitioningFrom page ->
            page


pageSubscriptions : Page -> Sub Msg
pageSubscriptions page =
    case page of
        Blank ->
            Sub.none

        Errored _ ->
            Sub.none

        NotFound ->
            Sub.none

        Home _ ->
            Sub.none

        Collection _ ->
            Sub.none

        About _ ->
            Sub.none



---- PROGRAM ----


type alias Flags =
    { apiUrl : String
    , token : Maybe String
    }


initialPage : Page
initialPage =
    Blank


init : Flags -> Location -> ( Model, Cmd Msg )
init flags location =
    setRoute (Route.fromLocation location)
        { pageState = Loaded initialPage
        , apiUrl = flags.apiUrl
        , session = { token = AuthToken.decodeTokenFromFlags flags.token }
        }


main : Program Flags Model Msg
main =
    Navigation.programWithFlags (Route.fromLocation >> SetRoute)
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }
