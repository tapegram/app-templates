module Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Html exposing (Html, a, footer, h1, li, nav, text, ul)
import Html.Attributes exposing (classList, href)
import Html.Events exposing (onMouseOver)
import Html.Lazy exposing (lazy)
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, s, string)
import Users



-- MODEL


type alias Model =
    { -- Storing the current page value in the Model so that view can render things different depending on the current page state
      page : Page

    -- this basically exists exclusively to be used with Nav.pushUrl
    -- this is an implementation detail to make it impossible to use Nav.pushUrl without Browser.application, since thats the only way to get a key.
    , key : Nav.Key
    }


type alias UserId =
    String


type Page
    = UsersPage Users.Model
    | CreateUserPage
    | UserDetailPage
    | NotFoundPage


type Route
    = Users
    | CreateUser
    | UserDetails UserId



-- VIEW


view : Model -> Document Msg
view model =
    let
        content =
            case model.page of
                UsersPage m ->
                    Users.view m |> Html.map GotUsersMsg

                CreateUserPage ->
                    Debug.todo "branch 'CreateUserPage' not implemented"

                UserDetailPage ->
                    Debug.todo "branch 'UserDetailPage' not implemented"

                NotFoundPage ->
                    Debug.todo "branch 'NotFoundPage' not implemented"
    in
    { -- The title of page in the browser
      title = "Template App, SPA Style"

    -- Notice that body is a list
    , body =
        [ lazy viewHeader model.page
        , content
        , viewFooter
        ]
    }


viewFooter : Html msg
viewFooter =
    footer [] [ text "One is never alone with a rubber duck. - Douglas Adams" ]


viewHeader : Page -> Html Msg
viewHeader page =
    let
        logo =
            h1 [] [ text "Template Users App" ]

        links =
            ul []
                [ navLink Users { url = "/users", caption = "Users" }
                , navLink CreateUser { url = "/users/create", caption = "Create User" }
                ]

        navLink : Route -> { url : String, caption : String } -> Html msg
        navLink route { url, caption } =
            li
                [ classList
                    [ ( "active"
                      , isActive
                            { link = route
                            , page = page
                            }
                      )
                    ]
                ]
                [ a [ href url ] [ text caption ] ]
    in
    nav [] [ logo, links ]


isActive : { link : Route, page : Page } -> Bool
isActive { link, page } =
    case ( link, page ) of
        ( Users, UsersPage _) ->
            True

        ( Users, _ ) ->
            False

        ( CreateUser, CreateUserPage ) ->
            True

        ( CreateUser, _ ) ->
            False

        ( UserDetails _, UserDetailPage ) -> True
        ( UserDetails _, _ ) -> False



-- MESSAGE


type Msg
    = ClickedLink Browser.UrlRequest
    | ChangedUrl Url
    | GotUsersMsg Users.Msg



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedLink urlRequest ->
            case urlRequest of
                -- Handle clicking a link to some other domain (website.com -> othersite.com)
                -- Nav.load does a full page load
                Browser.External href ->
                    ( model, Nav.load href )

                -- Handle clicking a link to the same domain (website.com/foo -> website.com/bar)
                -- Nav.pushUrl just pushes onto the browser's history stack (without reloading)
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

        ChangedUrl url ->
            -- This would be the place where we could also choose to implement fancy transitions/etc.
            ( { model | page = urlToPage url }, Cmd.none )
            
        GotUsersMsg usersMsg -> Users.update usersMsg



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



--
-- MAIN


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , onUrlRequest = ClickedLink
        , onUrlChange = ChangedUrl
        , subscriptions = subscriptions
        , update = update
        , view = view
        }


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( { page = urlToPage url, key = key }, Cmd.none )


urlToPage : Url -> Page
urlToPage url =
    case Parser.parse parser url of
        Just Users ->
            UsersPage (Tuple.first (Users.init ()))

        Just CreateUser ->
            CreateUserPage

        Just (UserDetails _) ->
            UserDetailPage

        Nothing ->
            NotFoundPage


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ -- Match on / and returns Users page
          Parser.map Users
            Parser.top

        -- Match on /users and returns Users page
        , Parser.map
            Users
            (s "users")

        -- Match on /users/create and return CreateUser
        , Parser.map CreateUser (s "users" </> s "create")

        -- Match on /users/<id> and return UserDetail
        , Parser.map UserDetails (s "users" </> Parser.string)
        ]
