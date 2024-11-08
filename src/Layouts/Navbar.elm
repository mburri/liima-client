module Layouts.Navbar exposing (Model, Msg, Props, layout)

import Effect exposing (Effect)
import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Layout exposing (Layout)
import Route exposing (Route)
import Route.Path exposing (Path)
import Shared
import View exposing (View)


type alias Props =
    {}


layout : Props -> Shared.Model -> Route () -> Layout () Model Msg contentMsg
layout props shared route =
    Layout.new
        { init = init
        , update = update
        , view = view route
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


view : Route () -> { toContentMsg : Msg -> contentMsg, content : View contentMsg, model : Model } -> View contentMsg
view route { toContentMsg, model, content } =
    { title = content.title
    , attributes = []
    , element =
        column [ width fill, height fill ]
            [ row
                [ width fill
                , Background.color (rgb255 0 0 0)
                ]
                [ row
                    [ spacing 16
                    , padding 16
                    , alignRight
                    , Font.color (rgba255 255 255 255 0.55)
                    ]
                    [ el [] <| link [] { url = "/apps", label = text "Apps" }
                    , el [] <| link [] { url = "/servers", label = text "Servers" }
                    , el [] <| link [] { url = "/resources", label = text "Resources" }
                    , el [] <| link [] { url = "/deploy", label = text "Deploy" }
                    , el [] <| link [] { url = "/settings", label = text "Settings" }
                    ]
                ]
            , row
                [ width fill
                , paddingXY 16 12
                , Background.color (rgb255 222 222 222)
                ]
                [ el [ Font.bold, Font.size 18 ] <| text (toPageTitle route.path) ]
            , el [ padding 16, width fill, height fill ] <| content.element
            ]
    }


toPageTitle : Path -> String
toPageTitle path =
    case path of
        Route.Path.Home_ ->
            "Home"

        Route.Path.Apps ->
            "Apps"

        Route.Path.Deploy ->
            "Deploy"

        Route.Path.Resources ->
            "Resources"

        Route.Path.Servers ->
            "Servers"

        Route.Path.Settings ->
            "Settings"

        Route.Path.NotFound_ ->
            "Not Found"
