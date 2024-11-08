module Layouts.Navbar exposing (Model, Msg, Props, layout)

import Effect exposing (Effect)
import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Layout exposing (Layout)
import Route exposing (Route)
import Route.Path exposing (Path)
import Shared
import Style.Palette
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
                , Background.color Style.Palette.grayScale.black
                ]
                [ row
                    [ spacing Style.Palette.size.l
                    , padding Style.Palette.size.m
                    , alignRight
                    , Font.color Style.Palette.grayScale.light
                    ]
                    [ link [] { url = "/apps", label = text "Apps" }
                    , link [] { url = "/servers", label = text "Servers" }
                    , link [] { url = "/resources", label = text "Resources" }
                    , link [] { url = "/deploy", label = text "Deploy" }
                    , link [] { url = "/settings", label = text "Settings" }
                    ]
                ]
            , row
                [ width fill
                , padding Style.Palette.size.m
                , Background.color Style.Palette.grayScale.light
                ]
                [ el [ Font.bold, Font.size Style.Palette.fontSize.large ] <| text (toPageTitle route.path) ]
            , el
                [ width fill
                , height fill
                , padding Style.Palette.size.m
                ]
              <|
                content.element
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
