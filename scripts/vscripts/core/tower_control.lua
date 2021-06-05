if not TowerControl then
    TowerControl = class({})
end

function TowerControl:Init()
    TowerControl.Links = {}
    TowerControl.validTeams = {DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS} --could be a map setting
    for _,teamNumber in pairs(self.validTeams) do
        TowerControl.Links[teamNumber] = {}
    end
    TowerControl.Debug = false -- Turn this off to stop spewing messages from this module
    TowerControl.maximumTowers = 0
    TowerControl.teamToIssueLastStand = nil
end

-- Naming convention is tower_lane[1-X]_tier[1-Y]_team[2-Z]
-- The towers and ancient should have invulnerability link counts but no backdoor protection.
function TowerControl:SpawnMapEntities()
    local maxLanes = MapSettings:GetData("maxLanes")
    local maxTier = MapSettings:GetData("maxTier")

    self:print("Spawn Map Towers")
    for laneNumber=1,maxLanes do

        -- Store towers of each lane for each valid team
        for _,teamNumber in pairs(self.validTeams) do
            TowerControl.Links[teamNumber][laneNumber] = {}
        end

        for tierNumber=1,maxTier do
            local tower_entities = Entities:FindAllByName("tower_lane"..laneNumber.."_tier"..tierNumber.."*")
            TowerControl.maximumTowers = TowerControl.maximumTowers + #tower_entities
            if #tower_entities > 0 then
                self:print("Found "..#tower_entities.." tower entities for lane "..laneNumber.." tier "..tierNumber)

                -- Create for each team
                for _,ent in pairs(tower_entities) do
                    local position = ent:GetAbsOrigin()
                    local name = ent:GetName()
                    local angles = ent:GetAngles()
                    local teamNumber = DOTA_TEAM_GOODGUYS
                    if string.match(name, "team3") then
                        teamNumber = DOTA_TEAM_BADGUYS
                    end

                    -- Create the unit
                    BuildingHelper:SnapToGrid(4, position)
                    local blockers = BuildingHelper:BlockGridSquares(4, 4, position)
                    local tower = CreateUnitByName(name, position, false, nil, nil, teamNumber)
                    tower:SetNeverMoveToClearSpace(true)
                    tower:SetAngles(angles.x, angles.y, angles.z)
                    tower:AddNewModifier(nil, nil, "modifier_disable_turning", {})
                    tower:SetEntityName(name)
                    tower.tier = tierNumber
                    tower.lane = laneNumber
                    tower.blockers = blockers
                    tower.invulnCount = tierNumber-1

                    -- radiant towers also have a pedestal that spawns below them
                    local pedestalName = GetUnitKV(name, "PedestalModel")
                    if pedestalName then
                        BuildingHelper:CreatePedestalForBuilding(tower, name, position, pedestalName)
                    end

                    -- Store a direct reference to this tower tier
                    TowerControl.Links[teamNumber][laneNumber][tierNumber] = tower

                    -- Set invulnerability charges
                    if tower.invulnCount > 0 then
                        local invulnModifier = tower:AddNewModifier(tower, nil, "modifier_invulnerable", {})
                        if invulnModifier then
                            invulnModifier:SetStackCount(tower.invulnCount)
                        end
                    end

                    self:print("\tSpawned "..name.." - Team ".. teamNumber.." - Invuln Count "..tower.invulnCount.." - Position: "..VectorString(position))

                    -- Remove the Hammer entity
                    UTIL_Remove(ent)
                end
            end
        end
    end

    self:print("Spawning Map Ancients")
    for _,teamNumber in pairs(self.validTeams) do
        local ent = Entities:FindByName(nil, "ancient_team"..teamNumber)
        if not ent then
            self:print("ERROR: No ancient for team "..teamNumber)
        else
            local position = ent:GetAbsOrigin()
            local name = ent:GetName()
            local angles = ent:GetAngles()

            local construction_size = BuildingHelper:GetConstructionSize(name)
            local pathing_size = BuildingHelper:GetBlockPathingSize(name)
            BuildingHelper:SnapToGrid(construction_size, position)
            local blockers = BuildingHelper:BlockGridSquares(construction_size, pathing_size, position)
            local ancient = CreateUnitByName("ancient_team"..teamNumber, position, false, nil, nil, teamNumber)
            ancient:SetNeverMoveToClearSpace(true)
            ancient:SetAngles(angles.x, angles.y, angles.z)
            ancient.blockers = blockers
            ancient.tier = maxTier -- Used to know when we should disable the invulnerability
            ancient.winOnKill = true -- Used to set game winner when killed
            ancient:SetHullRadius(320)

            local invulnModifier = ancient:AddNewModifier(ancient, nil, "modifier_invulnerable", {})

            -- Keep a reference
            TowerControl.Links[teamNumber]['ancient'] = ancient

            -- Remove the Hammer entity
            UTIL_Remove(ent)
        end
    end
end

-- Perform actions when a tower is killed
function TowerControl:OnTowerKilled(unit)
    local teamNumber = unit:GetTeamNumber()
    local towerTable = TowerControl.Links[teamNumber][unit.lane]

    self:print("OnTowerKilled")

    -- Remove this tower from the table
    towerTable[unit.tier] = nil

    -- Play effects
    unit:AddNoDraw()
    BuildingHelper:RemoveBuilding(unit)

    -- Award Last Stand charge
    -- local dur = 5.0
    -- Notifications:BottomToTeam(teamNumber, {item="item_last_stand", duration=dur}) 
    -- Notifications:BottomToTeam(teamNumber, {text="&nbsp;", continue=true})
    -- Notifications:BottomToTeam(teamNumber, {text="#give_item_last_stand", continue=true})

    -- local heroList = HeroList:GetAllHeroes()
    -- for _,hero in pairs(heroList) do
    --     if hero:GetTeamNumber() == teamNumber then
    --         local itemName = "item_last_stand"
    --         local lastStandItem = GetItemByName(hero, itemName)
    --         if lastStandItem then
    --             lastStandItem:SetCurrentCharges(lastStandItem:GetCurrentCharges() + 1)
    --         else
    --             hero:AddItemByName(itemName)
    --         end
    --     end
    -- end

    -- Go through the remaining towers in this lane and reduce their invulnerability count
    -- for tier,tower in pairs(towerTable) do
    --     tower.invulnCount = tower.invulnCount - 1
    --     local invulnModifier = tower:FindModifierByName("modifier_invulnerable")
    --     if invulnModifier and invulnModifier:GetStackCount() > 0 then
    --         invulnModifier:SetStackCount(tower.invulnCount)
    --         self:print("Set "..tower:GetUnitName().." invulnerability count to "..tower.invulnCount)
    --     end

    --     if tower.invulnCount == 0 then
    --         tower:RemoveModifierByName("modifier_invulnerable")
    --     end
    -- end

    -- -- Should we make the ancient vulnerable?
    -- local ancient = TowerControl.Links[teamNumber]['ancient']
    -- if IsValidEntity(ancient) and ancient:HasModifier("modifier_invulnerable") and unit.tier == ancient.tier then
    --     self:print("Removed "..ancient:GetUnitName().." invulnerability ")
    --     ancient:RemoveModifierByName("modifier_invulnerable")
    -- end
end

-- self print while Debug flag is turned on
function TowerControl:print(...)
    if self.Debug then
        print('[TowerControl] '.. ...)
    end
end

function TowerControl:VerifyInvulnerabilityCount()
    local maxLanes = MapSettings:GetData("maxLanes")
    local maxTier = MapSettings:GetData("maxTier")

    for _,teamNumber in pairs(self.validTeams) do
        -- Get remaining towers remaining
        local towersRemaining = 0
        for laneNumber=1,maxLanes do
            for tierNumber=1,maxTier do
                local towerEntities = Entities:FindAllByName("tower_lane"..laneNumber.."_tier"..tierNumber.."_team"..teamNumber)
                towersRemaining = towersRemaining + #towerEntities
                self:print("Tower remaining for team "..teamNumber.." : "..towersRemaining)

            end
        end

        -- Remove ancient invulnerability if all towers destroyed
        if towersRemaining == 0 then
            local ancient = TowerControl.Links[teamNumber]['ancient']
            if IsValidEntity(ancient) and ancient:HasModifier("modifier_invulnerable") then
                self:print("Removed "..ancient:GetUnitName().." invulnerability ")
                ancient:RemoveModifierByName("modifier_invulnerable")
            end
        end

        local ancient = TowerControl.Links[teamNumber]['ancient']
        -- End game if ancient is actually dead
        if IsValidEntity(ancient) and not ancient:IsAlive() then
            local team = ancient:GetOpposingTeamNumber() --This would need to change in a multi team scenario
            WebApi.winner = team
            self:print('Setting winner'..team)
        end

        -- Check if invulnerability count matches expected count
        for laneNumber=1,maxLanes do
            for tierNumber=1,maxTier do
                local tower = Entities:FindByName(nil, "tower_lane"..laneNumber.."_tier"..tierNumber.."_team"..teamNumber)
                if not tower then
                    self:print("Tower does not exist for team "..teamNumber)
                else
                    local invulnModifier = tower:FindModifierByName("modifier_invulnerable")
                    if invulnModifier then 
                        local currentInvulnCount = invulnModifier:GetStackCount()
                        self:print("Current invulnerability count for tower_lane"..laneNumber.."_tier"..tierNumber.."_team"..teamNumber..": "..currentInvulnCount)

                        if currentInvulnCount > 0 then
                            -- Check expected invulnerability count
                            local expectedInvulnCount = tierNumber - 1 - (TowerControl.maximumTowers / 2 - towersRemaining)
                            self:print("Expected invulnerability count for tower_lane"..laneNumber.."_tier"..tierNumber.."_team"..teamNumber..": "..expectedInvulnCount)
                        
                            if currentInvulnCount ~= expectedInvulnCount then
                                self:print("Invulnerability count does not match for tower_lane"..laneNumber.."_tier"..tierNumber.."_team"..teamNumber..". Fixing.")
                                if expectedInvulnCount == 0 then
                                    tower:RemoveModifierByName("modifier_invulnerable")
                                else
                                    invulnModifier:SetStackCount(expectedInvulnCount)
                                end

                                tower.invulnCount = expectedInvulnCount
                                TowerControl.teamToIssueLastStand = tower:GetTeamNumber()
                            end
                        end
                    else
                        self:print("Tower has no invulnerability modifier.")
                    end
                end
            end
        end
    end

    -- Award last stand as it was not awarded
    if TowerControl.teamToIssueLastStand ~= nil then
        local teamNumber = TowerControl.teamToIssueLastStand
        local dur = 5.0
        Notifications:BottomToTeam(teamNumber, {item="item_last_stand", duration=dur}) 
        Notifications:BottomToTeam(teamNumber, {text="&nbsp;", continue=true})
        Notifications:BottomToTeam(teamNumber, {text="#give_item_last_stand", continue=true})
        local heroList = HeroList:GetAllHeroes()
        for _,hero in pairs(heroList) do
            if hero:GetTeamNumber() == teamNumber then
                local itemName = "item_last_stand"
                local lastStandItem = GetItemByName(hero, itemName)
                if lastStandItem then
                    lastStandItem:SetCurrentCharges(lastStandItem:GetCurrentCharges() + 1)
                else
                    hero:AddItemByName(itemName)
                end
            end
        end
        TowerControl.teamToIssueLastStand = nil
    end

    if not (WebApi.winner == nil or WebApi.winner == -1) then
        self:print("Game should end. Ancient is destroyed")
        GameRules:SetGameWinner(WebApi.winner)
    end
end

if not TowerControl.Links then TowerControl:Init() end