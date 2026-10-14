extends ProgressBar

@onready var player: CharacterBody2D = $"../../Player"

func _ready() -> void:
	#define valores da barra ao ser instanciada de acordo com os valores da stamina do player
	max_value = player.max_stamina
	value = player.current_stamina
	
	#conecta a barra ao sinal emitido pelo player com mudanças na stamina
	player.staminaChanged.connect(_on_player_stamina_changed)

#chama toda vez que a stamina do player muda para alterar o valor da barra
func _on_player_stamina_changed(new_value: float) -> void:
	value = new_value
