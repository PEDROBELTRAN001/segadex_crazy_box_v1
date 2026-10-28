class_name ScoreRiseState
extends BaseState

var transition_timer: Timer

func enter() -> void:
	var score: int = SessionManager.hit_score
	var record: int = SessionManager.initial_record
	var prize_id: int = int(SessionManager.selected_prize.get("id", -1))
	var prize_name: String = SessionManager.selected_prize.get("nombre", "Desconocido")
	
	print("Entrando a SCORE_RISE - Subiendo puntaje...")
	print("Comparando Golpe (%d) vs Récord de %s (%d)" % [score, prize_name, record])
	
	# 1. Determinación automática de WIN / LOSE
	if score >= record:
		SessionManager.set_result("WIN")
		print("Resultado determinado automáticamente: WIN")
	else:
		SessionManager.set_result("LOSE")
		print("Resultado determinado automáticamente: LOSE")
		
	# 2. Actualizar récords (-1 habilitados, -2 seleccionado) y guardar en JSON
	if prize_id != -1:
		PrizeManager.apply_post_game_discounts(prize_id)
		
	# 3. Temporizador breve (1.5s) para visualizar el estado SCORE_RISE antes de cambiar automáticamente
	transition_timer = Timer.new()
	transition_timer.wait_time = 1.5
	transition_timer.one_shot = true
	transition_timer.timeout.connect(_advance_to_result)
	add_child(transition_timer)
	transition_timer.start()

func update_input(event: InputEvent) -> void:
	# Permitir saltar la espera de 1.5s presionando ENTER si se desea probar rápido
	if event.is_action_pressed("ui_accept"):
		if transition_timer and not transition_timer.is_stopped():
			transition_timer.stop()
		_advance_to_result()

func _advance_to_result() -> void:
	if SessionManager.last_result == "WIN":
		StateManager.change_state(StateManager.States.SHOW_WIN)
	else:
		StateManager.change_state(StateManager.States.SHOW_LOSE)
