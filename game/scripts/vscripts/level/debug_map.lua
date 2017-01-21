if DebugMap == nil then
	DebugMap = class({})
end

local XP_PER_LEVEL_TABLE = {}
XP_PER_LEVEL_TABLE[0] = 0
for i = 1, 299 do
	XP_PER_LEVEL_TABLE[i] = XP_PER_LEVEL_TABLE[i - 1] * 1.5 + 200
end

function DebugMap:InitGameMode()
	GameRules:SetTreeRegrowTime( 10.0 )
	
	local mode = GameRules:GetGameModeEntity()
	mode:SetAnnouncerDisabled( true )
	mode:SetFixedRespawnTime( 1.0 )
	mode:SetFogOfWarDisabled( true )
	mode:SetCustomXPRequiredToReachNextLevel(XP_PER_LEVEL_TABLE)
	mode:SetUseCustomHeroLevels(true)
	mode:SetCustomHeroMaxLevel(299)
	
	ListenToGameEvent( "npc_spawned", Dynamic_Wrap( DebugMap, "OnUnitSpawned" ), self )
	
	DebugMap:AddDebugMapCommands()
end

local once = false

function DebugMap:OnGameInProgress()
	if once == false then
		CampSpawner:Init()
		once = true
	end
end

function DebugMap:OnUnitSpawned( keys )
	local unit = EntIndexToHScript( keys.entindex )
	if unit.cstat == nil and unit:GetUnitName() ~= "npc_dummy_unit" then
		-- Attach stat
		unit.stat = Stat:new( keys.entindex )
		
		-- Attaching necessary system
		local ability_name = "teve_stat"
		local mod = {}
		mod[1] = "modifier_negate_health"
		mod[2] = "modifier_negate_armor"
		mod[3] = "modifier_negate_mana"
		mod[4] = "modifier_health_regen"
		mod[5] = "modifier_mana_regen"
		mod[6] = "modifier_refund_health"
		
		unit:AddAbility(ability_name)
		local ability = unit:FindAbilityByName(ability_name)
		if ability ~= nil then
			ability:SetLevel(1)
			for k, v in pairs(mod) do
				ability:ApplyDataDrivenModifier(unit, unit, v, { duration = -1 })
			end
		end
		
		unit:RemoveAbility(ability_name)
	end
end

function DebugMap:AddDebugMapCommands()
	Convars:RegisterCommand("damage_self", function( cmd )
			return DebugMap:DamageSelf()
		end, "Damage self", FCVAR_CHEAT
	)
	Convars:RegisterCommand("burn_mana", function( cmd )
			return DebugMap:BurnMana()
		end, "Use some mana", FCVAR_CHEAT
	)
	Convars:RegisterCommand("lvlup", function( cmd )
			return DebugMap:LevelUp()
		end, "Level up", FCVAR_CHEAT
	)
	Convars:RegisterCommand("lvlmax", function( cmd )
			return DebugMap:LevelMax()
		end, "Max level", FCVAR_CHEAT
	)
	Convars:RegisterCommand("create_unit", function( cmd )
			return DebugMap:CreateUnit()
		end, "Create unit", FCVAR_CHEAT
	)
end

function DebugMap:DamageSelf()
	local hero = PlayerResource:GetPlayer( tonumber(0) ):GetAssignedHero()
	local damage_table = { }
	damage_table.attacker = hero
	damage_table.victim = hero
	damage_table.damage_type = DAMAGE_TYPE_PURE
	damage_table.damage = 100
	ApplyDamage(damage_table)
	print("Hero has " .. hero.stat.cur_health .. "/" .. hero.stat.max_health .. " health")
	print("Restore: " .. hero:GetHealthRegen())
end

function DebugMap:BurnMana()
	local hero = PlayerResource:GetPlayer( tonumber(0) ):GetAssignedHero()
	local ability_name = "teve_ability_template"
	hero:AddAbility(ability_name)
	local ability = hero:FindAbilityByName(ability_name)
	ability:SetLevel(1)
	ability:CastAbility()
	Timers:CreateTimer(0.5, function()
			hero:RemoveAbility(ability_name)
			print("Hero has " .. hero.stat.cur_mana .. "/" .. hero.stat.max_mana .. " mana")
			print("Restore: " .. (hero:GetStatsBasedManaRegen() + hero:GetPercentageBasedManaRegen()))
		end
	)
end

function DebugMap:LevelUp()
	local hero = PlayerResource:GetPlayer( tonumber(0) ):GetAssignedHero()
	hero:HeroLevelUp(true)
end

function DebugMap:LevelMax()
	local hero = PlayerResource:GetPlayer( tonumber(0) ):GetAssignedHero()
	local i = 0
	while i < 300 do
		hero:HeroLevelUp(false)
		i = i + 1
	end
end

function DebugMap:CreateUnit()
	local hero = PlayerResource:GetPlayer( tonumber(0) ):GetAssignedHero()
	CreateUnitByName("npc_dota_creature_gnoll_assassin", hero:GetAbsOrigin(), true, hero, hero, DOTA_TEAM_NEUTRALS)
end