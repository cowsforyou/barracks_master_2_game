--[[
Installation Instructions:

1) On addon_game_mode.lua, add this line of code:
require('widgets/modify_lumber')
]]--

function ModifyLumber(hero, lumber_value)
    print("ModifyLumber ", hero, lumber_value)
    -- local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    local playerID = hero:GetPlayerID()
    local player = PlayerResource:GetPlayer(playerID)
    DebugPrintTable(hero)

    hero.lumber = hero.lumber + lumber_value

    if player and hero.lumber >= 0 then
        CustomGameEventManager:Send_ServerToPlayer(player, "player_lumber_changed", { lumber = math.floor(hero.lumber) })
    else
        print("Tried to set negative lumber for ", playerID)
    end
end

function PopupLumber(target, amount)
    PopupNumbers(target, "damage", Vector(10, 200, 90), 3.0, amount, 0, nil)
end

-- Customizable version.
function PopupNumbers(target, pfx, color, lifetime, number, presymbol, postsymbol)
    local pfxPath = string.format("particles/msg_fx/msg_%s.vpcf", pfx)
    local pidx
    if pfx == "gold" or pfx == "lumber" then
        pidx = ParticleManager:CreateParticleForTeam(pfxPath, PATTACH_ABSORIGIN_FOLLOW, target, target:GetTeamNumber())
    else
        pidx = ParticleManager:CreateParticle(pfxPath, PATTACH_ABSORIGIN_FOLLOW, target)
    end

    local digits = 0
    if number ~= nil then
        digits = #tostring(number)
    end
    if presymbol ~= nil then
        digits = digits + 1
    end
    if postsymbol ~= nil then
        digits = digits + 1
    end

    ParticleManager:SetParticleControl(pidx, 1, Vector(tonumber(presymbol), tonumber(number), tonumber(postsymbol)))
    ParticleManager:SetParticleControl(pidx, 2, Vector(lifetime, digits, 0))
    ParticleManager:SetParticleControl(pidx, 3, color)
end