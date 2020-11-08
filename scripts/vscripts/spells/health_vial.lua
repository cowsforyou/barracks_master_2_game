function HealthVial(keys)
    local caster = keys.caster
    local ability = keys.ability
    local bonus = ability:GetSpecialValueFor("health_bonus")

    local maxHealth = caster:GetMaxHealth()
    caster:SetMaxHealth(maxHealth + bonus)
    caster:SetBaseMaxHealth(maxHealth + bonus) -- not sure what the difference is

    local relativeHP = caster:GetHealthPercent() * caster:GetHealth()
    caster:SetHealth(relativeHP)
end