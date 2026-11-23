class_name DemoIdleState
extends BaseState

func enter() -> void:
	print("Entrando a DEMO_IDLE - Máquina en espera (Presiona ENTER para iniciar)")

func update_input(event: InputEvent) -> void:
	# ENTER: Presentar los premios antes del golpe.
	if event.is_action_pressed("ui_accept"):
		if PrizeManager.get_enabled_prizes().is_empty():
			print("No hay premios habilitados. Revisa la configuración y presiona F5.")
			return
		SessionManager.begin_round(PrizeManager.get_enabled_prizes())
		StateManager.change_state(StateManager.States.PRIZE_INTRO)
