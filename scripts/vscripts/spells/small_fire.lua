function CreateSmallFire( keys )
    print(keys)
    local caster = keys.caster
    local fireParticle = ParticleManager:CreateParticleForPlayer("models/items/queenofpain/queenofpain_arcana/debut/particles/lava/lava_bubbling_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, purifier, player)
    ParticleManager:SetParticleControl(fireParticle, 1, caster:GetAbsOrigin())
end