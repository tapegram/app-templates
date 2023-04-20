module API exposing (..)

import Json.Decode exposing (Decoder, field, int, list, map4, string)

type alias User =
    { id : Int
    , email : String
    , password : String
    , name : String
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
