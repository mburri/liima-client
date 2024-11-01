module Api.Endpoint exposing (applicationServers, ownPermissions)


ownPermissions : String
ownPermissions =
    "/AMW_rest/resources/permissions/restrictions/ownRestrictions/"


applicationServers : String -> String
applicationServers releaseId =
    "/AMW_rest/resources/apps?releaseId=" ++ releaseId
