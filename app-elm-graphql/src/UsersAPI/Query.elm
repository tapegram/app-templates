-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module UsersAPI.Query exposing (..)

import Graphql.Internal.Builder.Argument as Argument exposing (Argument)
import Graphql.Internal.Builder.Object as Object
import Graphql.Internal.Encode as Encode exposing (Value)
import Graphql.Operation exposing (RootMutation, RootQuery, RootSubscription)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet exposing (SelectionSet)
import Json.Decode as Decode exposing (Decoder)
import UsersAPI.InputObject
import UsersAPI.Interface
import UsersAPI.Object
import UsersAPI.Scalar
import UsersAPI.ScalarCodecs
import UsersAPI.Union


users :
    SelectionSet decodesTo UsersAPI.Object.User
    -> SelectionSet (List decodesTo) RootQuery
users object____ =
    Object.selectionForCompositeField "users" [] object____ (Basics.identity >> Decode.list)


type alias UserRequiredArguments =
    { id : Int }


user :
    UserRequiredArguments
    -> SelectionSet decodesTo UsersAPI.Object.User
    -> SelectionSet decodesTo RootQuery
user requiredArgs____ object____ =
    Object.selectionForCompositeField "user" [ Argument.required "id" requiredArgs____.id Encode.int ] object____ Basics.identity
