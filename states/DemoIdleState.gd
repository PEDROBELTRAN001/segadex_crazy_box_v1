class_name DemoIdleState
extends BaseState

func enter() -> void:
	print("Entrando a DEMO_IDLE - Máquina en espera")
	# Aquí en el futuro puedes reproducir un video de loop o luces atractivas

func update_input(event: InputEvent) -> void:
	# ENTER: Avanzar por la transición normal del estado actual
	if event.is_action_pressed("ui_accept"):
		StateManager.change_state(StateManager.States.PRIZE_SELECT)
