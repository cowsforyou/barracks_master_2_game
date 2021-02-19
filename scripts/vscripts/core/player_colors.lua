if not PlayerColors then
    PlayerColors = class({})
end

function PlayerColors:Init()
    for i, color in ipairs({
        "Gold",
        "Red",
        "Blue",
        "LightGreen",
        "Green",
        "Yellow",
        "Pink",
        "LightBlue",
        "Purple",
        "Silver",
        "Black",
    }) do
        CustomNetTables:SetTableValue( "player_colors", color, { isAvailable = true } )
        if color == "purple" then
            CustomNetTables:SetTableValue( "player_colors", color, { isAvailable = false } )
        end

      end

    CustomGameEventManager:RegisterListener ('set_player_color', Dynamic_Wrap(PlayerColors, "SetPlayerColor") )
    CustomGameEventManager:RegisterListener ('set_player_color_unselected', Dynamic_Wrap(PlayerColors, "SetPlayerColorUnselected") )
    CustomGameEventManager:RegisterListener ('set_player_color_preview', Dynamic_Wrap(PlayerColors, "SetPlayerColorPreview") )
    CustomGameEventManager:RegisterListener ('check_player_premium_colors', Dynamic_Wrap(PlayerColors, "CheckPlayerPremiumColors") )
end

function PlayerColors:CheckPlayerPremiumColors( event )
    local playerId = event.PlayerID
    local player = PlayerResource:GetPlayer(playerId)
    local steamId = PlayerResource:GetSteamAccountID(playerId)
    local premiumColor = {Purple = false, Silver = false, Black = false, LightGreen = false, Blue = false, LightBlue = false}

    if steamId == 46639111 then -- (cows)
        premiumColor.Silver = true
        premiumColor.Black = true
        premiumColor.Purple = true
        premiumColor.LightGreen = true
        premiumColor.Blue = true
        premiumColor.LightBlue = true
    end

    if steamId == 72355671 then -- (xiao)
        premiumColor.Silver = true
        premiumColor.Black = true
        premiumColor.Purple = true
        premiumColor.LightGreen = true
        premiumColor.Blue = true
        premiumColor.LightBlue = true
    end

    if player then
      CustomGameEventManager:Send_ServerToPlayer(player, "get_player_premium_colors", premiumColor)
    end
end

function PlayerColors:SetPlayerColorPreview( event )
	CustomGameEventManager:Send_ServerToAllClients( "player_color_preview_pick", 
	{ PlayerID = event.PlayerID, Color = event.Color} )
end

function PlayerColors:GetRGBValues (color)
    if color == "Gold" then
        return {215,138,5}
    elseif color == "Red" then
        return {128,0,3}
    elseif color == "Blue" then
        return {0,156,201}
    elseif color == "LightGreen" then
        return {170,255,170}
    elseif color == "Green" then
        return {0,200,50}
    elseif color == "Yellow" then
        return {255,255,0}
    elseif color == "Pink" then
        return {255,125,200}
    elseif color == "LightBlue" then
        return {0,255,255}
    elseif color == "Purple" then
        return {191,0,255}
    elseif color == "Silver" then
        return {225,225,225}
    elseif color == "Black" then
        return {0,0,0}
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
            "Gold",
            "Red",
            "Blue",
            "LightGreen",
            "Green",
            "Yellow",
            "Pink",
            "LightBlue",
            "Purple",
            "Silver",
            "Black",
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

function PlayerColors:GetPlayerColorName ( playerId )
    local colorData = CustomNetTables:GetTableValue("selected_player_colors", tostring(playerId))
    return colorData.color
end

