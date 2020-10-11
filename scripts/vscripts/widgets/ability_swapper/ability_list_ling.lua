function OnSpellStart(keys)
    local caster = keys.caster
    local ability = keys.ability
    local player = caster:GetPlayerOwner()

    -- Page 1: 5 abilities; Pages 2+: 4 abilities
    -- Do NOT use duplicate ability names on the same page
    local ability_list = 
    {
        "build_ling_building_elixir", -- start page 1 (contains 5 abilities)
        "build_ling_building_clorn",
        "build_ling_building_orthi",
        "build_ling_building_lumber",
        "build_ling_building_catlan",
        "build_ling_building_thiki",-- start page 2
        "build_ling_building_gnorgil",
        "build_ling_building_temple",
        "build_ling_building_portal",
        "build_ling_building_purifier", -- start page 3
        "build_ling_building_runic",
        -- remaining slots will be filled with blanks, if any
    }

    -- if caster doesn't have an AbilitySwapper, make one
    if caster.AbilitySwapper == nil then
        caster.AbilitySwapper = AbilitySwapper(caster, ability_list)
    end

    -- swap abilities (takes the ability to know which index it's in)
    caster.AbilitySwapper:SwapAbilities(ability)

    -- building helper fixes requirements
    --CheckAbilityRequirements(caster, player) 
end