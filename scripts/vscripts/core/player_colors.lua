if not PlayerColors then
    PlayerColors = class({})
end

function PlayerColors:Init()
    for i, color in ipairs({
        "purple",
        "white",
        "black",
    }) do
        CustomNetTables:SetTableValue( "player_colors", color, { isAvailable = true } )
      end

    CustomGameEventManager:RegisterListener ('set_player_color', Dynamic_Wrap(PlayerColors, "SetPlayerColor") )
end

function PlayerColors:GetRGBValues (color)
    if color == "purple" then
        return {191,0,255}
    elseif color == "white" then
        return {255,255,255}
    elseif color == "black" then
        return {0,0,0}
    else end
end

function PlayerColors:SetPlayerColor( event )
    -- local originalColorData = CustomNetTables:GetTableValue("selected_player_colors", tostring(event.PlayerID))
    -- if not originalColorData then
    --     PrintTable(originalColorData)
    --     CustomNetTables:SetTableValue( "player_colors", originalColorData.color, { isAvailable = true })
    -- end

    CustomNetTables:SetTableValue( "selected_player_colors", tostring(event.PlayerID), {color = event.color})
    local newColorData = CustomNetTables:GetTableValue("selected_player_colors", tostring(event.PlayerID))

    CustomNetTables:SetTableValue( "player_colors", event.color, { isAvailable = false })
    -- if not originalColorData then
    --     local oldColorAvailability = CustomNetTables:GetTableValue("player_colors", originalColorData.color)
    --     PrintTable(oldColorAvailability)
    -- end
    local newColorAvailability = CustomNetTables:GetTableValue("player_colors", event.color)
    print(PlayerColors:GetPlayerColor ( event.PlayerID ))
end

function PlayerColors:GetPlayerColor ( playerId )
    local colorData = CustomNetTables:GetTableValue("selected_player_colors", tostring(playerId))
    return PlayerColors:GetRGBValues (colorData.color)
end

PlayerColors:Init()