extends CharacterBody2D

signal staminaChanged

@export var speed: float = 70.0
@onready var sprite: AnimatedSprite2D = $Sprite2D
@export var run_speed: float = 100

@export var inventory: Inventory

@export var max_stamina:float  = 100.0
@onready var current_stamina : float = max_stamina
@onready var min_stamina : int = 0

@export var stamina_drain : float = 20.0
@export var stamina_regen : float = 15.0

var isRunning = false

func get_input():
	var input_direction = Input.get_vector("Move_left", "Move_right", "Move_up", "Move_down")
	if isRunning:
		velocity = input_direction * run_speed
	else:
		velocity = input_direction * speed


func _physics_process(delta):
	get_input()
	move_and_slide()
	update_stamina(delta)
	if Input.is_action_pressed("Move_right"):
		sprite.flip_h = false
		sprite.play("walk")
	elif Input.is_action_pressed("Move_left"):
		sprite.flip_h = true
		sprite.play("walk")
	elif Input.is_action_pressed("Move_up"):
		sprite.play("up")
	elif Input.is_action_pressed("Move_down"):
		sprite.play("down")
	else:
		sprite.play("Idle_front")

func update_stamina(delta):
	if isRunning && !velocity.is_zero_approx():
		current_stamina -= stamina_drain * delta
		staminaChanged.emit(current_stamina)
	else:
		current_stamina += stamina_regen * delta
		staminaChanged.emit(current_stamina)
	
	current_stamina = clamp(current_stamina, 0 , max_stamina)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("run") && current_stamina > min_stamina:
		isRunning = true
	elif event.is_action_released("run") or current_stamina <= 0:
		isRunning = false
