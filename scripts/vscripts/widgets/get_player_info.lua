---------------------------------------------------------------------------
-- Gets a list of playerIDs on a team
---------------------------------------------------------------------------
function GetPlayersOnTeam(teamNumber)
    local players = {}
    for playerID=0,DOTA_MAX_TEAM_PLAYERS do
        if PlayerResource:GetTeam(playerID) == teamNumber then
            table.insert(players, playerID)
        end
    end
    return players
end

---------------------------------------------------------------------------
-- Gets the order of the player on a team
---------------------------------------------------------------------------
function GetPlayerAllyNumber(playerID)
    local players = GetPlayersOnTeam(PlayerResource:GetTeam(playerID))
    for k,pID in pairs(players) do
        if pID == playerID then
            return k
        end
    end
    return -1 --no team
end