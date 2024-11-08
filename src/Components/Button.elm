module Components.Button exposing (view)

import Element exposing (Element, alignRight, paddingXY, text)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Style.Palette


view : String -> Maybe msg -> Element msg
view label msg =
    Input.button
        [ Font.color Style.Palette.grayScale.white
        , Background.color Style.Palette.color.primary
        , Border.rounded 6
        , paddingXY 12 12
        , alignRight
        ]
        { label = text label, onPress = msg }
