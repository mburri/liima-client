module Api.ApplicationServer exposing (..)

import Json.Decode


type alias Release =
    { id : Int
    , name : String
    }


type alias Application =
    { id : Int
    , name : String
    , release : Release
    }


type alias ApplicationServer =
    { id : Int
    , name : String
    , runtime : String
    , release : Release
    , apps : List Application
    }


decoder : Json.Decode.Decoder (List ApplicationServer)
decoder =
    Json.Decode.list applicationServerDecoder


applicationServerDecoder : Json.Decode.Decoder ApplicationServer
applicationServerDecoder =
    Json.Decode.map5 ApplicationServer
        (Json.Decode.field "id" Json.Decode.int)
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "runtimeName" Json.Decode.string)
        (Json.Decode.field "release" releaseDecoder)
        (Json.Decode.field "apps" appsDecoder)


releaseDecoder : Json.Decode.Decoder Release
releaseDecoder =
    Json.Decode.map2 Release
        (Json.Decode.field "id" Json.Decode.int)
        (Json.Decode.field "name" Json.Decode.string)


appsDecoder : Json.Decode.Decoder (List Application)
appsDecoder =
    Json.Decode.list appDecoder


appDecoder : Json.Decode.Decoder Application
appDecoder =
    Json.Decode.map3 Application
        (Json.Decode.field "id" Json.Decode.int)
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "release" releaseDecoder)
