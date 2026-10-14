extends Area2D

@onready var player: CharacterBody2D = $".."

var can_interact: Array[CollisionObject2D] = []
var collectables: Array[Area2D] = []
var isOpen = false
var player_in_range = false

func _process(delta: float) -> void:
	if player_in_range && Input.is_action_just_pressed("interact"):
		for i in collectables:
			i.collect(player.inventory)

func _on_body_entered(body: Node2D):
	if body.has_method("interact"):
		can_interact.push_back(body)

func _on_body_exited(body: Node2D):
	if can_interact.has(body) && body.has_method("interact"):
		if isOpen:
			body.close()
			can_interact.erase(body)
			isOpen = false
		else:
			can_interact.erase(body)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") && !isOpen:
		for o in can_interact:
			isOpen = true
			o.interact()

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("collect"):
		print("Berry detected")
		player_in_range = true
		collectables.append(area)


func _on_area_exited(area: Area2D) -> void:
	if area.has_method("collect"):
		collectables.erase(area)
