module Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Css
import Html.Styled as Html exposing (Html, a, div, footer, h1, li, nav, text, toUnstyled, ul)
import Html.Styled.Attributes as Attr exposing (classList, href)
import Page.CreateUser as CreateUser
import Page.NotFound as NotFound
import Page.UserDetail as UserDetail
import Page.Users as Users
import Tailwind.Breakpoints as Breakpoints
import Tailwind.Theme as Tw
import Tailwind.Utilities as Tw
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, s)
import Html.Styled exposing (header)



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
    | CreateUserPage CreateUser.Model
    | UserDetailPage UserDetail.Model
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

                CreateUserPage m ->
                    CreateUser.view m |> Html.map CreateUserMsg

                UserDetailPage m ->
                    UserDetail.view m |> Html.map UserDetailMsg

                NotFoundPage ->
                    NotFound.view
    in
    { -- The title of page in the browser
      title = "Template App, SPA Style"

    -- Notice that body is a list
    , body =
        List.map toUnstyled
            [ div [ Attr.css [ Tw.flex, Tw.flex_col, Tw.h_screen, Tw.justify_between ] ]
                [ -- Mapping all of our "styled" html types to the "unstyled" default that the Elm runtime needs
                  viewHeader model.page
                , div [ Attr.css [ 
                    -- Centering content vertically
                    Tw.mb_auto
                    -- Some padding to get away from the edges
                    , Tw.p_10] ] [ content ]
                , viewFooter
                ]
            ]
    }


viewFooter : Html msg
viewFooter =
    footer [ Attr.css [ Tw.bg_color Tw.gray_100, Tw.h_10 ] ] [ text "The Footer" ]


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
    header [Attr.css [Tw.h_40, Tw.bg_color Tw.gray_100]] [nav [] [ logo, links ]]


isActive : { link : Route, page : Page } -> Bool
isActive { link, page } =
    case ( link, page ) of
        ( Users, UsersPage _ ) ->
            True

        ( Users, _ ) ->
            False

        ( CreateUser, CreateUserPage _ ) ->
            True

        ( CreateUser, _ ) ->
            False

        ( UserDetails _, UserDetailPage _ ) ->
            True

        ( UserDetails _, _ ) ->
            False



-- MESSAGE


type Msg
    = ClickedLink Browser.UrlRequest
    | ChangedUrl Url
    | GotUsersMsg Users.Msg
    | CreateUserMsg CreateUser.Msg
    | UserDetailMsg UserDetail.Msg



-- UPDATE


toUsers : Model -> ( Users.Model, Cmd Users.Msg ) -> ( Model, Cmd Msg )
toUsers model ( userModel, userCmd ) =
    ( { model | page = UsersPage userModel }, Cmd.map GotUsersMsg userCmd )


toCreateUser : Model -> ( CreateUser.Model, Cmd CreateUser.Msg ) -> ( Model, Cmd Msg )
toCreateUser model ( createUserModel, createUserCmd ) =
    ( { model | page = CreateUserPage createUserModel }, Cmd.map CreateUserMsg createUserCmd )


toUserDetail : Model -> ( UserDetail.Model, Cmd UserDetail.Msg ) -> ( Model, Cmd Msg )
toUserDetail model ( createUserModel, createUserCmd ) =
    ( { model | page = UserDetailPage createUserModel }, Cmd.map UserDetailMsg createUserCmd )


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
            updateUrl url model

        GotUsersMsg usersMsg ->
            case model.page of
                UsersPage userModel ->
                    toUsers model (Users.update usersMsg userModel)

                _ ->
                    ( model, Cmd.none )

        CreateUserMsg createUserMsg ->
            case model.page of
                CreateUserPage createUserModel ->
                    toCreateUser model (CreateUser.update createUserMsg createUserModel)

                _ ->
                    ( model, Cmd.none )

        UserDetailMsg userDetailMsg ->
            case model.page of
                UserDetailPage userDetailModel ->
                    toUserDetail model (UserDetail.update userDetailMsg userDetailModel)

                _ ->
                    ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
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


type alias Flags =
    ()



-- Not used for now


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    updateUrl url { page = NotFoundPage, key = key }


updateUrl : Url -> Model -> ( Model, Cmd Msg )
updateUrl url model =
    case Parser.parse parser url of
        Just Users ->
            let
                onUserClick userId =
                    Nav.pushUrl model.key (String.concat [ "/users/", userId ])
            in
            Users.init onUserClick |> toUsers model

        Just CreateUser ->
            let
                onSuccess _ =
                    Nav.pushUrl model.key "/users"
            in
            CreateUser.init onSuccess |> toCreateUser model

        Just (UserDetails userId) ->
            UserDetail.init userId |> toUserDetail model

        _ ->
            ( { model | page = NotFoundPage }, Cmd.none )


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
