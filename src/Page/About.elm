module Page.About exposing (Model, Msg, init, update, view)

import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (class, css, href, src)
import Html.Styled.Events exposing (onClick)


---- MODEL ----


type alias Model =
    { pageTitle : String
    , pageBody : String
    , counter : Int
    }



-- UPDATE --


type Msg
    = Decrement


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Decrement ->
            ( { model | counter = model.counter - 1 }, Cmd.none )


init : Model
init =
    Model "About" "This is the aboutpage" 1


view : Model -> Html Msg
view model =
    div []
        [ img [ src "/logo.svg" ] []
        , h1 [] [ text model.pageTitle ]
        , h2 [] [ text model.pageBody ]
        , text (toString model.counter)
        , div []
            [ button
                [ onClick Decrement
                , class "mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect mdl-button--accent"
                ]
                [ text "Button" ]
            ]
        ]
