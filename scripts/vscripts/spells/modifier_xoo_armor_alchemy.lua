modifier_xoo_armor_alchemy = class({})
--------------------------------------------------------------------------------

function modifier_xoo_armor_alchemy:IsDebuff()
	return self:GetParent()~=self:GetAbility():GetCaster()
end

function modifier_xoo_armor_alchemy:IsHidden()
	return self:GetParent()==self:GetAbility():GetCaster()
end

--------------------------------------------------------------------------------

function modifier_xoo_armor_alchemy:IsAura()
	if self:GetCaster() == self:GetParent() then
		if not self:GetCaster():PassivesDisabled() then
			return true
		end
	end
	
	return false
end

function modifier_xoo_armor_alchemy:GetModifierAura()
	return "modifier_xoo_armor_alchemy"
end


function modifier_xoo_armor_alchemy:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_xoo_armor_alchemy:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_xoo_armor_alchemy:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_xoo_armor_alchemy:GetAuraRadius()
	return self.aura_radius
end

function modifier_xoo_armor_alchemy:GetAuraEntityReject( hEntity )
	return not hEntity:CanEntityBeSeenByMyTeam(self:GetCaster())
end
--------------------------------------------------------------------------------

function modifier_xoo_armor_alchemy:OnCreated( kv )
	self.aura_radius = self:GetAbility():GetSpecialValueFor( "aura_radius" )
	self.armor_reduction = self:GetAbility():GetSpecialValueFor( "armor_reduction" )
end

function modifier_xoo_armor_alchemy:OnRefresh( kv )
	self.aura_radius = self:GetAbility():GetSpecialValueFor( "aura_radius" )
	self.armor_reduction = self:GetAbility():GetSpecialValueFor( "armor_reduction" )
end

--------------------------------------------------------------------------------

function modifier_xoo_armor_alchemy:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}

	return funcs
end

function modifier_xoo_armor_alchemy:GetModifierPhysicalArmorBonus( params )
	if self:GetParent() == self:GetCaster() then
		return 0
	end

	return self.armor_reduction
end

--------------------------------------------------------------------------------