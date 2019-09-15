-- Lumber AbilityValue, credits to zed https://github.com/zedor/AbilityValues
-- Note: When the abilities change, we need to update this value.
Convars:RegisterCommand("ability_values_entity", function(name, entityIndex)
    local cmdPlayer = Convars:GetCommandClient()
    local pID = cmdPlayer:GetPlayerID()

    if cmdPlayer then
        local unit = EntIndexToHScript(tonumber(entityIndex))
        if not IsValidEntity(unit) then return end
        
        if unit then
            local abilityValues = {}
            local itemValues = {}

            -- Iterate over the abilities
            for i=0,15 do
                local ability = unit:GetAbilityByIndex(i)

                -- If there's an ability in this slot and its not hidden, define the number to show
                if ability and not ability:IsHidden() then
                    local lumberCost = ability:GetLevelSpecialValueFor("lumber_cost", ability:GetLevel() - 1)
                    if lumberCost then
                        table.insert(abilityValues,lumberCost)
                    else
                        table.insert(abilityValues,0)
                    end
                end
            end

            FireGameEvent( 'ability_values_send', { player_ID = pID, 
                                                hue_1 = -10, val_1 = abilityValues[1], 
                                                hue_2 = -10, val_2 = abilityValues[2], 
                                                hue_3 = -10, val_3 = abilityValues[3], 
                                                hue_4 = -10, val_4 = abilityValues[4], 
                                                hue_5 = -10, val_5 = abilityValues[5],
                                                hue_6 = -10, val_6 = abilityValues[6] } )

            -- Iterate over the items
            for i=0,5 do
                local item = unit:GetItemInSlot(i)

                -- If there's an item in this slot, define the number to show
                if item then
                    local lumberCost = item:GetSpecialValueFor("lumber_cost")
                    if lumberCost then
                        table.insert(itemValues,lumberCost)
                    else
                        table.insert(itemValues,0)
                    end
                end
            end

            FireGameEvent('ability_values_send_items', { player_ID = pID, 
                                                hue_1 = 0, val_1 = itemValues[1], 
                                                hue_2 = 0, val_2 = itemValues[2], 
                                                hue_3 = 0, val_3 = itemValues[3], 
                                                hue_4 = 0, val_4 = itemValues[4], 
                                                hue_5 = 0, val_5 = itemValues[5],
                                                hue_6 = 0, val_6 = itemValues[6] } )
            
        else
            -- Hide all the values if the unit is not supposed to show any.
            FireGameEvent( 'ability_values_send', { player_ID = pID, val_1 = 0, val_2 = 0, val_3 = 0, val_4 = 0, val_5 = 0, val_6 = 0 } )
            FireGameEvent( 'ability_values_send_items', { player_ID = pID, val_1 = 0, val_2 = 0, val_3 = 0, val_4 = 0, val_5 = 0, val_6 = 0 } )
        end
    end
end, "Change AbilityValues", 0 )