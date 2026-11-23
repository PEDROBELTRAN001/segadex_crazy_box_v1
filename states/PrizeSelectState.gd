class_name PrizeSelectState
extends BaseState

func enter() -> void:
	if SessionManager.last_result == "WIN":
		print("PRIZE_SELECT - Elige un premio alcanzado (1-6) y confirma con ENTER")
	else:
		print("PRIZE_SELECT - Sin premio disponible. ENTER para volver al inicio")

func update_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		var id: int = -1
		if event.keycode >= KEY_1 and event.keycode <= KEY_6:
			id = event.keycode - KEY_0
		elif event.keycode >= KEY_KP_1 and event.keycode <= KEY_KP_6:
			id = event.keycode - KEY_KP_0
		if id != -1:
			_try_select_prize(id)
			return
	if event.is_action_pressed("ui_accept"):
		if SessionManager.last_result != "WIN" or SessionManager.has_selected_prize():
			if SessionManager.has_selected_prize():
				print("Premio confirmado: ", SessionManager.selected_prize.get("nombre", ""))
			StateManager.change_state(StateManager.States.DEMO_IDLE)
		else:
			print("Selecciona primero uno de los premios alcanzados.")

func _try_select_prize(id: int) -> void:
	for prize in SessionManager.eligible_prizes:
		if int(prize.get("id", -1)) == id and SessionManager.select_prize(prize):
			print("Premio seleccionado: ", prize.get("nombre", ""))
			return
	print("Premio no disponible: está deshabilitado, no alcanzaste su récord o perdiste.")
