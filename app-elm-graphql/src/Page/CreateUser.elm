module Page.CreateUser exposing (Model, Msg, init, update, view)

import API exposing (User)
import Endpoint exposing (graphQLUrl, unwrap)
import Graphql.Http exposing (mutationRequest, send)
import Graphql.Operation exposing (RootMutation)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Html.Styled as Html exposing (button, div, input, text)
import Html.Styled.Attributes exposing (placeholder)
import Html.Styled.Events exposing (onClick, onInput)
import RemoteData exposing (RemoteData)
import UsersApi.Mutation as Mutation
import UsersApi.Object as GQLTypes
import UsersApi.Object.User as UserFields



-- MODEL


type alias OnSuccess =
    User -> Cmd Msg


type alias Model =
    { name : String
    , email : String
    , password : String
    , onSuccess : OnSuccess
    , result : RemoteData (Graphql.Http.Error User) User
    }


init : OnSuccess -> ( Model, Cmd Msg )
init onSuccess =
    ( { name = "", email = "", password = "", onSuccess = onSuccess, result = RemoteData.NotAsked }
    , Cmd.none
    )



-- VIEW


view : Model -> Html.Html Msg
view model =
    div []
        [ case model.result of
            RemoteData.NotAsked ->
                div [] []

            RemoteData.Loading ->
                div [] [ text "Submitting..." ]

            RemoteData.Failure _ ->
                div [] [ text "Something went wrong..." ]

            RemoteData.Success _ ->
                div [] [ text "Success! Redirecting..." ]
        , input [ onInput NewUserFormNameChanged, placeholder "name" ] []
        , input [ onInput NewUserFormEmailChanged, placeholder "email" ] []
        , input [ onInput NewUserFormPasswordChanged, placeholder "password" ] []
        , button [ onClick NewUserFormSubmitted ] [ text "Go!" ]
        , div [] []
        ]



-- UPDATE


type Msg
    = UserCreated (RemoteData (Graphql.Http.Error User) User)
    | NewUserFormNameChanged String
    | NewUserFormPasswordChanged String
    | NewUserFormEmailChanged String
    | NewUserFormSubmitted


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UserCreated (RemoteData.Success user) ->
            ( { model | result = RemoteData.Success user }, model.onSuccess user )

        UserCreated result ->
            ( { model | result = result }, Cmd.none )

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


mutation : { name : String, email : String, password : String } -> SelectionSet User RootMutation
mutation { name, email, password } =
    let
        args =
            Mutation.CreateUserRequiredArguments
                name
                email
                password
    in
    Mutation.createUser args usersSelection


usersSelection : SelectionSet User GQLTypes.User
usersSelection =
    SelectionSet.map4 User
        UserFields.id
        UserFields.name
        UserFields.email
        UserFields.password


createUser : { name : String, email : String, password : String } -> Cmd Msg
createUser args =
    mutation args
        |> mutationRequest (unwrap graphQLUrl)
        |> send (RemoteData.fromResult >> UserCreated)
