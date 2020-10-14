function SpawnScout( event )
    local caster = event.caster -- Hero
    local distance = event.Distance -- Passed by parameter
    local duration = event.Duration -- Passed by parameter
    local goldCost = event.GoldCost -- Passed by parameter

    -- Determine the unitName based on steamID
    local playerID = caster:GetPlayerID()
    local steamID = PlayerResource:GetSteamAccountID(playerID)
    local unitName = "scout_techies"

    -- Create the unit in front of the caster
    local origin = caster:GetAbsOrigin()
    local fv = caster:GetForwardVector()
    local position = origin + fv * distance

    local unit = CreateUnitByName( unitName, position, true, caster, caster, caster:GetTeamNumber() )
    unit:SetOwner(caster)
    unit:SetControllableByPlayer( playerID, true )
    unit:SetForwardVector(fv)

    -- Add to scoreboard
    unit.GoldCost = goldCost
    table.insert(caster.units, unit)

    -- Apply modifiers
    local ability = event.ability
    ability:ApplyDataDrivenModifier( caster, unit, "modifier_creation_and_death_effects", {} )

    -- Set duration for summoned units
    unit:AddNewModifier( unit, nil, "modifier_kill", {duration = duration} )
end

function ScoutDeath( event )
    local hero = event.caster -- Hero
    local unit = event.unit -- Unit
    local unit_index = getIndexTable(hero.units, unit)

    table.remove(hero.units, unit_index)
end