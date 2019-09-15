-- This overrides the broken API by redirecting the sound to be played in Panorama (sounds.js)
function EmitSoundOnClient(sound, pID)
    local player = type(pID) == "number" and PlayerResource:GetPlayer(pID) or pID -- Takes a playerID or player handle as parameter

    if player then
        CustomGameEventManager:Send_ServerToPlayer(player, "emit_client_sound", {sound=sound})
        return true
    end
    return false
end