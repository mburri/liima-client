module Components.Loading exposing (view)

import Element exposing (Element, el, text)


view : Element msg
view =
    el [] <| text "loading data..."
