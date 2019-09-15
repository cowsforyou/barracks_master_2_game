if not Upgrades then
    Upgrades = class({})
end

function Upgrades:Init()
    Upgrades.Requirements = LoadKeyValues("scripts/kv/tech_tree.kv")
    Upgrades.Players = {}
    Upgrades.Debug = true -- Turn this off to stop spewing messages from this module
end

-- Checks all abilities on a unit
function Upgrades:CheckAbilityRequirements(unit, playerID)
    if not IsValidEntity(unit) then return self:print("[CheckAbilityRequirements ERROR, unit is not valid (deleted)") end
    playerID = playerID or unit:GetPlayerOwnerID()

    -- Check the Researches for this player, adjusting the abilities that have been already upgraded
    Upgrades:CheckResearchRequirements(unit, playerID)

    Upgrades:print("Checking Requirements on "..unit:GetUnitName().." for Player "..playerID)
    for abilitySlot=0,15 do
        local ability = unit:GetAbilityByIndex(abilitySlot)
        if ability then
            ability:CheckAbility()
        end
    end
end

-- Returns bool
function Upgrades:PlayerHasRequirementForAbility(playerID, ability_name)
    if Upgrades.Unlocked then return true end

    local requirements = Upgrades:GetAbilityRequirements(ability_name) 
    if not requirements then return true end

    local upgrades = Upgrades:GetUpgradeTable(playerID) 

    -- Go through each requirement line and check if the player has that building on its list
    for k,v in pairs(requirements) do

        -- If it's an ability tied to a research, check the upgrades table
        if requirements.research then
            if k ~= "research" and (not upgrades[k] or upgrades[k] == 0) then
                Upgrades:print("Failed the research requirements for "..ability_name..", no "..k.." found")
                return false
            end
        else
            local buildCount = BuildingHelper:GetBuildingCount(playerID, k)
            Upgrades:print("Building Name | Need | Have")
            Upgrades:print(k.." | "..v.." | "..(buildCount or "0"))

            -- If its a building, check every building requirement
            if not buildCount or buildCount == 0 then
                Upgrades:print("Failed one of the requirements for "..ability_name..", no "..k.." found")
                return false
            end
        end
    end
    return true
end

function Upgrades:GetAbilityRequirements(ability_name)
    return Upgrades.Requirements[ability_name]
end

function Upgrades:GetUpgradeTable(playerID)
    Upgrades.Players[playerID] = Upgrades.Players[playerID] or {}
    return Upgrades.Players[playerID]
end

function Upgrades:SetLevel(playerID, name, level)
    local upgradeTable = Upgrades:GetUpgradeTable(playerID)
    level = (upgradeTable[name] and math.max(upgradeTable[name], level)) or level
    upgradeTable[name] = level
end

function Upgrades:GetLevel(playerID, name)
    return Upgrades:GetUpgradeTable(playerID)[name] or 0
end

-- Returns bool
function Upgrades:PlayerHasUpgrade(playerID, name)
    return Upgrades:GetLevel(playerID, name) > 0
end

-- Run just before CheckAbilityRequirements, when a building starts construction
function Upgrades:CheckResearchRequirements(unit, playerID)
    for abilitySlot=0,15 do
        local ability = unit:GetAbilityByIndex(abilitySlot)

        if ability then
            local ability_name = ability:GetAbilityName()
            if ability_name:match("research_") and not ability:IsChannelingOrQueued() then
                if Upgrades:PlayerHasUpgrade(playerID, ability_name) then
                    if Upgrades:GetLevel(playerID, ability_name) < ability:GetMaxLevel() then
                        ability:SetHidden(false)
                    else
                        -- Player already has the research, remove it
                        ability:SetHidden(true)
                        unit:RemoveAbility(ability_name)                        
                    end
                else
                    ability:SetHidden(false)
                end
            end
        end
    end
end

function Upgrades:ToggleLock()
    Upgrades.Unlocked = not Upgrades.Unlocked
end

function Upgrades:Unlock()
    Upgrades.Unlocked = true
end

function Upgrades:print(s)
    if Upgrades.Debug then
        print("[Upgrades] "..s)
    end
end

-------------------------------------------

-- Enable/Disable as required
function CDOTABaseAbility:CheckAbility()
    local abilityName = self:GetBaseAbilityName()
    local playerHasRequirements = Upgrades:PlayerHasRequirementForAbility(self:GetCaster():GetPlayerOwnerID(), abilityName)
    
    if self:IsDisabled() then
        -- Success: Player has necessary buildings/research, OR there are no requirements
        if playerHasRequirements then 
            self:Enable():UpdateToResearchLevel()
        else
            Upgrades:print("Requirements not met. "..abilityName.." still disabled.")
        end
    else -- research ability is not disabled
        if playerHasRequirements then
            self:UpdateToResearchLevel()
        else -- Failure: The player has lost some requirement due to building destruction.
            self:Disable()
        end
    end
end

function CDOTABaseAbility:UpdateToResearchLevel()
    local abilityName = self:GetAbilityName()    
    local researchLevel = Upgrades:GetLevel(self:GetCaster():GetPlayerOwnerID(), "research_"..abilityName)

    if researchLevel and researchLevel > 0 then
        self:SetLevel(researchLevel)
        return
    elseif self:IsUpgradeableResearch() then
        local researchLevel = Upgrades:GetLevel(self:GetCaster():GetPlayerOwnerID(), abilityName)
        if researchLevel then
            self:SetLevel(researchLevel + 1)
            return
        end
    end
    
    self:SetLevel(1)
end

function CDOTABaseAbility:IsChannelingOrQueued()
    if self:IsChanneling() then
        return true
    end

    local unit = self:GetCaster()
    local abilityName = self:GetAbilityName()
    for itemSlot=0,5 do
        local item = unit:GetItemInSlot(itemSlot)
        if item and item:GetName():match(abilityName) then
            Upgrades:print("item: " .. item:GetName())
            return true
        end
    end

    return false
end

function CDOTABaseAbility:IsResearch()
    return self:GetAbilityName():match("research_")
end

-- is this a research ability above level 0? we should ignore it, because it's an upgradeable research ability
function CDOTABaseAbility:IsUpgradeableResearch()
    return self:IsResearch() and self:GetMaxLevel() > 1
end

-- adds the base ability, swaps it with disabled ability, returns new ability
function CDOTABaseAbility:Enable()
    local unit = self:GetCaster()
    local disabledAbilityName = self:GetAbilityName()
    local abilityName = self:GetBaseAbilityName()

    -- Learn the ability and remove the disabled one
    local ability = unit:AddAbility(abilityName)
    unit:SwapAbilities(disabledAbilityName, abilityName, false, true)
    unit:RemoveAbility(disabledAbilityName)

    if not ability then Upgrades:print("Error, Couldn't add Enabled ability named "..abilityName)
    else Upgrades:print("Enabled ability "..abilityName) end

    return ability
end

-- Disable the ability, swap to a _disabled
function CDOTABaseAbility:Disable()
    local unit = self:GetCaster()
    local abilityName = self:GetAbilityName()
    local disabledAbilityName = abilityName.."_disabled"

    unit:AddAbility(disabledAbilityName)                    
    unit:SwapAbilities(abilityName, disabledAbilityName, false, true)
    unit:RemoveAbility(abilityName)

    local ability = unit:FindAbilityByName(disabledAbilityName)
    if not ability then Upgrades:print("Error, Couldn't add Disabled ability named "..disabledAbilityName)
    else Upgrades:print("Disabled ability "..abilityName) end

    return ability
end

-- By default, all abilities that have a requirement start as _disabled
-- This is to prevent applying passive modifier effects that have to be removed later
-- The disabled ability is just a dummy for tooltip, precache and level 0.
-- Check if the ability is disabled or not
function CDOTABaseAbility:IsDisabled()
    return self:GetAbilityName():match("_disabled")
end

function CDOTABaseAbility:GetBaseAbilityName()
    return self:IsDisabled() and self:GetAbilityName():gsub("_disabled", "") or self:GetAbilityName()
end

if not Upgrades.Requirements then Upgrades:Init() end