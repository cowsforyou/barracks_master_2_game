if not CreepControl then
    CreepControl = class({})
end

function CreepControl:IsTower(entity)
    local isTower = string.find(entity:GetUnitName(), "tower")
    return isTower ~= nil
end

function CreepControl:IsValidBountyKiller(killerEntity)
    return not self:IsTower(killerEntity)
end

function CreepControl:IsValidBountyTargetForPlayer(killedUnit)
    return not self:IsTower(killedUnit) and not killedUnit:IsHero()
end

function CreepControl:OnCreepKilled( killedUnit, killerEntity )
    if self:IsValidBountyKiller(killerEntity) and self:IsValidBountyTargetForPlayer(killedUnit) then
        local gold = killedUnit:GetGoldBounty()
        local playerID = killerEntity:GetPlayerOwnerID()
        local player = PlayerResource:GetPlayer(playerID)
        Purifier:EarnedGold(player, gold)
    end
end