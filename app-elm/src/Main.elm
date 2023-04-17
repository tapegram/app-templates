module Main exposing (..)

import Browser
import Debug exposing (log)
import Html exposing (button, div, input, table, td, text, th, thead, tr)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (Decoder, field, int, list, map4, string)
import String exposing (fromInt, toInt)


add : number -> number -> number
add a b =
    a + b


init : () -> ( Model, Cmd Messages )
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


type Model
    = Loading
    | Failure
    | Loaded State


view : Model -> Html.Html Messages
view model =
    case model of
        Loaded state ->
            div []
                [ text (fromInt state.score)
                , div [] []
                , input [ onInput TextChanged ] []
                , button [ onClick Add ] [ text "Add" ]
                , div []
                    [ viewUsers state.users ]
                ]

        Loading ->
            div [] [ text "Loading..." ]

        Failure ->
            div [] [ text "Failed to load users" ]


viewUsers : List User -> Html.Html Messages
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


toTableRow : User -> Html.Html Messages
toTableRow user =
    tr []
        [ td [] [ text (fromInt user.id) ]
        , td [] [ text user.name ]
        , td [] [ text user.email ]
        , td [] [ text user.password ]
        ]


type alias Text =
    String


type alias Key =
    Int


type Messages
    = Add
    | TextChanged Text
    | KeyPressed Key
    | GotUsers (Result Http.Error (List User))


update : Messages -> Model -> ( Model, Cmd Messages )
update msg model =
    let
        logmessage =
            log "here" "Button Clicked"

        logmessage2 =
            log "model" model
    in
    case model of
        Loaded state ->
            case msg of
                Add ->
                    ( Loaded { state | score = state.score + state.inputValue }, Cmd.none )

                TextChanged newText ->
                    let
                        log3 =
                            log "Entered Text" newText
                    in
                    ( Loaded { state | inputValue = parseInput newText }
                    , Cmd.none
                    )

                GotUsers _ ->
                    ( model, Cmd.none )

                KeyPressed key ->
                    let
                        log4 =
                            log "Key was pressed" key
                    in
                    case key of
                        13 ->
                            ( Loaded { state | score = state.score + state.inputValue }, Cmd.none )

                        _ ->
                            ( Loaded state, Cmd.none )

        Loading ->
            case msg of
                -- ( model, Cmd.none )
                Add ->
                    Debug.todo "todo"

                TextChanged _ ->
                    Debug.todo "branch 'TextChanged _' not implemented"

                KeyPressed _ ->
                    Debug.todo "branch 'KeyPressed _' not implemented"

                GotUsers result ->
                    case result of
                        Ok users ->
                            ( Loaded { initState | users = users }, Cmd.none )

                        Err err ->
                            let
                                logFailure =
                                    log "failed to fetch users" err
                            in
                            ( Failure, Cmd.none )

        Failure ->
            Debug.todo "branch 'Failure' not implemented"


parseInput : String -> Int
parseInput text =
    case toInt text of
        Just val ->
            val

        Nothing ->
            0


subscriptions : Model -> Sub Messages
subscriptions model =
    Sub.none


type alias User =
    { id : Int
    , email : String
    , password : String
    , name : String
    }


getUsers : Cmd Messages
getUsers =
    Http.get
        { url = "http://localhost:3000/users"
        , expect = Http.expectJson GotUsers usersDecoder
        }


usersDecoder : Decoder (List User)
usersDecoder =
    list
        (map4 User
            (field "id" int)
            (field "email" string)
            (field "password" string)
            (field "name" string)
        )


main : Program () Model Messages
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
