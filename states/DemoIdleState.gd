class_name DemoIdleState
extends BaseState

func enter() -> void:
	# Limpiar los datos de la jugada anterior al volver al inicio
	SessionManager.reset_session()
	print("Entrando a DEMO_IDLE - Máquina en espera (Presiona ENTER para iniciar)")

func update_input(event: InputEvent) -> void:
	# ENTER: Avanzar a PRIZE_SELECT
	if event.is_action_pressed("ui_accept"):
		StateManager.change_state(StateManager.States.PRIZE_SELECT)
