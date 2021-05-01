if not BMCore then
    BMCore = class({})
end

-- Called from GameMode:OnPlayerPickedHero(keys)
function BMCore:InitializeHero(hero)
    print("BMCore:InitializeHero function Initialized", hero)
    DebugPrintTable(hero)
    local playerID = hero:GetPlayerOwnerID()     
    local player = PlayerResource:GetPlayer(playerID)

    -- Initialize variables for tracking
    hero.units = {} -- This keeps the handle of all the units of the player, to iterate for unlocking upgrades
    hero.structures = {} -- This keeps the handle of the constructed units, to iterate for unlocking upgrades
    hero.buildings = {} -- This keeps the name and quantity of each building
    hero.upgrades = {} -- This kees the name of all the upgrades researched
    hero.lumber = 0 -- Secondary resource of the player
    
    -- Create a building in front of the hero
    -- if PlayerResource:GetTeam(playerID) == DOTA_TEAM_GOODGUYS then
    --     local ent = Entities:FindByName(nil, "goodguys_spawn_1")
    --     initialSpawnPosition = ent:GetAbsOrigin()
    -- else 
    --     local ent = Entities:FindByName(nil, "badguys_spawn_1")
    --     initialSpawnPosition = ent:GetAbsOrigin()
    -- end
    -- local position = hero:GetAbsOrigin() + hero:GetForwardVector() * 400
    if hero:GetUnitName() == "npc_dota_hero_keeper_of_the_light" then
        local playerBuildings = BuildingHelper:GetBuildings(playerID)
        local hasInitializedBuilding = false
        if playerBuildings ~= nil then
            for _,building in pairs(playerBuildings) do
                if IsValidEntity(building) and building:IsAlive() then
                    if building:GetUnitName():match("ling_building_clorn") then
                        hasInitializedBuilding = true
                    end
                end
            end
        end

        if not hasInitializedBuilding then
            InstantBuild( hero, player, "ling_building_clorn", hero:GetAbsOrigin() )
        end
    elseif hero:GetUnitName() == "npc_dota_hero_nevermore" then
        local hasInitializedBuilding = false
        if playerBuildings ~= nil then
            for _,building in pairs(playerBuildings) do
                if IsValidEntity(building) and building:IsAlive() then
                    if building:GetUnitName():match("xoo_building_citol") then
                        hasInitializedBuilding = true
                    end
                end
            end
        end

        if not hasInitializedBuilding then
            InstantBuild( hero, player, "xoo_building_citol", hero:GetAbsOrigin() )
        end
    end

    -- Give starting items and resources
    hero:SetGold(350, false)
    ModifyLumber(hero, 50)

    hero:AddItemByName("item_travel_boots")
    hero:AddItemByName("item_scout_land")
    hero:AddItemByName("item_last_stand")
    --hero:AddItemByName("item_quelling_blade")

    -- Remove AbilityPoints and upgrade initial abilities
    hero:SetAbilityPoints(0)
    Upgrades:CheckAbilityRequirements(hero)

    -- Give Perk Ability
    local perkData = CustomNetTables:GetTableValue("selected_player_perks", tostring(playerID))
    print("hahah im here")
    PrintTable(perkData)
    if perkData ~= nil then
        print(perkData.perk)
        hero:AddAbility(perkData.perk)
    end

    -- Setup Lumber tick
    Timers(function()
        ModifyLumber(hero, LUMBER_PER_TICK)
        return LUMBER_TICK_TIME
    end)
end

-- Instantly build the starting buildings
function InstantBuild( hero, player, building_name, position )
    local playerID = hero:GetPlayerOwnerID()     
    local angle = GetUnitKV("build_"..building_name, "ModelRotation")
    local unit = BuildingHelper:PlaceBuilding(player, building_name, position, 5, nil, angle)

    -- Colorize building according to player color
    local color = PlayerColors:GetPlayerColor(playerID) or {191,0,255}
    unit:SetRenderColor(color[1],color[2],color[3])

    -- Add the building handle to the list of structures
    table.insert( hero.structures, unit )

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
end