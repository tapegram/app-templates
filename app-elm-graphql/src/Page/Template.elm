module Page.Template exposing (Model, Msg, init, subscriptions, update, view)

import Html exposing (div, text)



--
-- This page is a template that can be copy + pasted when making new pages.
--
-- MODEL


type alias Model =
    {}


init : () -> ( Model, Cmd Msg )
init _ =
    ( {}, Cmd.none )



-- VIEW


view : Model -> Html.Html Msg
view _ =
    div [] [ text "Hello World" ]



-- UPDATE


type Msg
    = NothingYet


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NothingYet ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
