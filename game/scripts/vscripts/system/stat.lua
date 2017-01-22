-- Set everything to table
Stat = { }
local Stat_mt = { __index = Stat }
local ENGINE_HEALTH_PER_STRENGTH_CONSTANT = 20 -- Defined by the game
local HEALTH_PER_STRENGTH_CONSTANT = 20
local ENGINE_MANA_PER_INTELLECT_CONSTANT = 12 -- Defined by the game
local MANA_PER_INTELLECT_CONSTANT = 15
local ENGINE_AGILITY_PER_ARMOR_CONSTANT = 7 -- Defined by the game
local AGILITY_PER_ARMOR_CONSTANT = 12

local LIMIT_BREAK_THRESHOLD = 100000
local TEMP_HEALTH_BUFFER = 1000000

-- Attaching necessary system
local ability_name = "teve_stat"
local mod = {}
mod[1] = "modifier_negate_health"
mod[2] = "modifier_negate_armor"
mod[3] = "modifier_negate_mana"
mod[4] = "modifier_health_regen"
mod[5] = "modifier_mana_regen"
mod[6] = "modifier_refund_health"

-- Limit break
local limit_break = { }

-- Modifier values
local bitTable = {32768, 16384, 8192, 4096, 2048, 1024, 512,256,128,64,32,16,8,4,2,1}

function Stat:Attach(unit)
	if unit then
		unit.stat = Stat:new( unit:entindex() )
		
		-- In order for caster to become correct unit
		unit:AddAbility(ability_name)
		local ability = unit:FindAbilityByName(ability_name)
		if ability ~= nil then
			ability:SetLevel(1)
			for k, v in pairs(mod) do
				ability:ApplyDataDrivenModifier(unit, unit, v, { duration = -1 })
			end
		end
		
		unit:RemoveAbility(ability_name)
		
		-- Adding limit break
		local player_id = unit:GetPlayerOwnerID()
		if not limit_break[player_id] then
			limit_break[player_id] = { }
			limit_break[player_id].enable = false
			limit_break[player_id].damage_taken = 0
		end
	end
end

function Stat:Detach(unit)
	if unit then
		for k, v in pairs(mod) do
			unit:RemoveModifierByName(v)
		end
		unit.stat = nil
	end
end

function Stat:AddLimitBreak(player_id, damage)
	if limit_break[player_id] and limit_break[player_id].enable == true then
		if limit_break[player_id].damage_taken < LIMIT_BREAK_THRESHOLD then
			limit_break[player_id].damage_taken = limit_break[player_id].damage_taken + damage
		else
			limit_break[player_id].damage_taken = LIMIT_BREAK_THRESHOLD
		end
		
		-- print ("Current limit break meter: " .. limit_break[player_id].damage_taken .. "/" .. LIMIT_BREAK_THRESHOLD)
	end
end

function Stat:new(entindex)
	local newStat = { }
	newStat.index = entindex
	newStat.unit = EntIndexToHScript( entindex )
	
	-- Storing old value
	if newStat.unit:IsHero() then
		newStat.base_health = 100
		newStat.base_mana = 100
		
		-- Add new health tracker
		update_max_health( newStat )
		newStat.cur_health = newStat.max_health
		
		update_max_mana( newStat )
		newStat.cur_mana = newStat.max_mana
	else
		-- Placeholder for monster for now
		newStat.base_health = newStat.unit:GetBaseMaxHealth()
		newStat.cur_health = newStat.base_health
		newStat.max_health = newStat.base_health
		
		newStat.base_mana = newStat.unit:GetMaxMana()
		newStat.cur_mana = newStat.base_mana
		newStat.max_mana = newStat.base_mana
		
		newStat.unit:SetBaseMaxHealth(100)
	end
	
	-- Set resistance value
	newStat.physical_fixed = 0
	newStat.physical_percent = 0
	newStat.physical_dodge = 0
	
	newStat.magical_fixed = 0
	newStat.magical_percent = 0
	newStat.magical_dodge = 0
	
	Timers:CreateTimer(0.5, function()
			if newStat.unit:GetAbilityCount() > 0 then
				local i = 0
				while i < 16 do
					if newStat.unit:GetAbilityByIndex(i) and (
						newStat.unit:GetAbilityByIndex(i):GetAbilityName() == "teve_damage_type_normal" or
						newStat.unit:GetAbilityByIndex(i):GetAbilityName() == "teve_damage_type_hero" or
						newStat.unit:GetAbilityByIndex(i):GetAbilityName() == "teve_damage_type_piercing" or
						newStat.unit:GetAbilityByIndex(i):GetAbilityName() == "teve_damage_type_blunt" or
						newStat.unit:GetAbilityByIndex(i):GetAbilityName() == "teve_damage_type_chaos" or
						newStat.unit:GetAbilityByIndex(i):GetAbilityName() == "teve_damage_type_magic" or
						newStat.unit:GetAbilityByIndex(i):GetAbilityName() == "teve_damage_type_universal" or
						newStat.unit:GetAbilityByIndex(i):GetAbilityName() == "teve_damage_type_composite" or
						newStat.unit:GetAbilityByIndex(i):GetAbilityName() == "teve_damage_type_pure" or
						newStat.unit:GetAbilityByIndex(i):GetAbilityName() == "teve_damage_type_hp_removal" or
						newStat.unit:GetAbilityByIndex(i):GetAbilityName() == "teve_armor_type_light" or
						newStat.unit:GetAbilityByIndex(i):GetAbilityName() == "teve_armor_type_heavy" or
						newStat.unit:GetAbilityByIndex(i):GetAbilityName() == "teve_armor_type_magic" or
						newStat.unit:GetAbilityByIndex(i):GetAbilityName() == "teve_armor_type_chaos" or
						newStat.unit:GetAbilityByIndex(i):GetAbilityName() == "teve_armor_type_divine"
					) then
						newStat.unit:GetAbilityByIndex(i):SetLevel(1)
					end
					i = i + 1
				end
			end
		end
	)
	
	return setmetatable( newStat, Stat_mt )
end

function assign_damage( keys )
	local unit = keys.caster
	local damage_type = keys.damage_type
	unit.stat.damage_type = damage_type
end

function assign_armor( keys )
	local unit = keys.caster
	local armor_type = keys.armor_type
	unit.stat.armor_type = armor_type
end

function update_max_health( newStat )
	if newStat then
		newStat.max_health = newStat.base_health + (newStat.unit:GetStrength() * HEALTH_PER_STRENGTH_CONSTANT)
	end
end

function update_max_mana( newStat )
	if newStat then
		newStat.max_mana = newStat.base_mana + (newStat.unit:GetIntellect() * MANA_PER_INTELLECT_CONSTANT)
	end
end

function update_health( keys )
	local unit = keys.caster
	local ability = unit:GetAbilityByIndex(0)
	local tick_amount = 1.00 / 0.03
	local health_regen_per_tick = unit:GetHealthRegen() / tick_amount
	
	-- Do regen
	if unit and unit.stat then
		if unit.stat.cur_health < unit.stat.max_health then
			unit.stat.cur_health = unit.stat.cur_health + health_regen_per_tick
		end
		
		if unit.stat.cur_health > unit.stat.max_health then
			unit.stat.cur_health = unit.stat.max_health
		end
		
		if unit.stat.cur_health > 0 then
			unit:SetHealth((unit.stat.cur_health / unit.stat.max_health) * 100)
			
			if not unit:IsAlive() or unit:GetMaxHealth() > 100 then
				unit:SetBaseMaxHealth(TEMP_HEALTH_BUFFER)
				unit:SetMaxHealth(TEMP_HEALTH_BUFFER)
				unit:SetHealth(TEMP_HEALTH_BUFFER)
				
				remove_mod(unit, "modifier_health_mod_")
				unit.stat.strBonus = 0
				
				unit:SetBaseMaxHealth(100)
				unit:SetMaxHealth(100)
			end
		else
			Stat:Detach(unit)
			unit:ForceKill(false)
		end
	end
end

function update_mana( keys )
	local unit = keys.caster
	local tick_amount = 1.00 / 0.03
	local mana_regen_per_tick = (unit:GetStatsBasedManaRegen() + unit:GetPercentageBasedManaRegen()) / tick_amount
	-- Do regen
	if unit and unit.stat then
		if unit.stat.cur_mana < unit.stat.max_mana then
			unit.stat.cur_mana = unit.stat.cur_mana + mana_regen_per_tick
		end
		
		if unit.stat.cur_mana > unit.stat.max_mana then
			unit.stat.cur_mana = unit.stat.max_mana
		end
		
		if unit.stat.cur_mana > 0 then
			unit:SetMana((unit.stat.cur_mana / unit.stat.max_mana) * 100)
			
			if unit:GetMana() < 0 or unit:GetMaxMana() < 0 or unit:GetMaxMana() > 100 then
				unit:SetMana(100)
			
				remove_mod(unit, "modifier_mana_mod_")
				unit.stat.intBonus = 0
				
				unit:SetMana(0)
			end
		else
			unit.stat.cur_mana = 0
			unit:SetMana(0)
		end
	end
end

function negate_health_gain( keys )
	local unit = keys.caster
	
	if not unit or not unit:IsHero() then return nil end
	
	local strength = unit:GetStrength()
 
	--Check if strBonus is stored on hero, if not set it to 0
	if unit.stat.strBonus == nil then
		unit.stat.strBonus = 0
	end
	
	-- If player strength is different this time around, start the adjustment
	if strength ~= unit.stat.strBonus then
		remove_mod(unit, "modifier_health_mod_")
		strength = add_mod(unit, "modifier_health_mod_", "item_health_modifier", strength)
		update_max_health( unit.stat )
	end
	
	-- Updates the stored strength bonus value for next timer cycle
	unit.stat.strBonus = unit:GetStrength()	
end

function negate_mana_gain( keys )
	local unit = keys.caster
	if not unit or not unit:IsHero() then return nil end
	
	local intellect = unit:GetIntellect()
 
	--Check if strBonus is stored on hero, if not set it to 0
	if unit.stat.intBonus == nil then
		unit.stat.intBonus = 0
	end
	
	-- If player strength is different this time around, start the adjustment
	if intellect ~= unit.stat.intBonus then
		remove_mod(unit, "modifier_mana_mod_")
		intellect = add_mod(unit, "modifier_mana_mod_", "item_mana_modifier", intellect)
		update_max_mana( unit.stat )
	end
		
	-- Updates the stored strength bonus value for next timer cycle
	unit.stat.intBonus = unit:GetIntellect()
end

function negate_armor( keys )
	local unit = keys.caster
	
	if unit then
		local new_armor = unit:GetPhysicalArmorBaseValue()
	
		-- Include agility check if it is hero
		if unit:IsHero() then
			new_armor = new_armor + math.floor(unit:GetAgility() / ENGINE_AGILITY_PER_ARMOR_CONSTANT) + 1
		end
		
		if not unit.stat.negate_armor or unit.stat.negate_armor ~= new_armor then
			unit.stat.negate_armor = new_armor
			unit:SetModifierStackCount(mod[2], unit, unit.stat.negate_armor)
			
			if unit:IsHero() then
				unit.stat.armor = unit:GetPhysicalArmorBaseValue() + math.floor(unit:GetAgility() / AGILITY_PER_ARMOR_CONSTANT)
			else
				unit.stat.armor = new_armor
			end
		end
	end
end

function remove_mod(unit, mod_prefix)
	-- Gets the list of modifiers on the hero and loops through removing and health modifier
	local modCount = unit:GetModifierCount()
	for i = 0, modCount do
		for u = 1, #bitTable do
			local val = bitTable[u]
			if unit:GetModifierNameByIndex(i) == mod_prefix .. val  then
				unit:RemoveModifierByName(mod_prefix .. val)
			end
		end
	end
end

function add_mod(unit, mod_prefix, item_name, attribute_val)
	local attr = attribute_val
	
	-- Creates temporary item to steal the modifiers from
	local updater = CreateItem(item_name, nil, nil) 
	for p=1, #bitTable do
		local val = bitTable[p]
		local count = math.floor(attr / val)
		if count >= 1 then
			updater:ApplyDataDrivenModifier(unit, unit, mod_prefix .. val, {})
			attr = attr - val
		end
	end
	
	-- Cleanup
	UTIL_RemoveImmediate(updater)
	updater = nil
	
	return attr
end

return Stat