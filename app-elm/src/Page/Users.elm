module Page.Users exposing (Model, Msg, init, update, view)

import API exposing (User, usersDecoder)
import Endpoint exposing (getUsersUrl, unwrap)
import Html exposing (div, table, td, text, th, thead, tr)
import Html.Attributes exposing (classList, style)
import Html.Events exposing (onClick)
import Http
import String exposing (fromInt)



-- MODEL


type alias UserId =
    String


type alias OnUserClick =
    UserId -> Cmd Msg


type alias Model =
    { onUserClick : OnUserClick
    , state : State
    }


type State
    = Loading
    | Failed
    | Loaded
        { users : List User
        }


init : OnUserClick -> ( Model, Cmd Msg )
init onUserClick =
    ( { onUserClick = onUserClick, state = Loading }
    , getUsers
    )



-- VIEW


view : Model -> Html.Html Msg
view model =
    case model.state of
        Loaded state ->
            div []
                [ viewUsers state.users ]

        Loading ->
            div [] [ text "Loading..." ]

        Failed ->
            div [] [ text "Failed to load users" ]


viewUsers : List User -> Html.Html Msg
viewUsers users =
    table []
        (List.concat
            [ [ thead []
                    [ th [] [ text "Id" ]
                    , th [] [ text "Name" ]
                    , th [] [ text "Email" ]
                    , th [] [ text "Password" ]
                    ]
              ]
            , List.map toTableRow users
            ]
        )


toTableRow : User -> Html.Html Msg
toTableRow user =
    let
        userId =
            fromInt user.id
    in
    tr []
        [ td [ onClick (UserClicked userId), style "cursor" "pointer" ] [ text userId ]
        , td [] [ text user.name ]
        , td [] [ text user.email ]
        , td [] [ text user.password ]
        ]


-- UPDATE


type Msg
    = -- Http results
      GotUsers (Result Http.Error (List User))
    | UserClicked UserId


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case model.state of
        Loaded _ ->
            case msg of
                GotUsers _ ->
                    ( model, Cmd.none )

                UserClicked userId ->
                    ( model, model.onUserClick userId )

        Loading ->
            case msg of
                GotUsers result ->
                    case result of
                        Ok users ->
                            ( { model | state = Loaded { users = users } }, Cmd.none )

                        Err _ ->
                            ( { model | state = Failed }, Cmd.none )

                UserClicked _ ->
                    ( model, Cmd.none )

        Failed ->
            Debug.todo "branch 'Failure' not implemented"



-- HTTP


getUsers : Cmd Msg
getUsers =
    Http.get
        { url = unwrap getUsersUrl
        , expect = Http.expectJson GotUsers usersDecoder
        }
