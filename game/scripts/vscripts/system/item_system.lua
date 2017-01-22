ITEM_RARITY_COMMON = 0
ITEM_RARITY_RARE = 1
ITEM_RARITY_LEGENDARY = 2
ITEM_RARITY_GOD = 3

ITEM_TYPE_ACTIVE = 0
ITEM_TYPE_PASSIVE = 1
ITEM_TYPE_CONSUMABLES = 2
ITEM_TYPE_RECIPE = 3
ITEM_TYPE_QUEST = 4

-- All = 255
CLASS_SWORDMAN = 1
CLASS_INITIATE = 2
CLASS_THIEF = 4
CLASS_ACOLYTE = 8
CLASS_WITCH_HUNTER = 16
CLASS_DRUID = 32
CLASS_ARCHER = 64
CLASS_TEMPLAR = 128

if not ItemManager then
	ItemManager = class({})
end

function ItemManager:Init()
	Timers:CreateTimer(0.5, function()
			for player_id = 0, PlayerResource:GetPlayerCount() do
				local player = PlayerResource:GetPlayer(player_id)
				ItemManager:SortItems(player)
				ItemManager:CheckClass(player)
				ItemManager:CheckQuestDuplicate(player)
			end
			return 0.5
		end
	)
end

function ItemManager:SortItems(player)
	if player then
		local hero = player:GetAssignedHero()
		if hero and hero:HasInventory() then
			-- Make first pass to mark so it doesn't swap twice into same slot
			for item_index = 0, DOTA_ITEM_SLOT_9 do
				local item = hero:GetItemInSlot(item_index)
				if item then
					item.swapped = false
				end
			end
				
			-- Loop through inventory and backpack to sort
			for item_index = 0, DOTA_ITEM_SLOT_9 do
				local item = hero:GetItemInSlot(item_index)
				if item and item:IsItem() and item.swapped == false then
					-- Attach values if not attached already
					if not item.usable_class then
						ItemManager:AttachItem(item)
					end
					
					-- Check if item is still missing these important values then break it
					if not item.usable_class or item.usable_class == 0 or not item.item_type then
						hero:RemoveItem(item)
					end
						
					-- Assign common rarity if none
					if not item.rarity then
						item.rarity = ITEM_RARITY_COMMON
					end
					
					-- Setting up variables
					local assign_slot = 0
					local tmp_item = nil
					
					-- Within inventory bound
					if item_index < DOTA_ITEM_SLOT_7 then
						if item.item_type == ITEM_TYPE_QUEST then
							assign_slot = -1
							for i = DOTA_ITEM_SLOT_7, DOTA_ITEM_SLOT_9 do
								tmp_item = hero:GetItemInSlot(i)
								if not tmp_item then
									assign_slot = i
									break
								end
							end
							
							-- Swap
							if assign_slot ~= -1 then
								item.swapped = true
								hero:SwapItems(item_index, assign_slot)
							-- Since it's free then just destroy it if there is no slot								
							else
								hero:RemoveItem(item)
							end
						end
					-- Within backpack bound
					else
						if item.item_type ~= ITEM_TYPE_QUEST then
							assign_slot = -1
							for i = 0, DOTA_ITEM_SLOT_6 do
								tmp_item = hero:GetItemInSlot(i)
								if not tmp_item then
									assign_slot = i
									break
								end
							end
							
							-- Swap
							if assign_slot ~= -1 then
								item.swapped = true
								hero:SwapItems(item_index, assign_slot)
							-- Drop it at immediate location
							else
								hero:DropItemAtPositionImmediate(item, hero:GetAbsOrigin())
							end
						end
					end
				end
			end
		end
	end
end

function ItemManager:CheckClass(player)
	if player then
		local hero = player:GetAssignedHero()
		local class_bit = ItemManager:GetHeroBit(hero)
		
		if hero and hero:HasInventory() then
			-- Make first pass to mark so it doesn't swap twice into same slot
			for item_index = 0, DOTA_ITEM_SLOT_9 do
				local item = hero:GetItemInSlot(item_index)
				if item then
					if class_bit == 0 then
						hero:RemoveItem(item)
					elseif item.usable_class < 255 then	-- Not usable by all class
						if ItemManager:IsUsable(item.usable_class, class_bit) == false then
							hero:DropItemAtPositionImmediate(item, hero:GetAbsOrigin())
						end
					end
				end
			end
		end
	end
end

function ItemManager:GetHeroBit(hero)
	if hero then
		if hero:GetName() == "npc_dota_hero_drow_ranger" then
			return CLASS_ARCHER
		else
			return 0
		end
	else
		return 0
	end
end

function ItemManager:CheckQuestDuplicate(player)
	if player then
		local hero = player:GetAssignedHero()
		
		if hero and hero:HasInventory() then
			for item_index = DOTA_ITEM_SLOT_7, DOTA_ITEM_SLOT_8 do
				for next_item_index = item_index + 1, DOTA_ITEM_SLOT_9 do
					local prev_item = hero:GetItemInSlot(item_index)
					local next_item = hero:GetItemInSlot(next_item_index)
					if prev_item and next_item and prev_item:GetName() == next_item:GetName() then
						hero:RemoveItem(next_item)
					end
				end
			end
		end
	end
end

function ItemManager:AttachItem( item )
	item.usable_class = item:GetSpecialValueFor("usable_class")
	item.item_type = item:GetSpecialValueFor("item_type")
	item.rarity = item:GetSpecialValueFor("rarity")
end

function ItemManager:IsUsable(total_num, class_bit)
	local base = 1
	while base <= total_num do
		base = base * 2
	end
	
	if base ~= 1 then
		base = base / 2 -- make it come below total_num
	else
		return 1 == class_bit
	end
	
	while total_num >= class_bit do
		-- If base is below total_num then base is subset of binary total_num
		if total_num >= base then
			total_num = total_num - base
			if base == class_bit then
				-- correct number
				return true
			elseif base < class_bit then
				break
			end
		end
		base = base / 2
	end
	
	return false
end