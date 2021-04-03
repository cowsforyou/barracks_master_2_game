function SpawnScout( event )
    local caster = event.caster -- Hero
    local distance = event.Distance -- Passed by parameter
    local duration = event.Duration -- Passed by parameter


    -- Determine the unitName based on steamID
    local playerID = caster:GetPlayerID()
    local steamID = PlayerResource:GetSteamAccountID(playerID)
    local unitName = "scout_land"
    
    if 
        steamID == 87566860 or steamID == 103245869 then
        unitName = "scout_land_blue" 
    elseif 
        steamID == 72355671 then
        unitName = "scout_land_red"
    elseif 
        steamID == 46639111 then
        unitName = "scout_land_dino_white"
    end

    -- List of steamID3

    -- 46639111 (cows)
    -- 72355671 (xiao)
    -- 103245869 (iRest)
    -- 87566860 (groovy)

    -- Create the unit in front of the caster
    local origin = caster:GetAbsOrigin()
    local fv = caster:GetForwardVector()
    local position = origin + fv * distance

    local unit = CreateUnitByName( unitName, position, true, caster, caster, caster:GetTeamNumber() )
    unit:SetOwner(caster)
    unit:SetControllableByPlayer( playerID, true )
    unit:SetForwardVector(fv)

    -- Apply modifiers
    local ability = event.ability
    ability:ApplyDataDrivenModifier( caster, unit, "modifier_creation_and_death_effects", {} )

    -- Set duration for summoned units
    unit:AddNewModifier( unit, nil, "modifier_kill", {duration = duration} )
end