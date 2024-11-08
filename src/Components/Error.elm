module Components.Error exposing (view)

import Element exposing (Element, centerX, el, padding, text)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Http
import Style.Palette


view : Http.Error -> String -> Element msg
view error message =
    el
        [ Font.size Style.Palette.fontSize.large
        , Font.color Style.Palette.grayScale.black
        , padding Style.Palette.size.m
        , centerX
        , Background.color Style.Palette.color.warning
        , Border.rounded Style.Palette.size.s
        ]
    <|
        text message
