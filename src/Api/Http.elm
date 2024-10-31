module Api.Http exposing (Method(..), stringOf)


type Method
    = GET
    | POST
    | PUT
    | DELETE


stringOf : Method -> String
stringOf method =
    case method of
        GET ->
            "GET"

        POST ->
            "POST"

        PUT ->
            "PUT"

        DELETE ->
            "DELETE"
