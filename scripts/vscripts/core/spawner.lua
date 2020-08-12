---------------------------------------------------------------------
-- Spawn creep groups and manage building ability cooldown
---------------------------------------------------------------------

-- Called from spawner_ability.lua
function AutoSpawnCreeps(playerID, buildingAbility, creepName, spawn_count, overrideSpawnSync)
    local overrideSpawnSync = overrideSpawnSync or false
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)

    -- Linking with entities on hammer
    local team = PlayerResource:GetTeam(playerID)
    local spawn_number = 0
    if GetPlayerAllyNumber(playerID) == 1 or GetPlayerAllyNumber(playerID) == 2 then
        spawn_number = 1
    else
        spawn_number = 2
    end
    local spawn_name = team.."_"..spawn_number.."_spawner"
    local spawn_point = Entities:FindByName(nil, spawn_name)

    -- Call from spawn_synchronizer.lua
    -- Set the cooldown to the next 30 second interval
    local nextSync = SpawnSynchronizer:GetNextInterval()

    -- Don't spawn creeps the first time this ability is used
    -- The -1.0 gives us a little wiggleroom for the Thinker
    if not overrideSpawnSync then
        if nextSync == nil or nextSync < (SPAWN_INTERVAL-1.0) then 
            return
        else
            buildingAbility:StartCooldown(nextSync)
        end
    end

    -- Spawn creeps
    for i=1, spawn_count do
        local unit = CreateUnitByName(creepName, spawn_point:GetAbsOrigin() , true, hero, hero, team)
        unit:SetOwner(hero)
        table.insert(hero.units, unit)
        unit.coreSpawn = true
        Upgrades:CheckAbilityRequirements(unit, playerID)
        
        -- Colorize creeps according to player color
        local color = PlayerColors:GetPlayerColor(playerID)
        unit:SetRenderColor(color[1],color[2],color[3])
        
        Timers(0.1, function()
            local wp = Entities:FindByName(nil, team.."_"..spawn_number.."_spawner_waypoint_1") -- First wp, this must exist
            ExecuteOrderFromTable({UnitIndex=unit:GetEntityIndex(), OrderType=DOTA_UNIT_ORDER_ATTACK_MOVE, Position=wp:GetAbsOrigin()})

            -- Queued wps
            for i=2,10 do --whatever max waypoint number
                local wp = Entities:FindByName(nil, team.."_"..spawn_number.."_spawner_waypoint_"..i) --wp number i
                if wp then -- if it exists, queue the movement
                    ExecuteOrderFromTable({UnitIndex=unit:GetEntityIndex(), OrderType=DOTA_UNIT_ORDER_ATTACK_MOVE, Position=wp:GetAbsOrigin(), Queue=true})
                else --no more wps to process, they come in order
                    break
                end
            end
        end)
    end
end