module Api.Release exposing (Release, decoder)

import Json.Decode


type alias Release =
    { id : Int
    , name : String
    }


decoder : Json.Decode.Decoder Release
decoder =
    Json.Decode.map2 Release
        (Json.Decode.field "id" Json.Decode.int)
        (Json.Decode.field "name" Json.Decode.string)
