-- Returns Int
function GetGoldCost( unit )
	if unit and IsValidEntity(unit) then
		if unit.GoldCost then
			return unit.GoldCost
		end
	end
	return 0
end

function GetGoldCostForStructures( unit )
	if unit and IsValidEntity(unit) then
		if unit.gold_cost then
			return unit.gold_cost
		end
	end
	return 0
end

function GetLumberCostForStructures( unit )
	if unit and IsValidEntity(unit) then
		if unit.lumber_cost then
			return unit.lumber_cost
		end
	end
	return 0
end