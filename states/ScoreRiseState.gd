class_name ScoreRiseState
extends BaseState

var transition_timer: Timer

func enter() -> void:
	SessionManager.evaluate_hit()
	print("SCORE_RISE - Golpe: %d | Premios alcanzados: %d" % [SessionManager.hit_score, SessionManager.eligible_prizes.size()])
	transition_timer = Timer.new()
	transition_timer.wait_time = 1.5
	transition_timer.one_shot = true
	transition_timer.timeout.connect(_advance_to_result)
	add_child(transition_timer)
	transition_timer.start()

func exit() -> void:
	# Evita que un temporizador de una jugada cancelada avance la siguiente.
	if is_instance_valid(transition_timer):
		transition_timer.stop()

func update_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.keycode == KEY_L:
			SessionManager.set_result("LOSE")
			_advance_to_result()
			return
		if event.keycode == KEY_W:
			if SessionManager.eligible_prizes.is_empty():
				print("Para probar WIN, ingresa un golpe que alcance al menos un premio.")
				return
			SessionManager.set_result("WIN")
			_advance_to_result()
			return
	if event.is_action_pressed("ui_accept"):
		_advance_to_result()

func _advance_to_result() -> void:
	if StateManager.current_state != StateManager.States.SCORE_RISE:
		return
	transition_timer.stop()
	if SessionManager.last_result == "WIN":
		StateManager.change_state(StateManager.States.SHOW_WIN)
	else:
		StateManager.change_state(StateManager.States.SHOW_LOSE)
