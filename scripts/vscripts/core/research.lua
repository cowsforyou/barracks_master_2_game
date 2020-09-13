--[[
	Adds the search to the player research list
]]
function ResearchComplete( event )
	local caster = event.caster
	local ability = event.ability
	local ability_level = ability:GetLevel()
	local research_name = ability:GetAbilityName()
	local playerID = caster:GetPlayerOwnerID()
	local hero = PlayerResource:GetSelectedHeroEntity(playerID)

	-- It shouldn't be possible to research the same upgrade more than once.
	Upgrades:SetLevel(playerID, research_name, ability_level)
	ability:SetLevel(ability_level + 1)
	if ability:GetMaxLevel()+1 == ability:GetLevel() then
		ability:SetHidden(true)
	else
		ability:SetHidden(false)
	end

	-- Update hero
	Upgrades:CheckAbilityRequirements(hero, playerID)
	
	-- Go through all the upgradeable units and upgrade with the research
	for _,unit in pairs(hero.units) do
		Upgrades:CheckAbilityRequirements(unit, playerID)
	end

	-- Also, on the buildings that have the upgrade, disable the upgrade and/or apply the next rank.
	local playerStructures = BuildingHelper:GetBuildings(playerID)
    for k,structure in pairs(playerStructures) do
        Upgrades:CheckAbilityRequirements(structure, playerID)
    end

    -- Play a sound
    EmitSoundOnClient("BarracksMaster.ResearchComplete", PlayerResource:GetPlayer(playerID))
end

-- For add_mines
function ItemResearchComplete ( event )
	local caster = event.caster
	local ability = event.ability
	local itemName = event.item_name
	local player = caster:GetPlayerOwner()
	local hero = player:GetAssignedHero()

	if GetItemByName(hero, itemName) then
		GetItemByName(hero, itemName):SetCurrentCharges(GetItemByName(hero, itemName):GetCurrentCharges() + 1)
	else
		hero:AddItemByName(itemName)
	end
	ResearchComplete(event)
end

-- When queing a research, disable it to prevent from being queued again
function DisableResearch( event )
	local ability = event.ability
	print("Set Hidden "..ability:GetAbilityName())
	ability:SetHidden(true)
end

-- Reenable the parent ability without item_ in its name
function ReEnableResearch( event )
	local caster = event.caster
	local ability = event.ability
	local item_name = ability:GetAbilityName()
	local research_ability_name = string.gsub(item_name, "item_", "")

	print("Unhide "..research_ability_name)
	local research_ability = caster:FindAbilityByName(research_ability_name)
	research_ability:SetHidden(false)
end