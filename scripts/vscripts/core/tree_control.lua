if not TreeControl then
	TreeControl = class({})
end

function TreeControl:SpawnMapEntities()
	local maxTree1 = MapSettings:GetData("maxTree1")
	local maxTree2 = MapSettings:GetData("maxTree2")

	for Tree1=1,maxTree1 do
		local ent = Entities:FindByName(nil, "giant_tree_1_"..Tree1)
		if not ent then
			print("ERROR: No Giant Trees 1 found ")
		else
			local name = "giant_tree_1"
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
		end
	end
end