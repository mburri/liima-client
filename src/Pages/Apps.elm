module Pages.Apps exposing (Model, Msg, page)

import Api
import Api.ApplicationServer exposing (ApplicationServer)
import Api.Endpoint
import Api.Http exposing (Method(..))
import Effect exposing (Effect)
import Element
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


type alias Model =
    { applicationServers : Api.Data (List ApplicationServer)
    }


init : () -> ( Model, Effect Msg )
init () =
    ( { applicationServers = Api.Loading }
    , Effect.sendApiRequest
        { method = GET
        , decoder = Api.ApplicationServer.decoder
        , endpoint = Api.Endpoint.applicationServers "1"
        , onResponse = GotApplicationServerResponse
        }
    )



-- UPDATE


type Msg
    = GotApplicationServerResponse (Result Http.Error (List ApplicationServer))


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        GotApplicationServerResponse (Ok applicationServers) ->
            ( { model | applicationServers = Api.Success applicationServers }, Effect.none )

        GotApplicationServerResponse (Err error) ->
            ( { model | applicationServers = Api.Failure error }, Effect.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Pages.Apps"
    , attributes = []
    , element = Element.text "/apps"
    }
