module Api.Endpoint exposing (applicationServers, ownPermissions, releases)

import Api.Release exposing (Release)


ownPermissions : String
ownPermissions =
    "/AMW_rest/resources/permissions/restrictions/ownRestrictions/"


applicationServers : String -> Release -> String
applicationServers name release =
    let
        nameQuery =
            case name of
                "" ->
                    ""

                _ ->
                    "appServerName=" ++ name

        releaseQuery =
            "releaseId=" ++ String.fromInt release.id
    in
    "/AMW_rest/resources/apps?" ++ String.join "&" [ releaseQuery, nameQuery ]


releases : String
releases =
    "/AMW_rest/resources/releases"
