-- A build ability is used (not yet confirmed)
function Build( event )
    local caster = event.caster
    local ability = event.ability
    local ability_name = ability:GetAbilityName()
    local building_name = ability:GetAbilityKeyValues()['UnitName']
    local gold_cost = ability:GetGoldCost(1)
    local lumber_cost = ability:GetSpecialValueFor("lumber_cost")
    local hero = caster:IsRealHero() and caster or caster:GetOwner()
    local playerID = hero:GetPlayerID()

    -- Determine which construction effect to use
    --local construction_effect = "modifier_construction_purple"
    --[[if hero:GetUnitName() == "npc_dota_hero_nevermore" then 
        construction_effect = "modifier_construction_purple"
    elseif hero:GetUnitName() == "npc_dota_hero_arc_warden" then
        construction_effect = "modifier_construction_blue"
    elseif hero:GetUnitName() == "npc_dota_hero_keeper_of_the_light" then
        construction_effect = "modifier_construction_gold"
    end
    ]]--

    -- If the ability has an AbilityGoldCost, it's impossible to not have enough gold the first time it's cast
    -- Always refund the gold here, as the building hasn't been placed yet
    hero:ModifyGold(gold_cost, false, 0)

    -- Check for max building count
    local max = ability:GetKeyValue("MaxBuildingCount")
    if max then
        local current = BuildingHelper:GetBuildingCount(playerID, building_name)
        if current >= max then
            SendErrorMessage(playerID, "error_max_build_count")
            return false
        end
    end

    -- Makes a building dummy and starts panorama ghosting
    BuildingHelper:AddBuilding(event)

    -- Additional checks to confirm a valid building position can be performed here
    event:OnPreConstruction(function(vPos)
        -- Check for max building count
        local max = ability:GetKeyValue("MaxBuildingCount")
        local current = 1
        if max then
            current = current + BuildingHelper:GetBuildingCount(playerID, building_name)
        end
        -- Add queued to the current count
        if caster.work then
            if caster.work.name == building_name then
                current = current + 1
            end
        end
        if caster.buildingQueue and #caster.buildingQueue > 0 then
            for k,v in pairs(caster.buildingQueue) do
                if v.name == building_name then
                    current = current + 1
                end
            end
        end
        if current > max then
            SendErrorMessage(playerID, "error_max_build_count")
            return false
        end

        -- Check for minimum height if defined
        if not BuildingHelper:MeetsHeightCondition(vPos) then
            BuildingHelper:print("Failed placement of " .. building_name .." - Placement is below the min height required")
            SendErrorMessage(playerID, "#error_invalid_build_position")
            return false
        end

        -- If attempting to build on an existing structure (created on hammer), reject
        local construction_size = BuildingHelper:GetConstructionSize(building_name) * 16
        local buildings = FindUnitsInRadius(0, vPos, nil, construction_size, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
        if #buildings > 0 then 
            SendErrorMessage(playerID, "#error_invalid_build_position")
            return false 
        end

        -- If not enough resources to queue, stop
        if PlayerResource:GetGold(playerID) < gold_cost then
            BuildingHelper:print("Failed placement of " .. building_name .." - Not enough gold!")
            SendErrorMessage(playerID, "#error_not_enough_gold")
            -- Play sound
            EmitSoundOn("BarracksMaster.InsufficientFunds", caster)
            return false
        elseif hero.lumber < lumber_cost then
            SendErrorMessage(playerID, "#error_not_enough_lumber")
            -- Play sound
            EmitSoundOn("BarracksMaster.InsufficientResources", caster)
            return false
        end

        return true
    end)

    -- Position for a building was confirmed and valid
    event:OnBuildingPosChosen(function(vPos)
        -- Spend resources
        hero:ModifyGold(-gold_cost, false, 0)
        ModifyLumber(hero, -lumber_cost)

        -- Play a sound
        EmitSoundOnClient("DOTA_Item.ObserverWard.Activate", PlayerResource:GetPlayer(playerID))
    end)

    -- The construction failed and was never confirmed due to the gridnav being blocked in the attempted area
    event:OnConstructionFailed(function()
        local playerTable = BuildingHelper:GetPlayerTable(playerID)
        local name = playerTable.activeBuilding

        BuildingHelper:print("Failed placement of " .. building_name)
        SendErrorMessage(playerID, "#error_invalid_build_position_2")        
    end)

    -- Cancelled due to ClearQueue
    event:OnConstructionCancelled(function(work)
        local name = work.name
        BuildingHelper:print("Cancelled construction of " .. building_name)


        -- Refund resources for this cancelled work
        if work.refund then
            hero:ModifyGold(gold_cost, false, 0)
            ModifyLumber(hero, lumber_cost)
        end
    end)

    -- A building unit was created
    event:OnConstructionStarted(function(unit)

        BuildingHelper:print("Started construction of " .. unit:GetUnitName() .. " " .. unit:GetEntityIndex())

        -- Play construction sound
        EmitSoundOn("BarracksMaster.Building", caster)

        -- Add construction effect
        ApplyModifier(unit, "modifier_construction_purple")

        -- Store lumber cost of the building
        unit.lumber_cost = lumber_cost

        -- If it's an item-ability and has charges, remove a charge or remove the item if no charges left
        if ability.GetCurrentCharges and not ability:IsPermanent() then
            local charges = ability:GetCurrentCharges()
            charges = charges-1
            if charges == 0 then
                ability:RemoveSelf()
            else
                ability:SetCurrentCharges(charges)
            end
        end

        -- Colorize building according to player color
        local color = PlayerColors:GetPlayerColor(playerID) or {191,0,255}
        unit:SetRenderColor(color[1],color[2],color[3])

        -- Units can't attack while building
        unit.original_attack = unit:GetAttackCapability()
        unit:SetAttackCapability(DOTA_UNIT_CAP_NO_ATTACK)

        -- Give item to cancel
        unit.item_building_cancel = CreateItem("item_building_cancel", hero, hero)
        if unit.item_building_cancel then 
            unit:AddItem(unit.item_building_cancel)
            unit.gold_cost = gold_cost
        end

        -- FindClearSpace for the builder
        FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
        caster:AddNewModifier(caster, nil, "modifier_phased", {duration=0.03})

        -- Remove invulnerability on npc_dota_building baseclass
        unit:RemoveModifierByName("modifier_invulnerable")
    end)

    -- A building finished construction
    event:OnConstructionCompleted(function(unit)
        BuildingHelper:print("Completed construction of " .. unit:GetUnitName() .. " " .. unit:GetEntityIndex())
        
        -- Play construction complete sound
        EmitSoundOn("BarracksMaster.ConstructionComplete", caster)
        
        -- Remove construction effect
        unit:RemoveModifierByName("modifier_construction_purple")

        -- Remove the item
        if unit.item_building_cancel then
            UTIL_Remove(unit.item_building_cancel)
        end

        -- Give the unit their original attack capability
        if unit.original_attack then
            unit:SetAttackCapability(unit.original_attack)
        end

        -- Initialize the Queue timer
        if unit:GetKeyValue("HasQueue") then
            StartQueue(unit)
        end

        -- Auto-upgrade spawn ability
        for i=0,15 do
            local ability = unit:GetAbilityByIndex(i)
            if ability then
                local abilityName = ability:GetAbilityName()
                if abilityName:match("research_spawn_") and ability:GetLevel() == 1 then
                    Upgrades:SetLevel(playerID, abilityName, ability:GetLevel())
                end
            end
        end

        -- Update the abilities of the builders and buildings
        local playerStructures = BuildingHelper:GetBuildings(playerID)
        for k,structure in pairs(playerStructures) do
            Upgrades:CheckAbilityRequirements(structure, playerID)
        end
        for _,unit in pairs(hero.units) do
            Upgrades:CheckAbilityRequirements(unit, playerID)
        end

        -- Update hero
        Upgrades:CheckAbilityRequirements(hero, playerID)
    end)

    -- These callbacks will only fire when the state between below half health/above half health changes.
    -- i.e. it won't fire multiple times unnecessarily.
    event:OnBelowHalfHealth(function(unit)
        BuildingHelper:print(unit:GetUnitName() .. " is below half health.")
    end)

    event:OnAboveHalfHealth(function(unit)
        BuildingHelper:print(unit:GetUnitName().. " is above half health.")        
    end)
end

-- Called when the Cancel ability-item is used
function CancelBuilding( keys )
    local building = keys.unit
    local hero = building:GetOwner()
    local playerID = building:GetPlayerOwnerID()

    BuildingHelper:print("CancelBuilding "..building:GetUnitName().." "..building:GetEntityIndex())

    -- Play cancelled sound
    EmitSoundOn("BarracksMaster.Cancelled", building)

    -- Remove construction effect
    building:RemoveModifierByName("modifier_construction_purple")

    -- Refund here
    if building.gold_cost then
        hero:ModifyGold(building.gold_cost, false, 0)
    end

    if building.lumber_cost then
        ModifyLumber(hero, building.lumber_cost)
    end

    -- NoDraw
    building:AddNoDraw() 

    -- Eject builder
    local builder = building.builder_inside
    if builder then
        BuildingHelper:ShowBuilder(builder)
    end

    building:ForceKill(true) --This will call RemoveBuilding
end