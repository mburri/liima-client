module Pages.Home_ exposing (Model, Msg, page)

import Api
import Api.Permission exposing (Permission)
import Html exposing (Html)
import Http
import Page exposing (Page)
import View exposing (View)



-- PAGE


page : Page Model Msg
page =
    Page.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- INIT


type alias Model =
    { permissions : Api.Data (List Permission) }


init : ( Model, Cmd Msg )
init =
    ( { permissions = Api.Loading }
    , Api.Permission.load
        { onResponse = PermissionsRestResponded
        }
    )



-- UPDATE


type Msg
    = PermissionsRestResponded (Result Http.Error (List Permission))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PermissionsRestResponded (Ok permissions) ->
            ( { model | permissions = Api.Success permissions }, Cmd.none )

        PermissionsRestResponded (Err error) ->
            ( { model | permissions = Api.Failure error }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Pages.Home_"
    , body =
        case model.permissions of
            Api.Loading ->
                [ Html.text "Loading..." ]

            Api.Success value ->
                [ Html.text "Got some Permissions" ]

            Api.Failure error ->
                let
                    _ =
                        Debug.log "failed to load restrictions" (Debug.toString error)
                in
                [ Html.text "Failed to load permissions" ]
    }
