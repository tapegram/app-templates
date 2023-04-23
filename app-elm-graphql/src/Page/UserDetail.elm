module Page.UserDetail exposing (Model, Msg, init, update, view)

import API exposing (User, userDecoder)
import Endpoint exposing (graphQLUrl, unwrap)
import Graphql.Http exposing (queryRequest, send)
import Graphql.Operation exposing (RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Html.Styled as Html exposing (div, text)
import RemoteData exposing (RemoteData)
import UsersApi.Object as GQLTypes
import UsersApi.Object.User as UserFields
import UsersApi.Query as Query



-- MODEL


type alias Model =
    { user : RemoteData (Graphql.Http.Error User) User }


type alias UserId =
    Int


init : UserId -> ( Model, Cmd Msg )
init userId =
    ( -- Start in a loading state
    { user = RemoteData.Loading }
    , -- Immediately query the backend for the provided user
      getUser userId
    )



-- VIEW


view : Model -> Html.Html Msg
view model =
    case model.user of
        RemoteData.Loading ->
            div [] [ text "Loading..." ]

        RemoteData.Success user ->
            div []
                [ div [] [ text user.name ]
                , div [] [ text user.email ]
                , div [] [ text user.password ]
                ]

        RemoteData.Failure _ ->
            div [] [ text "Failed to fetch user." ]

        RemoteData.NotAsked ->
            div [] [ text "Preparing to fetch user..." ]



-- UPDATE


type Msg
    = GotUser (RemoteData (Graphql.Http.Error User) User)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotUser result ->
            ( { model | user = result }, Cmd.none )


query : UserId -> SelectionSet User RootQuery
query userId =
    let
        args =
            Query.UserRequiredArguments
                userId
    in
    Query.user args usersSelection


getUser : UserId -> Cmd Msg
getUser userId =
    query userId
        |> queryRequest (unwrap graphQLUrl)
        |> send (RemoteData.fromResult >> GotUser)


usersSelection : SelectionSet User GQLTypes.User
usersSelection =
    SelectionSet.map4 User
        UserFields.id
        UserFields.name
        UserFields.email
        UserFields.password
