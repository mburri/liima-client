module Pages.Apps exposing (Model, Msg, page)

import Api
import Api.ApplicationServer exposing (Application, ApplicationServer)
import Api.Endpoint
import Api.Http exposing (Method(..))
import Api.Release as Release exposing (Release)
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
import Json.Decode
import Layouts
import Page exposing (Page)
import Route exposing (Route)
import SearchBox
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
    { name : String
    , release : Maybe Release
    , releaseText : String
    , releaseSearchBox : SearchBox.State
    }


emptyFilter : Filter
emptyFilter =
    { name = ""
    , release = Nothing
    , releaseText = ""
    , releaseSearchBox = SearchBox.init
    }


type alias Model =
    { applicationServers : Api.Data (List ApplicationServer)
    , releases : Api.Data (List Release)
    , filter : Filter
    }


init : () -> ( Model, Effect Msg )
init () =
    ( { applicationServers = Api.NotAsked
      , filter = emptyFilter
      , releases = Api.Loading
      }
    , Effect.batch
        [ loadReleases
        ]
    )


loadApplicationServers : Filter -> Effect Msg
loadApplicationServers filter =
    case filter.release of
        Just release ->
            Effect.sendApiRequest
                { method = GET
                , decoder = Api.ApplicationServer.decoder
                , endpoint = Api.Endpoint.applicationServers filter.name release
                , onResponse = GotApplicationServerResponse
                }

        Nothing ->
            Effect.none


loadReleases =
    Effect.sendApiRequest
        { method = GET
        , decoder = Json.Decode.list Release.decoder
        , endpoint = Api.Endpoint.releases
        , onResponse = GotReleasesResponse
        }



-- UPDATE


type Msg
    = GotApplicationServerResponse (Result Http.Error (List ApplicationServer))
    | GotReleasesResponse (Result Http.Error (List Release))
    | NameInputChanged String
    | ChangedReleaseSearchBox (SearchBox.ChangeEvent Release)
    | SearchButtonClicked


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        GotApplicationServerResponse (Ok applicationServers) ->
            ( { model | applicationServers = Api.Success applicationServers }, Effect.none )

        GotApplicationServerResponse (Err error) ->
            ( { model | applicationServers = Api.Failure error }, Effect.none )

        GotReleasesResponse (Ok releases) ->
            ( { model | releases = Api.Success releases }, Effect.none )

        GotReleasesResponse (Err error) ->
            ( { model | releases = Api.Failure error }, Effect.none )

        NameInputChanged name ->
            ( { model | filter = withName name model.filter }
            , Effect.none
            )

        ChangedReleaseSearchBox changeEvent ->
            case changeEvent of
                SearchBox.SelectionChanged release ->
                    ( { model | filter = withReleaseSelected (Just release) model.filter }, Effect.none )

                SearchBox.TextChanged releaseText ->
                    ( { model
                        | filter =
                            model.filter
                                |> withReleaseText releaseText
                                |> withResetSearchBox
                                |> withReleaseSelected Nothing
                      }
                    , Effect.none
                    )

                SearchBox.SearchBoxChanged subMsg ->
                    ( { model | filter = withSearchBoxChanged subMsg model.filter }, Effect.none )

        SearchButtonClicked ->
            ( { model | applicationServers = Api.Loading }
            , loadApplicationServers model.filter
            )


withName : String -> Filter -> Filter
withName name filter =
    { filter | name = name }


withReleaseSelected : Maybe Release -> Filter -> Filter
withReleaseSelected release filter =
    { filter | release = release }


withReleaseText : String -> Filter -> Filter
withReleaseText releaseText filter =
    { filter | releaseText = releaseText }


withSearchBoxChanged : SearchBox.Msg -> Filter -> Filter
withSearchBoxChanged msg filter =
    { filter | releaseSearchBox = SearchBox.update msg filter.releaseSearchBox }


withResetSearchBox : Filter -> Filter
withResetSearchBox filter =
    { filter | releaseSearchBox = SearchBox.reset filter.releaseSearchBox }



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
        column
            [ width fill
            , Border.solid
            , Border.roundEach
                { topLeft = Palette.size.s
                , topRight = Palette.size.s
                , bottomRight = 0
                , bottomLeft = 0
                }
            , Border.width 1
            , Border.color Palette.grayScale.dark
            ]
            [ viewTitleBar
            , viewFilter model.releases model.filter
            , viewApplicationServers model.applicationServers
            ]
    }


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
        , Button.view [ alignRight ] { label = text "Add Application Server", onPress = Nothing }
        , Button.view [] { label = text "Add Application", onPress = Nothing }
        ]


viewFilter : Api.Data (List Release) -> Filter -> Element Msg
viewFilter releases filter =
    let
        availableReleases =
            case releases of
                Api.NotAsked ->
                    []

                Api.Loading ->
                    []

                Api.Success value ->
                    value

                Api.Failure error ->
                    []
    in
    column
        [ width fill
        , padding Palette.size.m
        , spacing Palette.size.m
        ]
        [ el [ Font.bold ] <| text "Add Filter"
        , row [ spacing Palette.size.xl, width fill ]
            [ Input.text [ width (fillPortion 3) ]
                { onChange = NameInputChanged
                , text = filter.name
                , label = Input.labelAbove [] <| text "Application/ AS name"
                , placeholder = Nothing
                }
            , SearchBox.input [ width (fillPortion 2) ]
                { onChange = ChangedReleaseSearchBox
                , text = filter.releaseText
                , selected = filter.release
                , options = Just availableReleases
                , label = Input.labelAbove [] <| text "Release"
                , placeholder = Nothing
                , toLabel = \release -> release.name
                , filter =
                    \query release ->
                        release.name
                            |> String.toLower
                            |> String.contains (String.toLower query)
                , state = filter.releaseSearchBox
                }
            , el
                [ width (fillPortion 1)
                , moveDown 8
                ]
              <|
                viewSearchButton filter.release
            ]
        ]


viewSearchButton : Maybe Release -> Element Msg
viewSearchButton maybeRelease =
    case maybeRelease of
        Nothing ->
            Button.disabled
                { label = "Select a release"
                , description = "A release is required before searching application servers is possible."
                }

        Just _ ->
            Button.view [ alignRight ] { label = text "Search", onPress = Just SearchButtonClicked }


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


viewApplicationServers : Api.Data (List ApplicationServer) -> Element Msg
viewApplicationServers data =
    case data of
        Api.NotAsked ->
            Element.none

        Api.Failure error ->
            Error.view error "Error loading application servers"

        Api.Loading ->
            Loading.view

        Api.Success applicationServers ->
            column [ width fill ]
                ([ viewHeader ]
                    ++ List.map viewApplicationServer applicationServers
                )


viewApplicationServer : ApplicationServer -> Element msg
viewApplicationServer applicationServer =
    column [ width fill, paddingXY Palette.size.m Palette.size.s ]
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
