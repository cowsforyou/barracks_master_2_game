--[[
Installation Instructions:

1) On addon_game_mode.lua, add this line of code:
require('spells/purifier')
]]--

if not Purifier then
    Purifier = class({})
end

function Purifier:FindPurifier(player)
    local hero = player:GetAssignedHero()
    local playerID = player:GetPlayerID()
    local playerBuildings = BuildingHelper:GetBuildings(playerID)
    for _,building in pairs(playerBuildings) do
        if IsValidEntity(building) and building:IsAlive() then
            print("valid building found")
            if building:GetUnitName():match("purifier") then
                print("valid purifier found")
                return building
            end
        end
    end

    return nil
end

function Purifier:EarnedGold(player, gold)
    local purifier = self:FindPurifier(player)
    if not purifier then
        -- print("No purifier found.")
        return
    end

    local goldAbility = purifier:FindAbilityByName("purifier_bonus_gold")
    if not goldAbility then
        -- print("Shouldn't ever happen because this ability is not researched")
        return
    end

    local playerID = player:GetPlayerID()
    local goldMultiplier = goldAbility:GetSpecialValueFor("gold_bonus") / 10
    local extraGold = math.floor(gold * goldMultiplier)
    PlayerResource:ModifyGold(playerID, extraGold, false, DOTA_ModifyGold_CreepKill)

    -- particle effects appear on the purifier itself
    local coinsParticle = ParticleManager:CreateParticleForPlayer("particles/generic_gameplay/lasthit_coins.vpcf", PATTACH_ABSORIGIN_FOLLOW, purifier, player)
    ParticleManager:SetParticleControl(coinsParticle, 1, purifier:GetAbsOrigin())
    PopupGoldGainForPlayer(player, purifier, extraGold)
    -- print("Found purifier, gold +" .. extraGold)
end

function Purifier:EarnedLumber(player, lumber)
    local purifier = self:FindPurifier(player)
    if not purifier then
        -- print("No purifier found.")
        return
    end

    local lumberAbility = purifier:FindAbilityByName("purifier_bonus_lumber")
    if not lumberAbility then
        -- print("Purify lumber ability not researched yet")
        return
    end

    local lumberMultiplier = lumberAbility:GetSpecialValueFor("lumber_bonus") / 100
    local extraLumber = math.floor(lumber * lumberMultiplier)

    local playerID = player:GetPlayerID()
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    ModifyLumber(hero, extraLumber)
    PopupLumber(purifier, extraLumber)
    -- print("Found purifier, lumber +" .. extraLumber)
end