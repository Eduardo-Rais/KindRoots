extends Area2D

@export var itemRes: InventoryItem

@onready var sprite: Sprite2D = $Sprite2D

func collect(inventory: Inventory):
	inventory.insert(itemRes)
	queue_free()
