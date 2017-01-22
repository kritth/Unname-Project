if DebugMap == nil then
	DebugMap = class({})
end

local XP_PER_LEVEL_TABLE = {}
XP_PER_LEVEL_TABLE[0] = 0
for i = 1, 299 do
	XP_PER_LEVEL_TABLE[i] = XP_PER_LEVEL_TABLE[i - 1] * 1.5 + 200
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
	Convars:RegisterCommand("add_resource", function( cmd )
			return DebugMap:AddResource()
		end, "Add resource", FCVAR_CHEAT
	)
	Convars:RegisterCommand("spend_resource", function( cmd )
			return DebugMap:SpendResource()
		end, "Spend resource", FCVAR_CHEAT
	)
	Convars:RegisterCommand("add_items", function( cmd )
			return DebugMap:AddDebugItems()
		end, "Add debug items", FCVAR_CHEAT
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

function DebugMap:AddResource()
	Economy:ModifyResource(0, 100, 100)
end

function DebugMap:SpendResource()
	Economy:ModifyResource(0, -100, -100)
end

function DebugMap:AddDebugItems()
	local hero = PlayerResource:GetPlayer( tonumber(0) ):GetAssignedHero()
	hero:AddItemByName("item_dummy_1_datadriven")
	hero:AddItemByName("item_dummy_quest_1_datadriven")
	hero:AddItemByName("item_abyssal_blade")
end

-- Transferable codes

function DebugMap:InitGameMode()
	GameRules:SetTreeRegrowTime( 10.0 )
	GameRules:SetFirstBloodActive(false)
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 10 )
    GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 0 )
	
	local mode = GameRules:GetGameModeEntity()
	mode:SetAnnouncerDisabled( true )
	mode:SetFixedRespawnTime( 1.0 )
	mode:SetFogOfWarDisabled( true )
	mode:SetTopBarTeamValuesVisible(false)
    mode:SetBuybackEnabled(false)
	mode:SetStashPurchasingDisabled(true)
	
	-- Leveling setup
	mode:SetCustomXPRequiredToReachNextLevel(XP_PER_LEVEL_TABLE)
	mode:SetUseCustomHeroLevels(true)
	mode:SetCustomHeroMaxLevel(299)
	
	-- Class setup
	GameRules:SetSameHeroSelectionEnabled(true)
	
	-- Economy set up
	GameRules:SetStartingGold(0)
	GameRules:SetGoldPerTick(0)
	mode:SetLoseGoldOnDeath(false)
	
	-- System setup
	ListenToGameEvent( "npc_spawned", Dynamic_Wrap( DebugMap, "OnUnitSpawned" ), self )
	
	-- Item manager set up
	ItemManager:Init()
	
	-- Debug command added
	DebugMap:AddDebugMapCommands()
end

local once = false

function DebugMap:OnGameInProgress()
	if once == false then
		CampSpawner:Init()
		Economy:Init()
		once = true
	end
end

function DebugMap:OnUnitSpawned( keys )
	local unit = EntIndexToHScript( keys.entindex )
	print("unit spawned")
	unit.stat = nil
	if -- List of dummies exception
			unit:GetUnitName() ~= "npc_dummy_unit" or
			unit:GetUnitName() ~= "npc_dummy_spawner" or
			unit:IsItem() then
		-- Attach stat
		Stat:Attach(unit)

		-- Initialize economy system for player if not existed
		Economy:AddResource(unit:GetPlayerOwnerID())
	end
end