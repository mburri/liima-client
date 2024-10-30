module Api.Permission exposing (Permission, load)

import Http
import Json.Decode


type alias Permission =
    { name : String
    , old : Bool
    }


load : { onResponse : Result Http.Error (List Permission) -> msg } -> Cmd msg
load options =
    Http.request
        { method = "GET"
        , headers = [ Http.header "Accept" "application/json" ]
        , url = "/AMW_rest/resources/permissions/restrictions/ownRestrictions/"
        , body = Http.emptyBody
        , expect = Http.expectJson options.onResponse decoder
        , timeout = Nothing
        , tracker = Nothing
        }


decoder : Json.Decode.Decoder (List Permission)
decoder =
    Json.Decode.list permissionDecoder


permissionDecoder : Json.Decode.Decoder Permission
permissionDecoder =
    Json.Decode.map2 Permission
        (Json.Decode.at [ "permission", "name" ] Json.Decode.string)
        (Json.Decode.at [ "permission", "old" ] Json.Decode.bool)
