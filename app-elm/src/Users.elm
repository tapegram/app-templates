module Users exposing (Model, Msg, init, update, view)

import Html exposing (div, table, td, text, th, thead, tr)
import Http
import Json.Decode exposing (Decoder, field, int, list, map4, string)
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


type alias User =
    { id : Int
    , email : String
    , password : String
    , name : String
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


type alias Url =
    String


type Endpoint
    = Endpoint Url


unwrap : Endpoint -> String
unwrap (Endpoint url) =
    url


getUsersUrl : Endpoint
getUsersUrl =
    Endpoint "http://localhost:3000/users"

getUsers : Cmd Msg
getUsers =
    Http.get
        { url = unwrap getUsersUrl
        , expect = Http.expectJson GotUsers usersDecoder
        }



-- TODO: implement this correctly

userDecoder : Decoder User
userDecoder =
    map4 User
        (field "id" int)
        (field "email" string)
        (field "password" string)
        (field "name" string)


usersDecoder : Decoder (List User)
usersDecoder =
    list userDecoder
