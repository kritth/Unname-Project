ITEM_RARITY_COMMON = 0
ITEM_RARITY_RARE = 1
ITEM_RARITY_LEGENDARY = 2
ITEM_RARITY_GOD = 3

ITEM_TYPE_ACTIVE = 0
ITEM_TYPE_PASSIVE = 1
ITEM_TYPE_CONSUMABLES = 2
ITEM_TYPE_RECIPE = 3
ITEM_TYPE_QUEST = 4

if not ItemManager then
	ItemManager = class({})
end

function ItemManager:SortItems( keys )
	print("Start sorting")
end