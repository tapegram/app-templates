module Page.Users exposing (Model, Msg, init, update, view)

import API exposing (User)
import Endpoint exposing (graphQLUrl, unwrap)
import Graphql.Http exposing (queryRequest, send)
import Graphql.Operation exposing (RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Html.Styled as Html exposing (div, table, td, text, th, thead, tr)
import Html.Styled.Events exposing (onClick)
import RemoteData exposing (RemoteData)
import String exposing (fromInt)
import UsersApi.Object as GQLTypes
import UsersApi.Object.User as UserFields
import UsersApi.Query as Query



-- MODEL


type alias UserId =
    String


type alias OnUserClick =
    UserId -> Cmd Msg


type alias Model =
    { onUserClick : OnUserClick
    , users : RemoteData (Graphql.Http.Error Response) Response
    }


type State
    = Loading
    | Failed
    | Loaded
        { users : List User
        }


init : OnUserClick -> ( Model, Cmd Msg )
init onUserClick =
    ( { onUserClick = onUserClick, users = RemoteData.Loading }
    , getUsers
    )



-- VIEW


view : Model -> Html.Html Msg
view model =
    case model.users of
        RemoteData.Loading ->
            div [] [ text "Loading..." ]

        RemoteData.NotAsked ->
            div [] [ text "Not asked..." ]

        RemoteData.Failure _ ->
            div [] [ text "Failed to load users" ]

        RemoteData.Success users ->
            div []
                [ viewUsers users ]


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
        [ td [ onClick (UserClicked userId) ] [ text userId ]
        , td [] [ text user.name ]
        , td [] [ text user.email ]
        , td [] [ text user.password ]
        ]



-- UPDATE


type Msg
    = -- Http results
      GotUsers (RemoteData (Graphql.Http.Error Response) Response)
    | UserClicked UserId


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotUsers result ->
            ( { model | users = result }, Cmd.none )

        UserClicked userId ->
            ( model, model.onUserClick userId )

-- GraphQL

type alias Response =
    List User


query : SelectionSet Response RootQuery
query =
    Query.users usersSelection


getUsers : Cmd Msg
getUsers =
    query
        |> queryRequest (unwrap graphQLUrl)
        |> send (RemoteData.fromResult >> GotUsers)


usersSelection : SelectionSet User GQLTypes.User
usersSelection =
    SelectionSet.map4 User
        UserFields.id
        UserFields.name
        UserFields.email
        UserFields.password
