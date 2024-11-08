module Pages.Apps exposing (Model, Msg, page)

import Api
import Api.ApplicationServer exposing (Application, ApplicationServer)
import Api.Endpoint
import Api.Http exposing (Method(..))
import Effect exposing (Effect)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Http
import Layouts
import Page exposing (Page)
import Route exposing (Route)
import Shared
import View exposing (View)


page : Shared.Model -> Route () -> Page Model Msg
page shared route =
    Page.new
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
        |> Page.withLayout toLayout


toLayout : Model -> Layouts.Layout Msg
toLayout _ =
    Layouts.Navbar {}



-- INIT


type alias Filter =
    { name : String, release : String }


emptyFilter : Filter
emptyFilter =
    { name = "", release = "" }


type alias Model =
    { applicationServers : Api.Data (List ApplicationServer)
    , filter : Filter
    }


init : () -> ( Model, Effect Msg )
init () =
    ( { applicationServers = Api.Loading, filter = emptyFilter }
    , Effect.sendApiRequest
        { method = GET
        , decoder = Api.ApplicationServer.decoder
        , endpoint = Api.Endpoint.applicationServers "1" -- TODO: get a valid release
        , onResponse = GotApplicationServerResponse
        }
    )



-- UPDATE


type FilterInputField
    = NameInput
    | ReleaseInput


type Msg
    = GotApplicationServerResponse (Result Http.Error (List ApplicationServer))
    | InputChanged FilterInputField String


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        GotApplicationServerResponse (Ok applicationServers) ->
            ( { model | applicationServers = Api.Success applicationServers }, Effect.none )

        GotApplicationServerResponse (Err error) ->
            ( { model | applicationServers = Api.Failure error }, Effect.none )

        InputChanged filterInputField input ->
            case filterInputField of
                NameInput ->
                    ( { model | filter = { name = input, release = model.filter.release } }
                    , Effect.none
                    )

                ReleaseInput ->
                    ( { model | filter = { name = model.filter.name, release = input } }
                    , Effect.none
                    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Liima - Application servers and applications"
    , attributes = []
    , element =
        case model.applicationServers of
            Api.Failure error ->
                viewError error

            Api.Loading ->
                viewLoading

            Api.Success applicationServers ->
                viewApplicationServers applicationServers model.filter
    }


viewError : Http.Error -> Element msg
viewError error =
    el [] <| text "Error loading application servers"


viewLoading : Element msg
viewLoading =
    el [] <| text "loading data..."


viewApplicationServers : List ApplicationServer -> Filter -> Element Msg
viewApplicationServers applicationServers filter =
    column
        [ width fill
        , Border.solid
        , Border.rounded 5
        , Border.width 1
        , Border.color (rgb255 152 153 152)
        ]
        ([ viewTitleBar
         , viewFilter filter
         , viewHeader
         ]
            ++ List.map viewApplicationServer applicationServers
        )


viewTitleBar : Element Msg
viewTitleBar =
    row
        [ width fill
        , spacing 16
        , Background.color (rgb255 233 233 233)
        , Border.roundEach { bottomLeft = 0, bottomRight = 0, topLeft = 5, topRight = 5 }
        , Border.widthEach { right = 0, top = 0, left = 0, bottom = 1 }
        , Border.color (rgb255 152 153 152)
        , paddingXY 12 6
        ]
        [ el [ Font.bold ] <| text "Application Servers and Applications"
        , viewButton "Add Application Server" Nothing
        , viewButton "Add Application" Nothing
        ]


viewButton : String -> Maybe msg -> Element msg
viewButton label msg =
    Input.button
        [ Font.color (rgb255 255 255 255)
        , Background.color (rgb255 13 110 253)
        , Border.rounded 6
        , paddingXY 12 12
        , alignRight
        ]
        { label = text label, onPress = msg }


viewFilter : Filter -> Element Msg
viewFilter filter =
    column [ width fill, paddingXY 12 12, spacing 12 ]
        [ el [ Font.bold ] <| text "Add Filter"
        , row [ spacing 24, width fill ]
            [ Input.text [ width (fillPortion 3) ]
                { onChange = InputChanged NameInput
                , text = filter.name
                , label = Input.labelAbove [] <| text "Application/ AS name"
                , placeholder = Nothing
                }
            , Input.text [ width (fillPortion 2) ]
                { onChange = InputChanged ReleaseInput
                , text = filter.release
                , label = Input.labelAbove [] <| text "Release"
                , placeholder = Nothing
                }
            , el
                [ width (fillPortion 1)
                , alignBottom
                , paddingXY 0 2
                ]
              <|
                viewButton "Search" Nothing
            ]
        ]


viewHeader : Element Msg
viewHeader =
    row
        [ width fill
        , Background.color (rgb255 233 233 233)
        , paddingXY 12 12
        , Border.widthEach { top = 1, bottom = 1, left = 0, right = 0 }
        , Border.color (rgb255 211 211 211)
        ]
        [ el [ Font.bold, width (fillPortion 4) ] <| text "App Name"
        , el [ Font.bold, width (fillPortion 1) ] <| text "Release"
        ]


viewApplicationServer : ApplicationServer -> Element msg
viewApplicationServer applicationServer =
    column [ width fill, paddingXY 12 6 ]
        ([ row [ width fill, paddingXY 0 6 ]
            [ el [ Font.bold, width (fillPortion 4) ] <| text (applicationServer.name ++ " [ " ++ applicationServer.runtime ++ " ] ")
            , el [ alignRight, width (fillPortion 1) ] <| text applicationServer.release.name
            ]
         ]
            ++ List.map viewApplication applicationServer.apps
        )


viewApplication : Application -> Element msg
viewApplication application =
    row [ width fill ]
        [ el [ width (fillPortion 4) ] <| text application.name
        , el [ alignRight, width (fillPortion 1) ] <| text application.release.name
        ]
