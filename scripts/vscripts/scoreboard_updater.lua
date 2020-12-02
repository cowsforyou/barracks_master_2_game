if not ScoreboardUpdater then
    ScoreboardUpdater = class({})
end

SCOREBOARD_UPDATE_EVERY = 1.0

function ScoreboardUpdater:Setup()
	local emptyValues = { cs = 0, netWorth = 0, lumber = 0, gold = 0 }
	local playerCount = PlayerResource:GetPlayerCount()

	if playerCount == 1 then
		bot = GameRules:AddBotPlayerWithEntityScript('npc_dota_hero_wisp','Barracks Master Bot', DOTA_TEAM_BADGUYS, nil, false)
		bot:ForceKill(false)
		GameRules.botEnabled = true
	end

	for playerID=0, playerCount-1 do
		CustomNetTables:SetTableValue("scores", tostring(playerID), emptyValues)
	end

	Timers:CreateTimer(function()
		self:Update()
		return SCOREBOARD_UPDATE_EVERY
	end)
end

function ScoreboardUpdater:Update()
	local heroList = HeroList:GetAllHeroes()
	for _,hero in pairs(heroList) do
		local player = hero:GetPlayerOwner()
		local playerID = hero:GetPlayerOwnerID()
		local values = {
			cs = PlayerResource:GetLastHits(playerID) or 0,
			netWorth = self:GetNetWorth(player) or 0,
			lumber = hero.lumber or 0,
			gold = PlayerResource:GetGold(playerID) or 0,
		}
		CustomNetTables:SetTableValue("scores", tostring(playerID), values)
	end
	CustomGameEventManager:Send_ServerToAllClients("RefreshScoreboard", {})
end

-- Net Worth = current gold + buildings worth + research worth + living units worth (heroes, lumberjacks, scouts)
function ScoreboardUpdater:GetNetWorth(player)
	if player == nil then return 0 end

	local hero = player:GetAssignedHero()
	if hero == nil or hero.structures == nil then return 0 end

	local netWorth = PlayerResource:GetGold(player:GetPlayerID()) + hero.lumber
	--PrintTable(player)

	for _,structure in pairs(hero.structures) do
		netWorth = netWorth + GetGoldCostForStructures(structure) + GetLumberCostForStructures(structure)
	end

	for _,unit in pairs(hero.units) do
		netWorth = netWorth + GetGoldCost(unit)
	end

	for upgradeName,upgradeLevel in pairs(hero.upgrades) do
		local goldCostString = GameRules.AbilityKV[upgradeName]["AbilityGoldCost"]
		local goldCostTable = self:SplitResearchCostString(goldCostString)
		for i=1, upgradeLevel do
			netWorth = netWorth + goldCostTable[i]
			--print(upgradeName .. ": Adding " .. costTable[i])
		end

		local abilitySpecialTable = GameRules.AbilityKV[upgradeName]["AbilitySpecial"]
		local lumberCostString = nil
		for _,abilityVariable in pairs(abilitySpecialTable) do
			if abilityVariable['lumber_cost'] then
				lumberCostString = abilityVariable['lumber_cost']
			end
		end
		if lumberCostString then
			local lumberCostTable = self:SplitResearchCostString(lumberCostString)
			for i=1, upgradeLevel do
				netWorth = netWorth + lumberCostTable[i]
			end
		end
	end

	return netWorth
end

function ScoreboardUpdater:SplitResearchCostString(costString)
	return string_split(costString, " ")
end

-- http://stackoverflow.com/questions/1426954/split-string-in-lua
function string_split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end