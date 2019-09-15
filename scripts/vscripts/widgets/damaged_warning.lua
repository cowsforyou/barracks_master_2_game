-- Keep track of the last time each player was damaged (to play warnings/"we are under attack")
PLAYER_BUILDINGS_DAMAGED = {} 
PLAYER_DAMAGE_WARNING = {}
UNDER_ATTACK_WARNING_INTERVAL = 15

function CheckDamageWarning(victim)
    if IsValidEntity(victim) and (IsCustomBuilding(victim) or victim:GetUnitLabel() == "worker" or victim:GetUnitLabel() == "scout") then
        local playerID = victim:GetPlayerOwnerID()
        if playerID then
            local time = GameRules:GetGameTime()
            local origin = victim:GetAbsOrigin()
            local teamNumber = victim:GetTeamNumber()

            -- Set the new attack time
            PLAYER_BUILDINGS_DAMAGED[playerID] = time  

            -- Define the warning 
            local last_warning = PLAYER_DAMAGE_WARNING[playerID]

            -- If its the first time being attacked or its been long since the last warning, show a warning
            if not last_warning or (time - last_warning) > UNDER_ATTACK_WARNING_INTERVAL then
                -- Damage Particle
                local particle = ParticleManager:CreateParticleForPlayer("particles/generic_gameplay/screen_damage_indicator.vpcf", PATTACH_EYES_FOLLOW, victim, victim:GetPlayerOwner())
                ParticleManager:SetParticleControl(particle, 1, origin)
                Timers:CreateTimer(3, function() ParticleManager:DestroyParticle(particle, false) end)

                -- Ping
                MinimapEvent(teamNumber, victim, origin.x, origin.y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 1)
                MinimapEvent(teamNumber, victim, origin.x, origin.y, DOTA_MINIMAP_EVENT_ENEMY_TELEPORTING, 3)

                -- Play sound
                if IsCustomBuilding(victim) then
                    EmitSoundOnClient("BarracksMaster.BaseUnderAttack", PlayerResource:GetPlayer(playerID))
                else
                    EmitSoundOnClient("BarracksMaster.ForcesUnderAttack", PlayerResource:GetPlayer(playerID))
                end

                -- Update the last warning to the current time
                PLAYER_DAMAGE_WARNING[playerID] = time
            else
                -- Ping on the building, every 2 seconds at most
                local last_damaged = victim.last_damaged
                if not last_damaged or (time - last_damaged) > 2 then
                    victim.last_damaged = time
                    MinimapEvent(teamNumber, victim, origin.x, origin.y, DOTA_MINIMAP_EVENT_ENEMY_TELEPORTING, 2)
                end
            end
        end
    end
end