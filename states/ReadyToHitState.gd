class_name ReadyToHitState
extends BaseState

func enter() -> void:
	print("Entrando a READY_TO_HIT - Esperando el golpe en la máquina")

func update_input(event: InputEvent) -> void:
	# ENTER: Avanzar por la transición normal a SCORE_RISE
	if event.is_action_pressed("ui_accept"):
		StateManager.change_state(StateManager.States.SCORE_RISE)
