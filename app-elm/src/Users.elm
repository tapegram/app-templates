module Users exposing (Model, Msg, init, update, view)

import Browser
import Html exposing (button, div, input, table, td, text, th, thead, tr)
import Html.Attributes exposing (placeholder)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (Decoder, field, int, list, map4, string)
import Json.Encode
import String exposing (fromInt, toInt)



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



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
    , newUserFormName : String
    , newUserFormEmail : String
    , newUserFormPassword : String
    }


type alias NewUserFormState =
    { name : String
    , email : String
    , password : String
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
    , newUserFormName = ""
    , newUserFormEmail = ""
    , newUserFormPassword = ""
    }



-- VIEW


view : Model -> Html.Html Msg
view model =
    case model of
        Loaded state ->
            div []
                [ text (fromInt state.score)
                , div [] []
                , input [ onInput TextChanged ] []
                , button [ onClick Added ] [ text "Add" ]
                , div []
                    [ viewUsers state.users ]
                , div [] []
                , div []
                    [ input [ onInput NewUserFormNameChanged, placeholder "name" ] []
                    , input [ onInput NewUserFormEmailChanged, placeholder "email" ] []
                    , input [ onInput NewUserFormPasswordChanged, placeholder "password" ] []
                    , button [ onClick NewUserFormSubmitted ] [ text "Go!" ]
                    ]
                ]

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


type alias Text =
    String


type alias Key =
    Int


type
    Msg
    -- Tutorial stuff to remove later
    = Added
    | TextChanged Text
    | KeyPressed Key
      -- Http results
    | GotUsers (Result Http.Error (List User))
    | UserCreated (Result Http.Error User)
      -- New User form
    | NewUserFormNameChanged String
    | NewUserFormPasswordChanged String
    | NewUserFormEmailChanged String
    | NewUserFormSubmitted


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case model of
        Loaded state ->
            case msg of
                Added ->
                    ( Loaded { state | score = state.score + state.inputValue }, Cmd.none )

                TextChanged newText ->
                    ( Loaded { state | inputValue = parseInput newText }
                    , Cmd.none
                    )

                GotUsers _ ->
                    ( model, Cmd.none )

                UserCreated (Ok user) ->
                    ( Loaded { state | users = state.users ++ [ user ] }, Cmd.none )

                UserCreated (Err _) ->
                    Debug.todo "Failed to create user"

                KeyPressed key ->
                    case key of
                        13 ->
                            ( Loaded { state | score = state.score + state.inputValue }, Cmd.none )

                        _ ->
                            ( Loaded state, Cmd.none )

                NewUserFormNameChanged name ->
                    ( Loaded { state | newUserFormName = name }, Cmd.none )

                NewUserFormPasswordChanged password ->
                    ( Loaded { state | newUserFormPassword = password }, Cmd.none )

                NewUserFormEmailChanged email ->
                    ( Loaded { state | newUserFormEmail = email }, Cmd.none )

                NewUserFormSubmitted ->
                    ( model, createUser state.newUserFormName state.newUserFormEmail state.newUserFormPassword )

        Loading ->
            case msg of
                GotUsers result ->
                    case result of
                        Ok users ->
                            ( Loaded { initState | users = users }, Cmd.none )

                        Err _ ->
                            ( Failure, Cmd.none )

                _ ->
                    ( Loading, Cmd.none )

        Failure ->
            Debug.todo "branch 'Failure' not implemented"


parseInput : String -> Int
parseInput text =
    case toInt text of
        Just val ->
            val

        Nothing ->
            0



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- HTTP


type alias Url =
    String


type alias UserId =
    String


type Endpoint
    = Endpoint Url


unwrap : Endpoint -> String
unwrap (Endpoint url) =
    url


getUsersUrl : Endpoint
getUsersUrl =
    Endpoint "http://localhost:3000/users"


createUserUrl : Endpoint
createUserUrl =
    Endpoint "http://localhost:3000/users"


updateUserUrl : UserId -> Endpoint
updateUserUrl userId =
    Endpoint (String.join "/" [ "http://localhost:3000/users", userId ])


getUsers : Cmd Msg
getUsers =
    Http.get
        { url = unwrap getUsersUrl
        , expect = Http.expectJson GotUsers usersDecoder
        }



-- TODO: implement this correctly


createUser : String -> String -> String -> Cmd Msg
createUser name email password =
    Http.post
        { url = unwrap createUserUrl
        , body =
            Http.jsonBody <|
                Json.Encode.object
                    [ ( "name", Json.Encode.string name )
                    , ( "email", Json.Encode.string email )
                    , ( "password", Json.Encode.string password )
                    ]
        , expect = Http.expectJson UserCreated userDecoder
        }


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
