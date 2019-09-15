--[[
Installation Instructions:

1) On addon_game_mode.lua, add this line of code:
require('widgets/gold_to_unreliable')

2) On gamemode.lua, under "function GameMode:InitGameMode()", add this line of code (this calls the function):
GoldToUnreliable()
]]--

function GoldToUnreliable()
	print("GoldToUnreliable Initialized")
    Timers(function()
    	for playerID=0,DOTA_MAX_TEAM_PLAYERS do
        	if PlayerResource:IsValidPlayer(playerID) then
            	local gold = PlayerResource:GetGold(playerID)
            	PlayerResource:SetGold(playerID, 0, true) --0 reliable
            	PlayerResource:SetGold(playerID, gold, false) --all unreliable
        	end
    	end
        return 1.0 -- the integer represents the duration taken to execute the timer again
  	end)
end
