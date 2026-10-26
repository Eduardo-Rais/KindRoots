extends Button

@onready var background: Sprite2D  = $background
@onready var container: CenterContainer = $CenterContainer

@onready var inventory = preload("res://Resources/playerInventory.tres")

var itemStackGui: ItemStackGui
var index: int

func insert(isg: ItemStackGui):
	itemStackGui = isg
	background.frame = 1
	container.add_child(itemStackGui)
	
	if !itemStackGui.inventorySlot || inventory.slots[index] == itemStackGui.inventorySlot:
		return
	
	inventory.insertSlot(index, itemStackGui.inventorySlot)

func takeItem():
	var item = itemStackGui
	
	container.remove_child(itemStackGui)
	itemStackGui = null
	background.frame = 0
	
	return item

func isEmpty():
	return !itemStackGui
