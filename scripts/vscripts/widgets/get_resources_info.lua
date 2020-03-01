-- Returns Int
function GetGoldCost( unit )
	if unit and IsValidEntity(unit) then
		if unit.GoldCost then
			return unit.GoldCost
		end
	end
	return 0
end