module Shared exposing
    ( Flags, decoder
    , Model, Msg
    , init, update, subscriptions
    )

{-|

@docs Flags, decoder
@docs Model, Msg
@docs init, update, subscriptions

-}

import Api
import Api.Endpoint
import Api.Http
import Api.Permission
import Effect exposing (Effect)
import Json.Decode
import Route exposing (Route)
import Shared.Model
import Shared.Msg



-- FLAGS


type alias Flags =
    {}


decoder : Json.Decode.Decoder Flags
decoder =
    Json.Decode.succeed {}



-- INIT


type alias Model =
    Shared.Model.Model


init : Result Json.Decode.Error Flags -> Route () -> ( Model, Effect Msg )
init flagsResult route =
    ( { permissions = Api.Loading }
    , Effect.sendApiRequest
        { method = Api.Http.GET
        , endpoint = Api.Endpoint.ownPermissions
        , decoder = Api.Permission.decoder
        , onResponse = Shared.Msg.PermissionsRestResponded
        }
    )


type alias Msg =
    Shared.Msg.Msg


update : Route () -> Msg -> Model -> ( Model, Effect Msg )
update route msg model =
    case msg of
        Shared.Msg.PermissionsRestResponded (Ok permissions) ->
            ( { model | permissions = Api.Success permissions }, Effect.none )

        Shared.Msg.PermissionsRestResponded (Err error) ->
            ( { model | permissions = Api.Failure error }, Effect.none )



-- SUBSCRIPTIONS


subscriptions : Route () -> Model -> Sub Msg
subscriptions route model =
    Sub.none
