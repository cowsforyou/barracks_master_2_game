if not BMCore then
    BMCore = class({})
end

-- Called from GameMode:OnPlayerPickedHero(keys)
function BMCore:InitializeHero(hero)
    print("BMCore:InitializeHero function Initialized", hero)
    DebugPrintTable(hero)
    local playerID = hero:GetPlayerOwnerID() 

    -- Initialize variables for tracking
    hero.units = {} -- This keeps the handle of all the units of the player, to iterate for unlocking upgrades
    hero.structures = {} -- This keeps the handle of the constructed units, to iterate for unlocking upgrades
    hero.buildings = {} -- This keeps the name and quantity of each building
    hero.upgrades = {} -- This kees the name of all the upgrades researched
    hero.lumber = 0 -- Secondary resource of the player
    
    -- Give starting items and resources
    --hero:SetGold(350, false)
    --ModifyLumber(hero, 0)

    hero:AddItemByName("item_travel_boots")
    hero:AddItemByName("item_scout_land")
    hero:AddItemByName("item_last_stand")
    hero:AddItemByName("item_quelling_blade")    
    hero:AddItemByName("item_mines")

    hero:SetGold(8000, false)
    ModifyLumber(hero, 5000)

    -- Remove AbilityPoints and upgrade initial abilities
    hero:SetAbilityPoints(0)
    Upgrades:CheckAbilityRequirements(hero)

    -- Setup Lumber tick
    Timers(function()
        ModifyLumber(hero, LUMBER_PER_TICK)
        return LUMBER_TICK_TIME
    end)
end