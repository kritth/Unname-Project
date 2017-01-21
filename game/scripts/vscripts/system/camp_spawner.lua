CAMP_SPAWN_INTERVAL = 15
local CHASE_RANGE = 2000

if not CampSpawner then
	CampSpawner = class({})
end

function CampSpawner:Init()
	CampSpawner:CreateSpawner("teve_camp_spawner_test_001")
end

function CampSpawner:CreateSpawner(e_name)
	local dummy_skill = "dummy_unit"
	local point = Entities:FindByName(nil, e_name):GetAbsOrigin()
	local dummy = CreateUnitByName("npc_dummy_spawner", point, true, nil, nil, DOTA_TEAM_NEUTRALS)
	dummy:AddAbility(e_name)
	dummy:AddAbility(dummy_skill)
	dummy:FindAbilityByName(e_name):SetLevel(1)
	dummy:FindAbilityByName(dummy_skill):SetLevel(1)
	dummy.activate = true		-- For Performance gain later
end

function spawn_monster( keys )
	local unit = keys.caster
	local point = unit:GetAbsOrigin()
	local monster_list = keys.monster_list
	local monster_count = 0
	
	-- Call units back
	if unit.monster_list then
		for k, v in pairs(unit.monster_list) do
			local monster = EntIndexToHScript(v)
			if monster then
				local distance = (unit:GetAbsOrigin() - monster:GetAbsOrigin()):Length()
				if distance > CHASE_RANGE then
					monster:MoveToPosition(unit:GetAbsOrigin())
				end
			end
		end
	end
	
	-- Check spawner
	if unit and unit.activate == true and math.mod(math.floor(GameRules:GetGameTime()), CAMP_SPAWN_INTERVAL) == 0 then
		if not unit.monster_list then
			unit.monster_list = { }
			for k, v in pairs(monster_list) do
				for i = 0, tonumber(v) - 1 do
					local monster = CreateUnitByName(k, point, true, nil, nil, DOTA_TEAM_NEUTRALS)
					table.insert(unit.monster_list, monster:entindex())
				end
			end
		else
			-- Check if any monster is left
			for k, v in pairs(unit.monster_list) do
				local monster = EntIndexToHScript(v)
				if monster and monster:IsAlive() then
					monster_count = monster_count + 1
				end
			end
			
			if monster_count <= 0 then
				unit.monster_list = nil
			end
		end
	end
end