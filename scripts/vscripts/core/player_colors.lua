if not PlayerColors then
    PlayerColors = class({})
end

function PlayerColors:Init()
    for i, color in ipairs({
        "mandarinorange",
        "red",
        "tiffany",
        "limegreen",
        "armygreen",
        "yellow",
        "pink",
        "cyan",
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
    if color == "mandarinorange" then
        return {215,138,5}
    elseif color == "red" then
        return {128,0,3}
    elseif color == "tiffany" then
        return {0,156,201}
    elseif color == "limegreen" then
        return {170,255,170}
    elseif color == "armygreen" then
        return {0,200,50}
    elseif color == "yellow" then
        return {255,255,0}
    elseif color == "pink" then
        return {255,125,200}
    elseif color == "cyan" then
        return {0,255,255}
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

    CustomGameEventManager:Send_ServerToAllClients( "player_color_confirmed_pick", 
	{ PlayerID = event.PlayerID, Color = event.color} )
end

function PlayerColors:SetPlayerColorUnselected( event )
    local colorData = CustomNetTables:GetTableValue("selected_player_colors", tostring(event.PlayerID))
    if colorData == nil then
        for i, color in ipairs({
            "mandarinorange",
            "red",
            "tiffany",
            "limegreen",
            "armygreen",
            "yellow",
            "pink",
            "cyan",
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