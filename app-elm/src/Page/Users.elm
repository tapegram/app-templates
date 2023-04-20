module Page.Users exposing (Model, Msg, init, update, view)

import Endpoint exposing (getUsersUrl, unwrap)
import API exposing (User, usersDecoder)
import Html exposing (div, table, td, text, th, thead, tr)
import Http
import String exposing (fromInt)



-- MODEL


type Model
    = Loading
    | Failure
    | Loaded State


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading
    , getUsers
    )


type alias State =
    { score : Int
    , firstName : String
    , lastName : String
    , inputValue : Int
    , users : List User
    }


initState : State
initState =
    { score = 0
    , firstName = "Kindson"
    , lastName = "Munonye"
    , inputValue = 0
    , users = []
    }



-- VIEW


view : Model -> Html.Html Msg
view model =
    case model of
        Loaded state ->
            div []
                [ viewUsers state.users ]

        Loading ->
            div [] [ text "Loading..." ]

        Failure ->
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
    tr []
        [ td [] [ text (fromInt user.id) ]
        , td [] [ text user.name ]
        , td [] [ text user.email ]
        , td [] [ text user.password ]
        ]



-- UPDATE


type Msg
    = -- Http results
      GotUsers (Result Http.Error (List User))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case model of
        Loaded _ ->
            case msg of
                GotUsers _ ->
                    ( model, Cmd.none )

        Loading ->
            case msg of
                GotUsers result ->
                    case result of
                        Ok users ->
                            ( Loaded { initState | users = users }, Cmd.none )

                        Err _ ->
                            ( Failure, Cmd.none )

        Failure ->
            Debug.todo "branch 'Failure' not implemented"



-- HTTP


getUsers : Cmd Msg
getUsers =
    Http.get
        { url = unwrap getUsersUrl
        , expect = Http.expectJson GotUsers usersDecoder
        }
