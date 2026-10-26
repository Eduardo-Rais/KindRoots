extends GutTest

const PLAYER_SCRIPT = preload("res://Scripts/player.gd")

var player


func before_each():
	player = PLAYER_SCRIPT.new()
	add_child(player)


func after_each():
	player.free()


# Funcionalidade 2: consumo de stamina
func test_stamina_diminui_ao_correr():
	player.current_stamina = 100.0
	player.isRunning = true
	player.velocity = Vector2.RIGHT

	player.update_stamina(1.0)

	assert_almost_eq(
		player.current_stamina, 80.0, 0.01,
		"A stamina deveria cair de 100 para 80."
	)


# Funcionalidade 3: recuperação de stamina
func test_stamina_recupera_quando_nao_corre():
	player.current_stamina = 50.0
	player.isRunning = false

	player.update_stamina(1.0)

	assert_almost_eq(
		player.current_stamina, 65.0, 0.01,
		"A stamina deveria subir de 50 para 65."
	)


# Caso de borda: stamina não pode ficar negativa
func test_stamina_nao_fica_negativa():
	player.current_stamina = 5.0
	player.isRunning = true
	player.velocity = Vector2.RIGHT

	player.update_stamina(1.0)

	assert_eq(
		player.current_stamina, 0.0,
		"A stamina não pode ficar abaixo de zero."
	)


# Caso de borda: stamina não pode passar do máximo
func test_stamina_nao_ultrapassa_maximo():
	player.current_stamina = 95.0
	player.isRunning = false

	player.update_stamina(1.0)

	assert_eq(
		player.current_stamina, 100.0,
		"A stamina não pode ultrapassar max_stamina."
	)
	
	
# Funcionalidade 1: caminhada
func test_movimento_usa_velocidade_normal():
	Input.action_press("Move_right")
	player.isRunning = false

	player.get_input()

	assert_almost_eq(
		player.velocity.x,
		player.speed,
		0.01,
		"A caminhada deve usar a velocidade normal."
	)

	Input.action_release("Move_right")


# Funcionalidade 1: corrida
func test_movimento_usa_velocidade_de_corrida():
	Input.action_press("Move_right")
	player.isRunning = true

	player.get_input()

	assert_almost_eq(
		player.velocity.x,
		player.run_speed,
		0.01,
		"A corrida deve usar run_speed."
	)

	Input.action_release("Move_right")
