module Page.UserDetail exposing (Model, init, Msg, subscriptions, update, view)

import Html exposing (div, text)



-- MODEL


type Model
    = Loading
    | Ok
        { name : String
        , email : String
        , password : String
        }

type alias UserId = String
init : UserId -> (Model, Cmd Msg)
init userId  = Debug.todo ""


-- VIEW


view : Model -> Html.Html Msg
view model =
    case model of
        Loading ->
            div [] [ text "Loading..." ]

        Ok m ->
            div []
                [ div [] [ text m.name ]
                , div [] [ text m.email ]
                , div [] [ text m.password ]
                ]



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
