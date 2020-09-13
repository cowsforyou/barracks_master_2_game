if not PlayerColors then
    PlayerColors = class({})
end

function PlayerColors:Init()
    for i, color in ipairs({
        "purple",
        "white",
        "black",
        "cyan",
        "lime",
        "red",
        "silver",
    }) do
        CustomNetTables:SetTableValue( "player_colors", color, { isAvailable = true } )
        if color == "purple" then
            CustomNetTables:SetTableValue( "player_colors", color, { isAvailable = false } )
        end

      end

    CustomGameEventManager:RegisterListener ('set_player_color', Dynamic_Wrap(PlayerColors, "SetPlayerColor") )
    CustomGameEventManager:RegisterListener ('set_player_color_unselected', Dynamic_Wrap(PlayerColors, "SetPlayerColorUnselected") )
    CustomGameEventManager:RegisterListener ('set_player_color_preview', Dynamic_Wrap(PlayerColors, "SetPlayerColorPreview") )
end

function PlayerColors:SetPlayerColorPreview( event )
	CustomGameEventManager:Send_ServerToAllClients( "player_color_preview_pick", 
	{ PlayerID = event.PlayerID, Color = event.Color} )
end

function PlayerColors:GetRGBValues (color)
    if color == "purple" then
        return {191,0,255}
    elseif color == "white" then
        return {255,255,255}
    elseif color == "black" then
        return {0,0,0}
    elseif color == "cyan" then
        return {0,255,255}
    elseif color == "lime" then
        return {0,255,0}
    elseif color == "red" then
        return {255,0,0}
    elseif color == "silver" then
        return {192,192,192}
    else end
end

function PlayerColors:SetPlayerColor( event )
    -- Reset old color to available
    local originalColorData = CustomNetTables:GetTableValue("selected_player_colors", tostring(event.PlayerID))
    if originalColorData ~= nil then
        PrintTable(originalColorData)
        CustomNetTables:SetTableValue( "player_colors", originalColorData.color, { isAvailable = true })
    end

    -- Set new color
    CustomNetTables:SetTableValue( "selected_player_colors", tostring(event.PlayerID), {color = event.color})
    CustomNetTables:SetTableValue( "player_colors", event.color, { isAvailable = false })

    -- Check old color availablility
    if  originalColorData ~= nil then
        local oldColorAvailability = CustomNetTables:GetTableValue("player_colors", originalColorData.color)
        print('check old color', originalColorData.color)
        PrintTable(oldColorAvailability)
    end

    -- Check new color availability
    local newColorAvailability = CustomNetTables:GetTableValue("player_colors", event.color)
    print('check new color', event.color)
    PrintTable(newColorAvailability)
end

function PlayerColors:SetPlayerColorUnselected( event )
    local colorData = CustomNetTables:GetTableValue("selected_player_colors", tostring(event.PlayerID))
    if colorData == nil then
        for i, color in ipairs({
            "purple",
            "white",
            "black",
            "cyan",
            "lime",
            "red",
            "silver",
        }) do
            local colorAvailabilityData = CustomNetTables:GetTableValue("player_colors", color)
            if colorAvailabilityData['isAvailable'] == 1 then
                local autoSelectedColor = {}
                autoSelectedColor['PlayerID'] = event.PlayerID
                autoSelectedColor['color'] = color
                PlayerColors:SetPlayerColor(autoSelectedColor)
            break end
          end
    end
end

function PlayerColors:GetPlayerColor ( playerId )
    local colorData = CustomNetTables:GetTableValue("selected_player_colors", tostring(playerId))
    return PlayerColors:GetRGBValues (colorData.color)
end