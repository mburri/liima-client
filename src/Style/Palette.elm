module Style.Palette exposing (color, fontSize, grayScale, size)

import Element exposing (Color, rgb255, rgba255)


fontSize : { medium : Int, large : Int }
fontSize =
    { medium = 16
    , large = 24
    }


color : { primary : Color, primarySubtle : Color, warning : Color }
color =
    { primary = rgb255 13 110 253
    , primarySubtle = rgba255 13 110 253 0.6
    , warning = rgb255 255 193 7
    }


grayScale : { white : Color, light : Color, dark : Color, black : Color }
grayScale =
    { white = rgb255 255 255 255
    , light = rgb255 223 223 223
    , dark = rgb255 155 155 155
    , black = rgb255 0 0 0
    }


size : { xxs : Int, xs : Int, s : Int, m : Int, l : Int, xl : Int, xxl : Int }
size =
    { xxs = 2
    , xs = 4
    , s = 8
    , m = 16
    , l = 32
    , xl = 64
    , xxl = 128
    }
