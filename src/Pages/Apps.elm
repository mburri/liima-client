module Pages.Apps exposing (Model, Msg, page)

import Api
import Api.ApplicationServer exposing (Application, ApplicationServer)
import Api.Endpoint
import Api.Http exposing (Method(..))
import Effect exposing (Effect)
import Element exposing (..)
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
        ]
        ([ viewTitleBar
         , viewHeader
         , viewFilter filter
         ]
            ++ List.map viewApplicationServer applicationServers
        )


viewTitleBar : Element Msg
viewTitleBar =
    row [ width fill, spacing 16 ]
        [ el [] <| text "Application Servers and Applications"
        , Input.button [ alignRight ] { label = text "Add Application Server", onPress = Nothing }
        , Input.button [] { label = text "Add Application", onPress = Nothing }
        ]


viewHeader : Element Msg
viewHeader =
    row [ width fill ]
        [ el [] <| text "App Name"
        , el [ alignRight ] <| text "Release"
        ]


viewFilter : Filter -> Element Msg
viewFilter filter =
    column [ width fill ]
        [ el [] <| text "Add Filter"
        , row [ width fill ]
            [ Input.text []
                { onChange = InputChanged NameInput
                , text = filter.name
                , label = Input.labelAbove [] <| text "Application/ AS name"
                , placeholder = Nothing
                }
            , Input.text []
                { onChange = InputChanged ReleaseInput
                , text = filter.release
                , label = Input.labelAbove [] <| text "Release"
                , placeholder = Nothing
                }
            , Input.button [] { onPress = Nothing, label = text "Search" }
            ]
        ]


viewApplicationServer : ApplicationServer -> Element msg
viewApplicationServer applicationServer =
    column [ width fill ]
        ([ row [ width fill ]
            [ el [] <| text applicationServer.name
            , el [ alignRight ] <| text applicationServer.release.name
            ]
         ]
            ++ List.map viewApplication applicationServer.apps
        )


viewApplication : Application -> Element msg
viewApplication application =
    row [ width fill, paddingEach { top = 0, bottom = 0, left = 16, right = 0 } ]
        [ el [] <| text application.name
        , el [ alignRight ] <| text application.release.name
        ]
