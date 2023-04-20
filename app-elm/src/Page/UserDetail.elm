module Page.UserDetail exposing (Model, Msg, init, update, view)

import API exposing (User, userDecoder)
import Endpoint exposing (getUserUrl, unwrap)
import Html exposing (div, text)
import Http



-- MODEL


type Model
    = Loading
    | Success
        { user : User
        }
    | Failed


type alias UserId =
    String


init : UserId -> ( Model, Cmd Msg )
init userId =
    ( -- Start in a loading state
      Loading
    , -- Immediately query the backend for the provided user
      getUser userId
    )



-- VIEW


view : Model -> Html.Html Msg
view model =
    case model of
        Loading ->
            div [] [ text "Loading..." ]

        Success m ->
            div []
                [ div [] [ text m.user.name ]
                , div [] [ text m.user.email ]
                , div [] [ text m.user.password ]
                ]

        Failed ->
            div [] [ text "Failed to fetch user." ]



-- UPDATE


type Msg
    = GotUser (Result Http.Error User)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg _ =
    case msg of
        GotUser result ->
            case result of
                Ok user ->
                    ( Success { user = user }, Cmd.none )

                Err _ ->
                    ( Failed, Cmd.none )



-- HTTP


getUser : UserId -> Cmd Msg
getUser userId =
    Http.get
        { url = unwrap <| getUserUrl userId
        , expect = Http.expectJson GotUser userDecoder
        }
