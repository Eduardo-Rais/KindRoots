extends Node2D
@onready var ground: TileMapLayer = $Ground

func _process(delta):
	if Input.is_action_pressed("Right_click"):
		var mouse_position : Vector2 = get_global_mouse_position()
		var ground_position : Vector2i = ground.local_to_map(mouse_position)
		
		ground.set_cell(ground_position,1,Vector2i(1,9))

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Close_game"):
		get_tree().quit()


func _on_inventory_ui_opened() -> void:
	get_tree().paused = true


func _on_inventory_ui_closed() -> void:
	get_tree().paused = false
