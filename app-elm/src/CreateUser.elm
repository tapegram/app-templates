module CreateUser exposing (Model, Msg, init, update, view)

import Html exposing (button, div, input, text)
import Html.Attributes exposing (placeholder)
import Html.Events exposing (onClick, onInput)
import Html.Lazy exposing (lazy)
import Http
import Json.Decode exposing (Decoder, field, int, map4, string)
import Json.Encode



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


type alias User =
    { id : Int
    , email : String
    , password : String
    , name : String
    }



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



-- SUBSCRIPTIONS
-- HTTP


type alias Url =
    String


type Endpoint
    = Endpoint Url


unwrap : Endpoint -> String
unwrap (Endpoint url) =
    url


createUserUrl : Endpoint
createUserUrl =
    Endpoint "http://localhost:3000/users"


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


userDecoder : Decoder User
userDecoder =
    map4 User
        (field "id" int)
        (field "email" string)
        (field "password" string)
        (field "name" string)
