function CreateSmallFire( keys )
    print(keys)
    local caster = keys.caster
    local fireParticle = ParticleManager:CreateParticleForPlayer("particles/econ/courier/courier_trail_international_2013_se/courier_international_2013_se_f.vpcf", PATTACH_ABSORIGIN_FOLLOW, purifier, player)
    ParticleManager:SetParticleControl(fireParticle, 1, caster:GetAbsOrigin())
end