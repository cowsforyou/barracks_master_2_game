if not Gathering then
    Gathering = class({})
end

function Gathering:Init()
    CustomGameEventManager:RegisterListener("tree_gather_order", Dynamic_Wrap(Gathering, "OnRightClick"))
    LinkLuaModifier("modifier_carrying_lumber","libraries/modifiers/modifier_carrying_lumber",LUA_MODIFIER_MOTION_NONE)
    self.Particle = {}
    self.Workers = {}

    GameRules.WarpTen = true -- Turn this off after finishing testing!
end

function Gathering:SpawnMapEntities()
    self.Trees = {} -- Holds all the trees
    local maxTree1 = MapSettings:GetData("maxTree1")
    local maxTree2 = MapSettings:GetData("maxTree2")

    for t=1,maxTree1 do
        local ent = Entities:FindByName(nil, "giant_tree_1_"..t)
        if not ent then
            print("ERROR: No Giant Trees 1 found ")
        else
            local name = "giant_tree_1"
            local position = ent:GetAbsOrigin()
            local angles = ent:GetAngles()
            local teamNumber = DOTA_TEAM_NEUTRALS

            -- Create the unit
            BuildingHelper:SnapToGrid(5, position)
            local blockers = BuildingHelper:BlockGridSquares(BuildingHelper:GetConstructionSize(name), BuildingHelper:GetBlockPathingSize(name), position)
            local tree = CreateUnitByName(name, position, false, nil, nil, teamNumber)
            tree:SetNeverMoveToClearSpace(true)
            tree:SetAngles(angles.x, angles.y, angles.z)
            tree.blockers = blockers

            -- Remove the Hammer entity
            UTIL_Remove(ent)

            -- Add to table
            table.insert(self.Trees, tree)
        end
    end

    for Tree2=1,maxTree2 do
        local ent = Entities:FindByName(nil, "giant_tree_2_"..Tree2)
        if not ent then
            print("ERROR: No Giant Trees 2 found ")
        else
            local name = "giant_tree_2"
            local position = ent:GetAbsOrigin()
            local angles = ent:GetAngles()
            local teamNumber = DOTA_TEAM_NEUTRALS

            -- Create the unit
            BuildingHelper:SnapToGrid(5, position)
            local blockers = BuildingHelper:BlockGridSquares(5, 5, position)
            local tree = CreateUnitByName(name, position, false, nil, nil, teamNumber)
            tree:SetNeverMoveToClearSpace(true)
            tree:SetAngles(angles.x, angles.y, angles.z)
            tree.blockers = blockers

            -- Remove the Hammer entity
            UTIL_Remove(ent)

            -- Add to table
            table.insert(self.Trees, tree)
        end
    end
end

function Gathering:FindClosestTree(position)
    local closestTree
    local minDistance = math.huge
    for _,tree in pairs(Gathering.Trees) do
        local distance = (tree:GetAbsOrigin() - position):Length()
        if distance < minDistance then
            closestTree = tree
            minDistance = distance
        end
        -- potential issue: need to have vision of the trees?
    end
    return closestTree
end

function SpawnWorker(event)
    local ability = event.ability
    local name = event.workerName
    local spawner = event.caster
    local position = spawner:GetAbsOrigin() + RandomVector(250)
    local playerID = spawner:GetPlayerOwnerID()
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    local max_count = ability:GetSpecialValueFor("max_count")

    -- Recreate the table, check max count
    local workers = {}
    local count = 0
    Gathering.Workers[playerID] = Gathering.Workers[playerID] or {}
    for _,unit in pairs(Gathering.Workers[playerID]) do
        if IsValidEntity(unit) and unit:IsAlive() then
            table.insert(workers, unit)
            count = count + 1
        end
    end
    Gathering.Workers[playerID] = workers

    if count >= max_count then
        SendErrorMessage(playerID, "#error_max_worker_count_reached")
        hero:ModifyGold(ability:GetGoldCost(1), false, 0)
        return
    end

    local worker = CreateUnitByName(name,position,true,hero,hero,spawner:GetTeamNumber())
    worker:SetControllableByPlayer(playerID,true)
    worker:SetRenderColor(191,0,255)

    -- Add the worker to the table
    table.insert(Gathering.Workers[playerID], worker)   

    function worker:GatherFromNearestTree()
        local origin = worker:GetAbsOrigin()
        local closestTree = Gathering:FindClosestTree(origin)
        if closestTree then
            worker:GatherFromTargetTree(closestTree)
        end
    end

    function worker:FindClearSpaceAroundTree(tree)
        local points = {}
        local size = 32
        local angle = 360/size*2
        local center = tree:GetAbsOrigin()
        local origin = worker:GetAbsOrigin()
        for i=0,size-1 do
            local rotate_pos = center + Vector(1,0,0) * 150
            local point = RotatePosition(center, QAngle(0, angle*i, 0), rotate_pos)
            table.insert(points, point)
        end
        table.sort(points, function(a,b) return (a-origin):Length2D()<(b-origin):Length2D() end) --sort by distance
        local teamNumber = worker:GetTeamNumber()
        for k,point in pairs(points) do
            if not GridNav:IsBlocked(point) then
                local units = FindUnitsInRadius(teamNumber,point,nil,size,DOTA_UNIT_TARGET_TEAM_BOTH,DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO,0,0,false)
                if #units == 0 or #units == 1 and units[1] == worker then
                    --DebugDrawCircle(point,Vector(0,255,0),100,size,true,10)
                    return point
                else
                    --DebugDrawCircle(point,Vector(255,0,0),100,size,true,10)
                end
            end
        end

        return center
    end

    function worker:GatherFromTargetTree(tree)
        if worker.gathering_timer then Timers:RemoveTimer(worker.gathering_timer) end
        worker:RemoveGesture(ACT_DOTA_ATTACK)

        -- Move towards the tree
        worker.target_tree = tree
        local position = worker:FindClearSpaceAroundTree(tree)
        ExecuteOrderFromTable({UnitIndex = worker:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION, Position = position, Queue = false}) 

        worker.gathering_timer = Timers:CreateTimer(function()
            if not IsValidEntity(worker) or not worker:IsAlive() then return end
            if not IsValidEntity(worker.target_tree) or not worker.target_tree:IsAlive() then
                -- If the target tree is killed, find a new one
            else
                local distance = (worker.target_tree:GetAbsOrigin() - worker:GetAbsOrigin()):Length()

                -- When close, start chopping, give carrying modifier
                if distance > 230 then
                    return 0.1
                else
                    -- When full or tree killed, go back
                    local continue = worker:DamageTree(worker.target_tree)
                    if not continue then
                        worker:ReturnLumber()                
                    else
                        return 1
                    end
                end
            end
        end)
    end

    function worker:DamageTree(tree)
        worker:StartGesture(ACT_DOTA_ATTACK)
        worker.lumber_gathered = worker.lumber_gathered or 0
        if not worker:HasModifier("modifier_carrying_lumber") then
            worker:AddNewModifier(worker,nil,"modifier_carrying_lumber",{})
        end

        if tree:GetHealth() > 0 then
            worker.lumber_gathered = worker.lumber_gathered + 1
            worker:SetModifierStackCount("modifier_carrying_lumber",worker,worker.lumber_gathered)
            tree:SetHealth(tree:GetHealth()-1)
            return worker.lumber_gathered < 10 --max
        else
            tree:ForceKill(true)
            return false
        end
    end

    function worker:ReturnLumber()
        local playerID = worker:GetPlayerOwnerID()
        local player = PlayerResource:GetPlayer(playerID)
        local hero = player:GetAssignedHero()
        local buidingList = BuildingHelper:GetBuildings(playerID)
        local origin = worker:GetAbsOrigin()
        local closestBuilding
        local minDistance = math.huge
        for _,building in pairs(buidingList) do
            if IsValidEntity(building) and building:IsAlive() then
                if building:GetUnitName():match("lumber") then -- if is valid lumber deposit, process it. Is the city center a valid deposit?
                    local distance = (building:GetAbsOrigin() - origin):Length()
                    if distance < minDistance then
                        closestBuilding = building
                        minDistance = distance
                    end
                end
            end
        end
        if closestBuilding then
            -- go towards the building

            if worker.gathering_timer then Timers:RemoveTimer(worker.gathering_timer) end
            worker:RemoveGesture(ACT_DOTA_ATTACK)

            -- Move towards the building
            worker.target_building = closestBuilding
            local position = closestBuilding:GetAbsOrigin() + (worker:GetAbsOrigin() - closestBuilding:GetAbsOrigin()):Normalized() * closestBuilding:GetHullRadius()
            ExecuteOrderFromTable({UnitIndex = worker:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION, Position = position, Queue = false}) 

            worker.gathering_timer = Timers:CreateTimer(function()
                if not IsValidEntity(worker) or not worker:IsAlive() then return end
                if not IsValidEntity(worker.target_building) or not worker.target_building:IsAlive() then
                    -- if the target building is killed, find a new one
                else
                    local distance = (worker.target_building:GetAbsOrigin() - worker:GetAbsOrigin()):Length2D()

                    -- When close, deposit and grant the resources, remove the carrying modifier
                    if distance > 250 then
                        return 0.1
                    else
                        ModifyLumber(hero, worker.lumber_gathered)
                        Purifier:EarnedLumber(player, worker.lumber_gathered)
                        if worker.lumber_gathered > 0 then
                            PopupLumber(worker, worker.lumber_gathered)
                        end
                        worker.lumber_gathered = 0
                        worker:RemoveModifierByName("modifier_carrying_lumber")

                        -- go back to the tree where it came, or find a new one if its killed
                        local tree = worker.target_tree
                        if tree and IsValidEntity(tree) and tree:IsAlive() then
                            worker:GatherFromTargetTree(tree)
                        else
                            worker:GatherFromNearestTree()
                        end
                    end
                end
            end)
        end
    end

    -- Should there be a worker:ReturnLumberToTarget(building) to be activated via right-click?

    Timers:CreateTimer(0.1, function()
        worker:RemoveModifierByName("modifier_phased")
        worker:GatherFromNearestTree()
    end)

    if GameRules.WarpTen then
        ability:EndCooldown()
    end
end

function GatherLumber(event)
    local worker = event.caster
    if worker:HasModifier("modifier_carrying_lumber") then
        worker:ReturnLumber()
    else
        worker:GatherFromNearestTree()
    end
end

function Gathering:OnRightClick(event)
    local playerID = event.PlayerID
    local targetIndex = event.target
    local selectedEntities = PlayerResource:GetSelectedEntities(playerID)
    local target = EntIndexToHScript(targetIndex)
    if target:GetUnitName():match("giant_tree") then
        print("Clicked a giant tree")
        if selectedEntities["0"] then
            local mainSelected = EntIndexToHScript(selectedEntities["0"])
            if mainSelected:GetUnitName():match("worker") then
                print("Sending all workers to gather")
                for _,entIndex in pairs(selectedEntities) do
                    local u = EntIndexToHScript(entIndex)
                    u:MoveToPosition(target:GetAbsOrigin()) --cast here
                end
            elseif mainSelected:GetUnitName():match("lumber") then
                if Gathering.Particle[playerID] then
                    ParticleManager:DestroyParticle(Gathering.Particle[playerID],true)
                end

                local particle = ParticleManager:CreateParticleForTeam("particles/custom/range_finder_lumber.vpcf",PATTACH_CUSTOMORIGIN,nil,PlayerResource:GetTeam(playerID))
                ParticleManager:SetParticleControl(particle,2,mainSelected:GetAbsOrigin())
                ParticleManager:SetParticleControl(particle,6,Vector(1,0,0))
                ParticleManager:SetParticleControl(particle,7,target:GetAbsOrigin())
                Gathering.Particle[playerID] = particle
            else
                SendErrorMessage(playerID, "#error_must_use_worker")
            end
        end
    end
end

if not Gathering.Particle then Gathering:Init() end