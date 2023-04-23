module Endpoint exposing (..)


type alias Url =
    String


type Endpoint
    = Endpoint Url


unwrap : Endpoint -> String
unwrap (Endpoint url) =
    url

graphQLUrl : Endpoint
graphQLUrl =
    Endpoint "http://localhost:3000/"
