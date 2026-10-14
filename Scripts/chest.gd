extends StaticBody2D

@onready var sprite: AnimatedSprite2D = $Sprite2D

func interact() -> void:
	sprite.play("open")

func close() -> void:
	sprite.play("close")
