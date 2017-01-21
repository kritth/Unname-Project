if not Economy then
	Economy = class({})
end

local GoldTracking = { }
local ShardTracking = { }
local GOLD_UPPER_LIMIT = 1000000
local SHARD_UPPER_LIMIT = 10000

function Economy:AddResource(player_id)
	local player = PlayerResource:GetPlayer(player_id)
	if player and player:IsPlayer() then
		if not GoldTracking[player_id] then
			GoldTracking[player_id] = 0
			ShardTracking[player_id] = 0
		end
	end
end

function Economy:Init()
	ListenToGameEvent( "entity_hurt", Dynamic_Wrap( Economy, "GetBounty" ), self )

	Timers:CreateTimer(0, function()
			Economy:Update()
			return 0.1
		end
	)
end

function Economy:GetBounty( keys )
	local killed_unit = EntIndexToHScript(keys.entindex_killed)
	local attacker = EntIndexToHScript(keys.entindex_attacker)
	
	local player_id = attacker:GetPlayerOwnerID()
	local gold_bounty = killed_unit:GetGoldBounty()
	
	if killed_unit and killed_unit:GetHealth() <= 0 then
		Economy:ModifyResource(player_id, gold_bounty, 0)
	end
end

-- This may not be needed in the future
function Economy:Update()
	for k, v in pairs(GoldTracking) do
		PlayerResource:SetGold(k, v, true)
	end
end

--[[
	Require parameter with following
	- keys.player_id			player id
	- keys.item			item entindex
]]
function Economy:BuyItem( keys )
	local player_gold = GoldTracking[keys.player_id]
	local player_shard = ShardTracking[keys.player_id]
	local item = EntIndexToHScript(keys.item)
	
	if item and item.gold <= player_gold and item.shard <= player_shard then
		Economy:ModifyResource( keys.player_id, item.gold, item.shard )
	else
		UTIL_RemoveImmediate(item)
	end
end

-- This will modify regardless if player has it or not
function Economy:ModifyResource( player_id, gold, shard )
	if player_id and GoldTracking[player_id] then
		GoldTracking[player_id] = GoldTracking[player_id] + gold
		ShardTracking[player_id] = ShardTracking[player_id] + gold
		
		if GoldTracking[player_id] < 0 then
			GoldTracking[player_id] = 0
		elseif GoldTracking[player_id] > GOLD_UPPER_LIMIT then
			GoldTracking[player_id] = GOLD_UPPER_LIMIT
		end
		
		if ShardTracking[player_id] < 0 then
			ShardTracking[player_id] = 0
		elseif ShardTracking[player_id] > SHARD_UPPER_LIMIT then
			ShardTracking[player_id] = SHARD_UPPER_LIMIT
		end
	end
end