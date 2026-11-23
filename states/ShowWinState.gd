class_name ShowWinState
extends BaseState

func enter() -> void:
	print("Entrando a SHOW_WIN - ¡Puedes elegir uno de los premios alcanzados!")

func update_input(event: InputEvent) -> void:
	# ENTER: Elegir el premio con el golpe conservado.
	if event.is_action_pressed("ui_accept"):
		StateManager.change_state(StateManager.States.PRIZE_SELECT)
