--[[
Installation Instructions:

1) On addon_game_mode.lua, add this line of code:
require('widgets/alchemist_gifter')

2) On events.lua, under "function GameMode:OnGameRulesStateChange(keys)", add these line of code:
  local newState = GameRules:State_Get()
  if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
    AlchemistGifter:Setup()
  end
]]--

if not AlchemistGifter then
    AlchemistGifter = class({})
end

-- Formula: GIFT_CONSTANT + (CURRENT_MINUTE * GIFT_MULTIPLIER) every GIFT_INTERVAL minutes
GIFT_MULTIPLIER = 19
GIFT_CONSTANT = 120
GIFT_INTERVAL = 3.0 -- minutes

function AlchemistGifter:Setup()
	print("AlchemistGifter Initialized")
	local t = GIFT_INTERVAL * 60

	Timers:CreateTimer(t, function()
		self:GiftAllPlayers()
		return t
	end)
end

-- returns time in seconds until next tick
function AlchemistGifter:GiftAllPlayers()
	local playerCount = PlayerResource:GetPlayerCount()

	local currentMinute = math.floor(GameRules:GetGameTime() / 60)
	local gold = GIFT_CONSTANT + (GIFT_MULTIPLIER * currentMinute)
	--print(string.format("Minute: %s, Gold: %s", currentMinute, gold))

	local dur = 7.0
    Notifications:BottomToAll({hero="npc_dota_hero_alchemist", duration=dur})
	Notifications:BottomToAll({text="&nbsp;", duration=dur, continue=true})    
	Notifications:BottomToAll({text="#alch_gold", duration=dur, continue=true})
	Notifications:BottomToAll({text=gold.."g", duration=dur, style={color="gold"}, continue=true})
	EmitGlobalSound("General.CoinsBig")

	for i=0, playerCount do
		PlayerResource:ModifyGold(i, gold, true, 0)
	end
end