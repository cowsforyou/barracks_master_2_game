xoo_rage_sacrifice = class({})

--------------------------------------------------------------------------------
function Sacrifice(keys)
	local new_hp = keys.target:GetHealth() * 0.8
	
	if new_hp < 1 then  --Cannot kill the caster from its HP drain.
		new_hp = 1
	end
	
	keys.target:SetHealth(new_hp)
end