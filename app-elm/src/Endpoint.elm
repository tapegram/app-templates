module Endpoint exposing (..)


type alias Url =
    String


type Endpoint
    = Endpoint Url


unwrap : Endpoint -> String
unwrap (Endpoint url) =
    url


getUsersUrl : Endpoint
getUsersUrl =
    Endpoint "http://localhost:3000/users"

createUserUrl : Endpoint
createUserUrl =
    Endpoint "http://localhost:3000/users"
    
type alias UserId = String

getUserUrl : UserId -> Endpoint
getUserUrl userId =
    Endpoint <| String.concat ["http://localhost:3000/users/", userId]
