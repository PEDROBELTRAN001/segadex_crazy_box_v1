class_name PrizeIntroState
extends BaseState

func enter() -> void:
	print("Entrando a PRIZE_INTRO - Presentando los premios disponibles y sus récords")

func update_input(event: InputEvent) -> void:
	# ENTER: Avanzar por la transición normal del estado actual[cite: 4]
	if event.is_action_pressed("ui_accept"):
		StateManager.change_state(StateManager.States.READY_TO_HIT)
