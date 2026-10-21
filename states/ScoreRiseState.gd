class_name ScoreRiseState
extends BaseState

var score_rise_finished: bool = false

func enter() -> void:
	print("Entrando a SCORE_RISE - Calculando fuerza del golpe...")
	score_rise_finished = false

func update_input(event: InputEvent) -> void:
	# ENTER: Simular fin de ScoreRise y habilitar decisión de resultado[cite: 4]
	if event.is_action_pressed("ui_accept") and not score_rise_finished:
		score_rise_finished = true
		print("Simulación de puntaje terminada. Presiona 'W' (Ganar) o 'L' (Perder).")
		return

	# W / L: Forzar resultado de prueba solo si el puntaje terminó de subir[cite: 4]
	if score_rise_finished:
		if Input.is_physical_key_pressed(KEY_W) and event.is_pressed() and not event.is_echo():
			StateManager.change_state(StateManager.States.SHOW_WIN)
		elif Input.is_physical_key_pressed(KEY_L) and event.is_pressed() and not event.is_echo():
			StateManager.change_state(StateManager.States.SHOW_LOSE)
