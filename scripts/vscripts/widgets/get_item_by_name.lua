---------------------------------------------------------------------------
-- Allows you to find an item by name
---------------------------------------------------------------------------
function GetItemByName(unit, item_name)
    for i=DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
        local item = unit:GetItemInSlot(i)
        if item and item:GetAbilityName() == item_name then
            return item
        end
    end
    return nil
end