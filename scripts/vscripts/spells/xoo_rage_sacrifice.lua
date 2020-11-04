xoo_rage_sacrifice = class({})

--------------------------------------------------------------------------------
function modifier_xoo_rage_sacrifice_drain(keys)
	local new_hp = keys.caster:GetHealth() - (keys.UnholyHealthDrainPerSecond * keys.UnholyHealthDrainInterval)
	
	if new_hp < 1 then  --Armlet cannot kill the caster from its HP drain.
		new_hp = 1
	end
	
	keys.caster:SetHealth(new_hp)
end