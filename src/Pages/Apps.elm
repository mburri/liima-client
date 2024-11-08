module Pages.Apps exposing (Model, Msg, page)

import Api
import Api.ApplicationServer exposing (Application, ApplicationServer)
import Api.Endpoint
import Api.Http exposing (Method(..))
import Components.Button as Button
import Components.Error as Error
import Components.Loading as Loading
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
import Style.Palette as Palette
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
                Error.view error "Error loading application servers"

            Api.Loading ->
                Loading.view

            Api.Success applicationServers ->
                viewApplicationServers applicationServers model.filter
    }


viewApplicationServers : List ApplicationServer -> Filter -> Element Msg
viewApplicationServers applicationServers filter =
    column
        [ width fill
        , Border.solid
        , Border.rounded Palette.size.s
        , Border.width 1
        , Border.color Palette.grayScale.dark
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
        , Background.color Palette.grayScale.light
        , Border.roundEach { bottomLeft = 0, bottomRight = 0, topLeft = Palette.size.s, topRight = Palette.size.s }
        , Border.widthEach { right = 0, top = 0, left = 0, bottom = 1 }
        , Border.color Palette.grayScale.dark
        , padding Palette.size.m
        ]
        [ el [ Font.bold ] <| text "Application Servers and Applications"
        , Button.view "Add Application Server" Nothing
        , Button.view "Add Application" Nothing
        ]


viewFilter : Filter -> Element Msg
viewFilter filter =
    column
        [ width fill
        , padding Palette.size.m
        , spacing Palette.size.m
        ]
        [ el [ Font.bold ] <| text "Add Filter"
        , row [ spacing Palette.size.xl, width fill ]
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
                , moveUp 2.0 -- TODO: would be nice to get rid of this
                ]
              <|
                Button.view "Search" Nothing
            ]
        ]


viewHeader : Element Msg
viewHeader =
    row
        [ width fill
        , Background.color Palette.grayScale.light
        , padding Palette.size.m
        , Border.widthEach { top = 1, bottom = 1, left = 0, right = 0 }
        , Border.color Palette.grayScale.dark
        ]
        [ el [ Font.bold, width (fillPortion 4) ] <| text "App Name"
        , el [ Font.bold, width (fillPortion 1) ] <| text "Release"
        ]


viewApplicationServer : ApplicationServer -> Element msg
viewApplicationServer applicationServer =
    column [ width fill, padding Palette.size.m ]
        ([ row [ width fill ]
            [ el
                [ Font.bold
                , width (fillPortion 4)
                ]
              <|
                text (applicationServer.name ++ " [ " ++ applicationServer.runtime ++ " ] ")
            , el
                [ alignRight
                , width (fillPortion 1)
                ]
              <|
                text applicationServer.release.name
            ]
         ]
            ++ List.map viewApplication applicationServer.apps
        )


viewApplication : Application -> Element msg
viewApplication application =
    row [ width fill, paddingXY 0 Palette.size.s ]
        [ el [ width (fillPortion 4) ] <| text application.name
        , el [ alignRight, width (fillPortion 1) ] <| text application.release.name
        ]
