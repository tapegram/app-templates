module Main exposing (..)

import Browser
import Debug exposing (log)
import Html exposing (button, div, input, text)
import Html.Events exposing (onClick, onInput)
import String exposing (fromInt, toInt)


add : number -> number -> number
add a b =
    a + b

init : Model
init =
    { score = 0 
    , firstName = "Kindson"
    , lastName = "Munonye"
    , inputValue = 0
    }

type alias Model = {
    score :  Int
    , firstName : String
    , lastName : String
    , inputValue :  Int
    }

view : Model -> Html.Html Messages
view model =
    div []
        [ text (fromInt model.score)
        , div [] []
        , input [onInput TextChanged] []
        , button [ onClick Add] [ text "Add" ]
        ]

type alias Text = String
type alias Key = Int

type Messages
    = Add
    | TextChanged Text
    | KeyPressed Key


update : Messages -> Model -> Model
update msg model =
    let
        logmessage =
            log "here" "Button Clicked"

        logmessage2 =
            log "model" model
    in
        case msg of
            Add ->
                {model | score = model.score + model.inputValue}

            TextChanged newText ->
                let
                    log3 = log "Entered Text" newText
                in
                    { model | inputValue = parseInput newText}
            KeyPressed key ->
                let
                    log4 = log "Key was pressed" key
                in
                    case key of
                        13 -> 
                            { model | score = model.score + model.inputValue}
                        _ -> model


parseInput : String -> Int
parseInput text = 
    case (toInt text) of
        Just val -> val
        Nothing -> 0

main : Program () Model Messages
main =
    Browser.sandbox
        { init = init
        , view = view
        , update = update
        }
