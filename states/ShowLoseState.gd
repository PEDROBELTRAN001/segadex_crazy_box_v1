class_name ShowLoseState
extends BaseState

func enter() -> void:
	print("Entrando a SHOW_LOSE - Fin del juego, vuelve a intentarlo.")

func update_input(event: InputEvent) -> void:
	# ENTER: Volver a DEMO_IDLE[cite: 4]
	if event.is_action_pressed("ui_accept"):
		StateManager.change_state(StateManager.States.DEMO_IDLE)
