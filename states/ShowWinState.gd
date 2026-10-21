class_name ShowWinState
extends BaseState

func enter() -> void:
	print("Entrando a SHOW_WIN - ¡Has ganado el premio!")

func update_input(event: InputEvent) -> void:
	# ENTER: Volver a DEMO_IDLE[cite: 4]
	if event.is_action_pressed("ui_accept"):
		StateManager.change_state(StateManager.States.DEMO_IDLE)
