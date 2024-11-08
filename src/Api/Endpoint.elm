module Api.Endpoint exposing (applicationServers, ownPermissions, releases)


ownPermissions : String
ownPermissions =
    "/AMW_rest/resources/permissions/restrictions/ownRestrictions/"


applicationServers : String -> String
applicationServers releaseId =
    "/AMW_rest/resources/apps?releaseId=" ++ releaseId


releases : String
releases =
    "/AMW_rest/resources/releases"
