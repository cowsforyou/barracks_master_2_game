function Suicide ( keys )
    local caster = keys.caster

    if caster:IsAlive() then
        caster:ForceKill(true) 
    end
end