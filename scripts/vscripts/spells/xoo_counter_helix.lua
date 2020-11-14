xoo_counter_helix = class({})
LinkLuaModifier( "modifier_xoo_counter_helix", "spells/modifier_xoo_counter_helix", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Passive Modifier
function xoo_counter_helix:GetIntrinsicModifierName()
	return "modifier_xoo_counter_helix"
end