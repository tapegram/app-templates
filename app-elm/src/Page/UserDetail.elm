module Page.UserDetail exposing (Model, Msg, init, subscriptions, update, view)

import Html exposing (div, text)
import Http
import Endpoint exposing (unwrap)
import API exposing (userDecoder)
import API exposing (User)
import Endpoint exposing (getUserUrl)



-- MODEL


type Model
    = Loading
    | Ok
        { name : String
        , email : String
        , password : String
        }


type alias UserId =
    String


init : UserId -> ( Model, Cmd Msg )
init userId =
  (Loading, getUser userId)



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
      = GotUser (Result Http.Error User)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model = ( model, Cmd.none )

    
-- HTTP


getUser : UserId -> Cmd Msg
getUser userId =
    Http.get
        { url = unwrap <| getUserUrl userId
        , expect = Http.expectJson GotUser userDecoder
        }
