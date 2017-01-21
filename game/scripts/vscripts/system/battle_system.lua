-- Damage type
-- Associated with damage_type_datadriven.txt
TEVE_PHYSICAL_DAMAGE_TYPE_NORMAL = 0
TEVE_PHYSICAL_DAMAGE_TYPE_HERO = 1
TEVE_PHYSICAL_DAMAGE_TYPE_PIERCING = 2
TEVE_PHYSICAL_DAMAGE_TYPE_BLUNT = 3
TEVE_PHYSICAL_DAMAGE_TYPE_CHAOS = 4
TEVE_MAGICAL_DAMAGE_TYPE_MAGIC = 5
TEVE_MAGICAL_DAMAGE_TYPE_UNIVERSAL = 6
TEVE_MAGICAL_DAMAGE_TYPE_COMPOSITE = 7
TEVE_MAGICAL_DAMAGE_TYPE_PURE = 8
TEVE_MAGICAL_DAMAGE_TYPE_HP_REMOVAL = 9

-- Armor Type
-- Associated with armor_type_datadriven.txt
TEVE_ARMOR_LIGHT = 0
TEVE_ARMOR_HEAVY = 1
TEVE_ARMOR_MAGIC = 2
TEVE_ARMOR_CHAOS = 3
TEVE_ARMOR_DIVINE = 4

-- Call from KV
function UnitTakeDamage( event )
	local damage = event.DamageTaken
	local target = event.caster
	local attacker = event.attacker
	local ability = event.ability
	
	target:Heal(damage, target)
	
	local tab = { }
	
	tab.victim = target
	tab.attacker = attacker
	
	if attacker then
		if ability ~= nil then
			tab.damage = ability:GetAbilityDamage()
			tab.damage_type = ability:GetSpecialValueFor("DamageType")
		else
			tab.damage = attacker:GetAttackDamage()
			tab.damage_type = attacker.stat.damage_type
		end
		
		DealDamage(tab)
	end
end

-- Deal damage system
function DealDamage( tab )
	local victim = tab.victim
	local damage = tab.damage
	local damage_type = tab.damage_type
	
	-- Calculate actual damage deal
	local armor_type = victim.stat.armor_type
	local actual_damage = GetDamage(damage, damage_type, armor_type)
	actual_damage = GetResistance(actual_damage, damage_type, victim.stat)
	
	-- print(victim:GetUnitName() .. ": " .. victim.stat.cur_health .. "/" .. victim.stat.max_health .. " getting " .. actual_damage .. " damage")
	
	-- Placeholder system, not taking armor into consideration
	victim.stat.cur_health = victim.stat.cur_health - actual_damage
	
	-- Add to limitbreak
	Stat:AddLimitBreak(victim:GetPlayerOwnerID(), actual_damage)
end

-- Deduct mana
function DeductMana( tab )
	local ability = tab.ability
	local mana_cost = tab.mana_cost
	local caster = tab.caster
	
	if caster.stat.cur_mana >= mana_cost then
		caster.stat.cur_mana = caster.stat.cur_mana - mana_cost
	else
		caster:Stop()
	end
end

function GetResistance(damage, damage_type, stat)
	local actual_damage = damage
	
	if damage_type < TEVE_MAGICAL_DAMAGE_TYPE_MAGIC then
		actual_damage = actual_damage - stat.physical_fixed
		actual_damage = actual_damage * (1 - stat.physical_percent)
		-- Dodge
	else
		actual_damage = actual_damage - stat.magical_fixed
		actual_damage = actual_damage * (1 - stat.magical_percent)
	end
	
	return actual_damage
end

function GetDamage(damage, damage_type, armor_type)
	local actual_damage = 0
	-- Normal physical damage
	if damage_type == TEVE_PHYSICAL_DAMAGE_TYPE_NORMAL then
		if armor_type == TEVE_ARMOR_LIGHT then
			actual_damage = damage
		elseif armor_type == TEVE_ARMOR_HEAVY then
			actual_damage = damage
		elseif armor_type == TEVE_ARMOR_MAGIC then
			actual_damage = damage
		elseif armor_type == TEVE_ARMOR_CHAOS then
			actual_damage = damage
		elseif armor_type == TEVE_ARMOR_DIVINE then
			actual_damage = damage
		end
	-- Hero physical damage
	elseif damage_type == TEVE_PHYSICAL_DAMAGE_TYPE_HERO then
		if armor_type == TEVE_ARMOR_LIGHT then
			actual_damage = damage
		elseif armor_type == TEVE_ARMOR_HEAVY then
			actual_damage = damage
		elseif armor_type == TEVE_ARMOR_MAGIC then
			actual_damage = damage
		elseif armor_type == TEVE_ARMOR_CHAOS then
			actual_damage = damage
		elseif armor_type == TEVE_ARMOR_DIVINE then
			actual_damage = damage
		end
	-- Piercing physical damage
	elseif damage_type == TEVE_PHYSICAL_DAMAGE_TYPE_PIERCING then
		if armor_type == TEVE_ARMOR_LIGHT then
			actual_damage = damage
		elseif armor_type == TEVE_ARMOR_HEAVY then
			actual_damage = damage
		elseif armor_type == TEVE_ARMOR_MAGIC then
			actual_damage = damage
		elseif armor_type == TEVE_ARMOR_CHAOS then
			actual_damage = damage
		elseif armor_type == TEVE_ARMOR_DIVINE then
			actual_damage = damage
		end
	-- Blunt physical damage
	elseif damage_type == TEVE_PHYSICAL_DAMAGE_TYPE_BLUNT then
		if armor_type == TEVE_ARMOR_LIGHT then
			actual_damage = damage
		elseif armor_type == TEVE_ARMOR_HEAVY then
			actual_damage = damage
		elseif armor_type == TEVE_ARMOR_MAGIC then
			actual_damage = damage
		elseif armor_type == TEVE_ARMOR_CHAOS then
			actual_damage = damage
		elseif armor_type == TEVE_ARMOR_DIVINE then
			actual_damage = damage
		end
	-- Chaos physical damage
	elseif damage_type == TEVE_PHYSICAL_DAMAGE_TYPE_CHAOS then
		if armor_type == TEVE_ARMOR_LIGHT then
			actual_damage = damage
		elseif armor_type == TEVE_ARMOR_HEAVY then
			actual_damage = damage
		elseif armor_type == TEVE_ARMOR_MAGIC then
			actual_damage = damage
		elseif armor_type == TEVE_ARMOR_CHAOS then
			actual_damage = damage
		elseif armor_type == TEVE_ARMOR_DIVINE then
			actual_damage = damage
		end
	elseif damage_type == TEVE_MAGICAL_DAMAGE_TYPE_MAGIC then
		if armor_type == TEVE_ARMOR_LIGHT then
			actual_damage = damage
		elseif armor_type == TEVE_ARMOR_HEAVY then
			actual_damage = damage
		elseif armor_type == TEVE_ARMOR_MAGIC then
			actual_damage = damage
		elseif armor_type == TEVE_ARMOR_CHAOS then
			actual_damage = damage
		elseif armor_type == TEVE_ARMOR_DIVINE then
			actual_damage = damage
		end
	elseif damage_type == TEVE_MAGICAL_DAMAGE_TYPE_UNIVERSAL then
		if armor_type == TEVE_ARMOR_LIGHT then
			actual_damage = damage
		elseif armor_type == TEVE_ARMOR_HEAVY then
			actual_damage = damage
		elseif armor_type == TEVE_ARMOR_MAGIC then
			actual_damage = damage
		elseif armor_type == TEVE_ARMOR_CHAOS then
			actual_damage = damage
		elseif armor_type == TEVE_ARMOR_DIVINE then
			actual_damage = damage
		end
	elseif damage_type == TEVE_MAGICAL_DAMAGE_TYPE_COMPOSITE then
		if armor_type == TEVE_ARMOR_LIGHT then
			actual_damage = damage
		elseif armor_type == TEVE_ARMOR_HEAVY then
			actual_damage = damage
		elseif armor_type == TEVE_ARMOR_MAGIC then
			actual_damage = damage
		elseif armor_type == TEVE_ARMOR_CHAOS then
			actual_damage = damage
		elseif armor_type == TEVE_ARMOR_DIVINE then
			actual_damage = damage
		end
	elseif damage_type == TEVE_MAGICAL_DAMAGE_TYPE_PURE then
		if armor_type == TEVE_ARMOR_LIGHT then
			actual_damage = damage
		elseif armor_type == TEVE_ARMOR_HEAVY then
			actual_damage = damage
		elseif armor_type == TEVE_ARMOR_MAGIC then
			actual_damage = damage
		elseif armor_type == TEVE_ARMOR_CHAOS then
			actual_damage = damage
		elseif armor_type == TEVE_ARMOR_DIVINE then
			actual_damage = damage
		end
	-- Nothing negate this type of damage
	elseif damage_type == TEVE_MAGICAL_DAMAGE_TYPE_HP_REMOVAL then
		actual_damage = damage
	end
	
	return actual_damage
end