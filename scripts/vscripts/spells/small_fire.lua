function CreateSmallFire( keys )
    local caster = keys.caster
    local fireParticle = ParticleManager:CreateParticle("particles/dire_fx/fire_barracks.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(fireParticle, 1, caster:GetAbsOrigin())
end