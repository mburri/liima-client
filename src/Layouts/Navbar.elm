module Layouts.Navbar exposing (Model, Msg, Props, layout)

import Effect exposing (Effect)
import Element exposing (..)
import Layout exposing (Layout)
import Route exposing (Route)
import Shared
import View exposing (View)


type alias Props =
    {}


layout : Props -> Shared.Model -> Route () -> Layout () Model Msg contentMsg
layout props shared route =
    Layout.new
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    {}


init : () -> ( Model, Effect Msg )
init _ =
    ( {}
    , Effect.none
    )



-- UPDATE


type Msg
    = ReplaceMe


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ReplaceMe ->
            ( model
            , Effect.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : { toContentMsg : Msg -> contentMsg, content : View contentMsg, model : Model } -> View contentMsg
view { toContentMsg, model, content } =
    { title = content.title
    , attributes = []
    , element =
        column []
            [ row []
                [ el [] <| text "Apps"
                , el [] <| text "Servers"
                , el [] <| text "Resources"
                , el [] <| text "Deploy"
                , el [] <| text "Settings"
                ]
            , content.element
            ]
    }
