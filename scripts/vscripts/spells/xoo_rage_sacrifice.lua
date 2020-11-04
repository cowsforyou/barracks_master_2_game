xoo_rage_sacrifice = class({})

--------------------------------------------------------------------------------
function Sacrifice(keys)
	local ability = keys.ability
	local new_hp = keys.target:GetHealth() * ability:GetSpecialValueFor("sacrifice_hp_damage_pct")
	
	if new_hp < 1 then  --Cannot kill the caster from its HP drain.
		new_hp = 1
	end
	
	keys.target:SetHealth(new_hp)
end