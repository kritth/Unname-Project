require( 'util/timers' )
require( 'util/debug' )
require( 'system/battle_system' )
require( 'system/stat' )
require( 'level/debug_map' )

if ORPGGameMode == nil then
	ORPGGameMode = class({})
end

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
end

-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = ORPGGameMode()
	GameRules.AddonTemplate:InitGameMode()
end

function ORPGGameMode:InitGameMode()
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
	
	if GetMapName() == "debug_map" then
		GameRules.Map = DebugMap()
		GameRules.Map:InitGameMode()
	end
	
	AttachListeners()
end

-- Evaluate the state of the game
function ORPGGameMode:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--print( "Template addon script is running." )
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end

function AttachListeners()
	
end
