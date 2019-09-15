--------------------------------------------------------------------------------------------------------
-- General spawner AI
--------------------------------------------------------------------------------------------------------
function Think( keys )
    --print("Think function executed")
    local caster = keys.caster
    local ability = keys.ability
    
    --print(ability:GetAutoCastState(), ability:IsFullyCastable(), ability.initialAutocast) 
    if ability.initialAutocast == nil and ability:GetAutoCastState() == false then
        ability:ToggleAutoCast()
        ability.initialAutocast = true
    end

    if ability:GetAutoCastState() and ability:IsFullyCastable() and not caster:HasModifier("modifier_construction") then
            --print("starting caster:castabilitynotarget") -- does it get here?
        caster:CastAbilityNoTarget(ability, 0)
    end
end

function SpawnerAbility( keys )
    --print("SpawnerAbility function executed")
    local caster = keys.caster
    local ability = keys.ability

    local overrideSpawnSync = false

    -- check for a stored creepName value on the caster, then use that if it's present
    local creepName = ""
    if caster.creepName == nil then
        creepName = keys.creepName
    else
        creepName = caster.creepName
    end

    local spawn_count = ability:GetLevelSpecialValueFor("creep_count", ability:GetLevel()-1)
    --print("Printing spawn count", spawn_count)


    local playerID = caster:GetPlayerOwnerID()
    AutoSpawnCreeps(playerID, ability, creepName, spawn_count, overrideSpawnSync)
end