class_name PrizeIntroState
extends BaseState

func enter() -> void:
	print("Entrando a PRIZE_INTRO - Presentando el premio seleccionado")
	# Aquí en el futuro se mostrará la animación del premio elegido

func update_input(event: InputEvent) -> void:
	# ENTER: Avanzar por la transición normal del estado actual[cite: 4]
	if event.is_action_pressed("ui_accept"):
		StateManager.change_state(StateManager.States.READY_TO_HIT)
