module Page.Home exposing (Model, Msg, init, update, view)

import Html exposing (Html, button, div, h1, h2, img, text)
import Html.Attributes exposing (class, src)
import Html.Events exposing (onClick)


---- MODEL ----


type alias Model =
    { pageTitle : String
    , pageBody : String
    , counter : Int
    }



-- UPDATE --


type Msg
    = Increment


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Increment ->
            ( { model | counter = model.counter + 1 }, Cmd.none )


init : Model
init =
    Model "Home" "This is the homepage" 1


view : Model -> Html Msg
view model =
    div []
        [ img [ src "/logo.svg" ] []
        , h1 [] [ text model.pageTitle ]
        , h2 [] [ text model.pageBody ]
        , text (toString model.counter)
        , div []
            [ button
                [ onClick Increment
                , class "mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect mdl-button--accent"
                ]
                [ text "Button" ]
            ]
        ]
