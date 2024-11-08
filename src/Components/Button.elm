module Components.Button exposing (disabled, view)

import Element exposing (Element, alignRight, htmlAttribute, padding, paddingXY, pointer, text)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input exposing (Label)
import Element.Region as Region
import Html.Attributes
import Style.Palette as Palette


view : List (Element.Attribute msg) -> { label : Element msg, onPress : Maybe msg } -> Element msg
view attrs =
    Input.button
        ([ Font.color Palette.grayScale.white
         , Background.color Palette.color.primary
         , Border.rounded Palette.size.s
         , paddingXY Palette.size.m Palette.size.s
         ]
            ++ attrs
        )


disabled : { label : String, description : String } -> Element msg
disabled { label, description } =
    Input.button
        [ Font.color Palette.color.primarySubtle
        , Background.color Palette.grayScale.white
        , Border.color Palette.color.primarySubtle
        , Border.rounded Palette.size.s
        , Border.solid
        , Border.width 1
        , htmlAttribute (Html.Attributes.style "cursor" "not-allowed")
        , paddingXY Palette.size.m Palette.size.s
        , Region.description description
        ]
        { label = text label, onPress = Nothing }
