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

function ManualSpawnerAbility( keys )
    local ability = keys.ability
    local caster = keys.caster
    local player = caster:GetPlayerOwner()
    if player == nil then return end -- don't try to spawn creeps from a ghost dummy
    local playerID = caster:GetPlayerOwnerID()
    local hero = player:GetAssignedHero()

    local creepName = keys.creepName
    local iconName = keys.iconName
    local soundName = keys.soundName
    local creepCount = ability:GetSpecialValueFor("creep_count")
    local gold_cost = ability:GetSpecialValueFor("gold_cost") or 0
    local lumber_cost = ability:GetSpecialValueFor("lumber_cost") or 0

    -- check if player has enough lumber
    if hero.lumber > lumber_cost then
        ModifyLumber(hero, -lumber_cost)
    else
        PlayerResource:ModifyGold(playerID, gold_cost, false, 0) -- refund gold
        ability:EndCooldown()
        SendErrorMessage(playerID, "#error_not_enough_lumber")
        return
    end

    -- send notification
    local dur = 4.0
    Notifications:BottomToAll({hero=iconName, duration=dur})
	Notifications:BottomToAll({text="&nbsp;", duration=dur, continue=true})    
	Notifications:BottomToAll({text="#warning_" .. creepName, duration=dur, continue=true})
    EmitGlobalSound(soundName)
    
    ManualSpawnCreeps(playerID, ability, creepName)
end