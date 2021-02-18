DeveloperTools = DeveloperTools or class({})

function DeveloperTools:Init()
    ListenToGameEvent( "player_chat", Dynamic_Wrap( DeveloperTools, "OnPlayerChat" ), self )
end

function DeveloperTools:OnPlayerChat(keys)
	local text = keys.text
    local playerid = keys.playerid
    
    if not IsAdmin(playerid) then return end
	if string.sub(text, 1, 1) ~= "-" then return end

	local player = PlayerResource:GetPlayer(keys.playerid)

	local args = {}

	for i in string.gmatch(text, "%S+") do -- split string
		table.insert(args, i)
	end

	local command = args[1]
	table.remove(args, 1)

    local fixed_command = command.sub(command, 2)

    if DeveloperTools[fixed_command] then
		DeveloperTools[fixed_command](DeveloperTools, player, args)
	end
end

function DeveloperTools:ToggleFastBuild(player, data)
    BuildingHelper:WarpTen()
    print('Fast Build ', GameRules.WarpTen)
end

function DeveloperTools:ModifyGold(player, data)
    local goldAmount = tonumber(data[1])
    local hero = PlayerResource:GetSelectedHeroEntity(player:GetPlayerID())

    hero:SetGold(tonumber(goldAmount), false)
    print('Gold set to ', goldAmount)    
end

function DeveloperTools:ModifyLumber(player, data)
    local lumberAmount = tonumber(data[1])
    local hero = PlayerResource:GetSelectedHeroEntity(player:GetPlayerID())

    ModifyLumber(hero, tonumber(lumberAmount))
    print('Lumber set to ', lumberAmount)
end

function DeveloperTools:PowerOverwhelming(player, data)
    local amount = {}
    amount[1] = "50000"
    DeveloperTools:ToggleFastBuild(player, data)
    DeveloperTools:ModifyGold(player, amount)
    DeveloperTools:ModifyLumber(player, amount)
end

function DeveloperTools:SendTestData(player, data)
    local winnerTeam = tonumber(data[1])
    WebApi:AfterMatch(tonumber(winnerTeam))
end

function DeveloperTools:GetLeaderBoard(player, data)
    WebApi:GetLeaderBoard()
end

local admin_ids = {
    [46639111] = 1, -- (cows)
    [72355671]  = 1, -- (xiao)
    [103245869] = 1, -- (iRest)
}

function IsAdmin(playerId)
    local cmdPlayer = Convars:GetCommandClient()
    local playerId = playerId or cmdPlayer:GetPlayerID()
    local steam_account_id = PlayerResource:GetSteamAccountID(playerId)
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

DeveloperTools:Init()