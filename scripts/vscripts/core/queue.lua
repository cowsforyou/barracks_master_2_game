--[[
    Creates an item on the buildings inventory to consume the queue.
]]
function EnqueueUnit( event )
    local caster = event.caster
    local ability = event.ability
    local gold_cost = ability:GetSpecialValueFor("gold_cost")
    local lumber_cost = ability:GetSpecialValueFor("lumber_cost")
    local playerID = caster:GetPlayerOwnerID()
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)

    -- Initialize queue
    if not caster.queue then
        caster.queue = {}
    end

    -- Lumber check
    if hero.lumber < lumber_cost then
        PlayerResource:ModifyGold(playerID, gold_cost, false, 0) -- refund gold       
        SendErrorMessage(playerID, "#error_not_enough_lumber")
        return
    end

    -- Queue up to 6 units max
    if #caster.queue < 6 then
        local ability_name = ability:GetAbilityName()
        local item_name = "item_"..ability_name
        local item = CreateItem(item_name, caster, caster)
        caster:AddItem(item)

        -- RemakeQueue
        caster.queue = {}
        for itemSlot = 0, 5, 1 do
            local item = caster:GetItemInSlot( itemSlot )
            if item ~= nil then
                table.insert(caster.queue, item:GetEntityIndex())
            end
        end

        ModifyLumber(hero, -lumber_cost)
        DisableResearch( event )

    else
        -- Refund with message
        PlayerResource:ModifyGold(playerID, gold_cost, false, 0)
        SendErrorMessage(playerID, "#error_queue_full")
    end
end


-- Destroys an item on the buildings inventory, refunding full cost of purchasing and reordering the queue
-- If its the first slot, the channeling ability is also set to not channel, refunding the full price.
function DequeueUnit( event )
    local caster = event.caster
    local item = event.ability
    local playerID = caster:GetPlayerOwnerID()
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)

    local item_ability = EntIndexToHScript(item:GetEntityIndex())
    local item_ability_name = item_ability:GetAbilityName()

    -- Get tied ability
    local train_ability_name = string.gsub(item_ability_name, "item_", "")
    local train_ability = caster:FindAbilityByName(train_ability_name)
    local gold_cost = train_ability:GetSpecialValueFor("gold_cost")
    local lumber_cost = train_ability:GetSpecialValueFor("lumber_cost")
    --print(string.format("%s (L%s) costs %s gold and %s lumber.", train_ability_name, train_ability:GetLevel(), gold_cost, lumber_cost))

    print("Start dequeue")
    for itemSlot = 0, 5, 1 do
        local item = caster:GetItemInSlot( itemSlot )
        if item ~= nil then
            local current_item = EntIndexToHScript(item:GetEntityIndex())

            if current_item == item_ability then
                --print("Q")
                --DeepPrintTable(caster.queue)
                local queue_element = getIndex(caster.queue, item:GetEntityIndex())
                --print(item:GetEntityIndex().." in queue at "..queue_element)
                table.remove(caster.queue, queue_element)

                UTIL_Remove(item)
                
                -- Refund ability cost
                PlayerResource:ModifyGold(playerID, gold_cost, false, 0)
                ModifyLumber(hero, lumber_cost)
                print(string.format("Refunding %s gold and %s lumber.", gold_cost, lumber_cost))

                -- Set not channeling if the cancelled item was the first slot
                if itemSlot == 0 then

                    train_ability:SetChanneling(false)
                    train_ability:EndChannel(true)
                    print("Cancel current channel")

                    -- Remove Research Particle Effect
                    caster:RemoveModifierByName("modifier_research_purple")

                    -- Fake mana channel bar
                    caster:SetMana(0)
                    caster:SetBaseManaRegen(0)
                else
                    print("Removed unit in queue slot",itemSlot)                    
                end
                ReorderItems(caster)
                break
            end
        end
    end
end

-- Moves on to the next element of the queue
function NextQueue( event )
    local caster = event.caster
    local ability = event.ability
    ability:SetChanneling(false)
    --print("Move next!")

    -- Dequeue
    --DeepPrintTable(event)
    local hAbility = EntIndexToHScript(ability:GetEntityIndex())

    for itemSlot = 0, 5, 1 do
        local item = caster:GetItemInSlot( itemSlot )
        if item ~= nil then
            local item_name = tostring(item:GetAbilityName())

            -- Remove the "item_" to compare
            local train_ability_name = string.gsub(item_name, "item_", "")

            if train_ability_name == hAbility:GetAbilityName() then

                local train_ability = caster:FindAbilityByName(train_ability_name)

                --print("Q")
                --DeepPrintTable(caster.queue)
                local queue_element = getIndex(caster.queue, item:GetEntityIndex())
                if IsValidEntity(item) then
                    --print(item:GetEntityIndex().." in queue at "..queue_element)
                    table.remove(caster.queue, queue_element)
                    UTIL_Remove(item)
                end

                break
            elseif item then
                --print(item_name,hAbility:GetAbilityName())
            end
        end
    end
end

QUEUE_THINK_TIME = 0.1
function StartQueue(caster)
    Timers:CreateTimer(QUEUE_THINK_TIME, function()
        if not IsValidEntity(caster) or not caster:IsAlive() then return end

        AdvanceQueue(caster)
        return QUEUE_THINK_TIME
    end)
end

function AdvanceQueue(caster)
    local bChanneling = caster:IsChanneling()
    if not bChanneling then
        caster:SetMana(0)
        caster:SetBaseManaRegen(0)
    end

    if bChanneling or caster:IsUnderConstruction() then
        return QUEUE_THINK_TIME
    end

    -- RemakeQueue
    caster.queue = {}

    -- Check the first item that contains "train" on the queue
    for itemSlot=0,5 do
        local item = caster:GetItemInSlot(itemSlot)
        if item and IsValidEntity(item) then

            table.insert(caster.queue, item:GetEntityIndex())

            local item_name = tostring(item:GetAbilityName())
            -- Items that contain "train" "revive" or "research" will start a channel of an ability with the same name without the item_ affix
            if string.find(item_name, "train_") or string.find(item_name, "_revive") or string.find(item_name, "research_") then
                -- Find the name of the tied ability-item: 
                --  ability = human_train_footman
                --  item = item_human_train_footman
                local train_ability_name = string.gsub(item_name, "item_", "")

                local ability_to_channel = caster:FindAbilityByName(train_ability_name)

                ability_to_channel:SetChanneling(true)
                print("->"..ability_to_channel:GetAbilityName()," started channel")

                -- Add Research Particle Effect -- cows
                ApplyModifier(caster, "modifier_research_purple")

                -- Play A Sound -- cows
                EmitSoundOn("BarracksMaster.Training", caster)

                -- Fake mana channel bar
                local channel_time = ability_to_channel:GetChannelTime()
                caster:SetMana(0)
                caster:SetBaseManaRegen(caster:GetMaxMana()/channel_time)

                -- Cheats
                if GameRules.WarpTen then
                    ability_to_channel:EndChannel(false)
                    ReorderItems(caster)
                    return QUEUE_THINK_TIME
                end

                -- After the channeling time, check if it was cancelled or spawn it
                -- EndChannel(false) runs whatever is in the OnChannelSucceded of the function
                local time = ability_to_channel:GetChannelTime()
                Timers:CreateTimer(time, function()
                    --print("===Queue Table====")
                    --DeepPrintTable(caster.queue)
                    if IsValidEntity(item) then
                        ability_to_channel:EndChannel(false)
                        ReorderItems(caster)
                        --print("Unit finished building")
                        
                        -- Remove Research Particle Effect
                        caster:RemoveModifierByName("modifier_research_purple")
                    else
                        --print("This unit was interrupted")
                    end
                end)

            -- Items that contain "research_" will start a channel of an ability with the same name  without the item_ affix
            elseif string.find(item_name, "research_") then
                -- Find the name of the tied ability-item: 
                --  ability = human_research_defend
                --  item = item_human_research_defend
                local research_ability_name = string.gsub(item_name, "item_", "")

                local ability_to_channel = caster:FindAbilityByName(research_ability_name)
                if ability_to_channel then
                    ability_to_channel:SetChanneling(true)
                    print("->"..ability_to_channel:GetAbilityName()," started channel")

                    -- Add Research Particle Effect -- cows
                    ApplyModifier(caster, "modifier_research_purple")

                    -- Play A Sound -- cows
                    EmitSoundOn("BarracksMaster.Training", caster)

                    -- Fake mana channel bar
                    local channel_time = ability_to_channel:GetChannelTime()
                    caster:SetMana(0)
                    caster:SetBaseManaRegen(caster:GetMaxMana()/channel_time)

                    -- Cheats
                    if GameRules.WarpTen then
                        ability_to_channel:EndChannel(false)
                        ReorderItems(caster)
                        return QUEUE_THINK_TIME
                    end

                    -- After the channeling time, check if it was cancelled or spawn it
                    -- EndChannel(false) runs whatever is in the OnChannelSucceded of the function
                    Timers:CreateTimer(ability_to_channel:GetChannelTime(), function()
                        --print("===Queue Table====")
                        --DeepPrintTable(caster.queue)
                        if IsValidEntity(item) then
                            ability_to_channel:EndChannel(false)
                            ReorderItems(caster)
                            print("Research complete!")

                            -- Remove Research Particle Effect
                            caster:RemoveModifierByName("modifier_research_purple")

                        else
                            --print("This Research was interrupted")
                        end
                    end)
                end
            end
        end
    end
end

-- Goes through every ability and item, checking for any ability being channelled
function CDOTA_BaseNPC:IsChanneling()
    
    for abilitySlot=0,15 do
        local ability = self:GetAbilityByIndex(abilitySlot)
        if ability and ability:IsChanneling() then 
            return true
        end
    end

    for itemSlot=0,5 do
        local item = self:GetItemInSlot(itemSlot)
        if item and item:IsChanneling() then
            return true
        end
    end

    return false
end

-- Takes all items and puts them 1 slot back
function ReorderItems( caster )
    local slots = {}
    for itemSlot = 0, 5, 1 do

        -- Handle the case in which the caster is removed
        local item
        if IsValidEntity(caster) then
            item = caster:GetItemInSlot( itemSlot )
        end

        if item ~= nil then
            table.insert(slots, itemSlot)
        end
    end

    for k,itemSlot in pairs(slots) do
        caster:SwapItems(itemSlot,k-1)
    end
end