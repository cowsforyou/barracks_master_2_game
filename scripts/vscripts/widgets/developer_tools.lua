DeveloperTools = DeveloperTools or class({})

local admin_ids = {
    [46639111] = 1, -- (cows)
    [72355671]  = 1, -- (xiao)
}

function IsAdmin()
    local cmdPlayer = Convars:GetCommandClient()
    local steam_account_id = PlayerResource:GetSteamAccountID(cmdPlayer:GetPlayerID())
    return (admin_ids[steam_account_id] == 1)
end

Convars:RegisterCommand("toggle_fast_build", function(name, _)
    if not IsAdmin() then return end

    BuildingHelper:WarpTen()
    print('Fast Build ', GameRules.WarpTen)
end, "Toggle Fast Build", FCVAR_CHEAT)

Convars:RegisterCommand("modify_gold", function(name, goldAmount)
    if not IsAdmin() then return end

    local cmdPlayer = Convars:GetCommandClient()
    local hero = PlayerResource:GetSelectedHeroEntity(cmdPlayer:GetPlayerID())

    hero:SetGold(tonumber(goldAmount), false)
    print('Gold set to ', goldAmount)    
end, "Set Gold Amount", FCVAR_CHEAT)

Convars:RegisterCommand("modify_lumber", function(name, lumberAmount)
    if not IsAdmin() then return end

    local cmdPlayer = Convars:GetCommandClient()
    local hero = PlayerResource:GetSelectedHeroEntity(cmdPlayer:GetPlayerID())

    ModifyLumber(hero, tonumber(lumberAmount))
    print('Lumber set to ', lumberAmount)    
end, "Set Lumber Amount", FCVAR_CHEAT)

Convars:RegisterCommand("test_send_match_data", function(name, winnerTeam)
    if not IsAdmin() then return end

    WebApi:AfterMatch(tonumber(winnerTeam))
end, "Send Sample Match Data", FCVAR_CHEAT)