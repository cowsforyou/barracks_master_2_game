function OnSpellStart(keys)
    local caster = keys.caster
    local ability = keys.ability
    local player = caster:GetPlayerOwner()

    -- Page 1: 5 abilities; Pages 2+: 4 abilities
    -- Do NOT use duplicate ability names on the same page
    local ability_list = 
    {
        "build_xoya_building_belek", -- start page 1 (contains 5 abilities)
        "build_xoya_building_citol",
        "build_xoya_building_phe",
        "build_xoya_building_lumber",
        "build_xoya_building_catlix",
        "build_xoya_building_zavartu", -- start page 2
        "build_xoya_building_warthan",
        "build_xoya_building_monolith",
        --"build_xoya_building_arrow",
        --"build_xoya_building_skeleton",
        "build_xoya_building_purifier",
        "build_xoya_building_library",
        -- remaining slots will be filled with blanks, if any
    }

    -- if caster doesn't have an AbilitySwapper, make one
    if caster.AbilitySwapperXoya == nil then
        caster.AbilitySwapperXoya = AbilitySwapperXoya(caster, ability_list)
    end

    -- swap abilities (takes the ability to know which index it's in)
    caster.AbilitySwapperXoya:SwapAbilities(ability)

    -- building helper fixes requirements
    --CheckAbilityRequirements(caster, player) 
end