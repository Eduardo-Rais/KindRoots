extends Button

@onready var background: Sprite2D  = $background
@onready var container: CenterContainer = $CenterContainer

@onready var inventory = preload("res://Resources/playerInventory.tres")

var itemStackGui: ItemStackGui
var index: int

func insert(isg: ItemStackGui) -> bool:
	itemStackGui = isg
	background.frame = 1
	container.add_child(itemStackGui)
	
	if !itemStackGui.inventorySlot || inventory.slots[index] == itemStackGui.inventorySlot:
		return false
	
	inventory.insertSlot(index, itemStackGui.inventorySlot)
	return true

func takeItem():
	var item = itemStackGui
	
	inventory.removeSlot(itemStackGui.inventorySlot)
	
	container.remove_child(itemStackGui)
	itemStackGui = null
	background.frame = 0
	
	return item

func isEmpty():
	return !itemStackGui
