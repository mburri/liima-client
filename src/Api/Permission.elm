module Api.Permission exposing (Permission, decoder)

import Json.Decode


type alias Permission =
    { name : String
    , old : Bool
    }


decoder : Json.Decode.Decoder (List Permission)
decoder =
    Json.Decode.list permissionDecoder


permissionDecoder : Json.Decode.Decoder Permission
permissionDecoder =
    Json.Decode.map2 Permission
        (Json.Decode.at [ "permission", "name" ] Json.Decode.string)
        (Json.Decode.at [ "permission", "old" ] Json.Decode.bool)
