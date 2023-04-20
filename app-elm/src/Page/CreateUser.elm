module Page.CreateUser exposing (Model, Msg, init, update, view)

import API exposing (userDecoder)
import Endpoint exposing (createUserUrl, unwrap)
import Html.Styled as Html exposing (button, div, input, text)
import Html.Styled.Attributes exposing (placeholder)
import Html.Styled.Events exposing (onClick, onInput)
import Http
import Json.Encode
import API exposing (User)



-- MODEL


type alias OnSuccess =
    User -> Cmd Msg


type alias Model =
    { name : String
    , email : String
    , password : String
    , onSuccess : OnSuccess
    }


init : OnSuccess -> ( Model, Cmd Msg )
init onSuccess =
    ( { name = "", email = "", password = "", onSuccess = onSuccess }
    , Cmd.none
    )



-- VIEW


view : Model -> Html.Html Msg
view _ =
    div []
        [ input [ onInput NewUserFormNameChanged, placeholder "name" ] []
        , input [ onInput NewUserFormEmailChanged, placeholder "email" ] []
        , input [ onInput NewUserFormPasswordChanged, placeholder "password" ] []
        , button [ onClick NewUserFormSubmitted ] [ text "Go!" ]
        , div [] []
        ]



-- UPDATE


type Msg
    = UserCreated (Result Http.Error User)
    | NewUserFormNameChanged String
    | NewUserFormPasswordChanged String
    | NewUserFormEmailChanged String
    | NewUserFormSubmitted


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UserCreated (Ok user) ->
            ( model, model.onSuccess user )

        UserCreated (Err _) ->
            Debug.todo "Failed to create user"

        NewUserFormNameChanged name ->
            ( { model | name = name }, Cmd.none )

        NewUserFormPasswordChanged password ->
            ( { model | password = password }, Cmd.none )

        NewUserFormEmailChanged email ->
            ( { model | email = email }, Cmd.none )

        NewUserFormSubmitted ->
            ( model
            , createUser
                { name = model.name
                , email = model.email
                , password = model.password
                }
            )



-- HTTP


createUser : { name : String, email : String, password : String } -> Cmd Msg
createUser { name, email, password } =
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
