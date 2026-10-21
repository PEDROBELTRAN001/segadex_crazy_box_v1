class_name PrizeSelectState
extends BaseState

var selected_prize_id: int = -1

func enter() -> void:
	print("Entrando a PRIZE_SELECT - Esperando selección de premio (Teclas 1 al 6)")
	selected_prize_id = -1

func update_input(event: InputEvent) -> void:
	# Teclas 1 a 6: Seleccionar un slot de premio
	for i in range(1, 7):
		if Input.is_physical_key_pressed(KEY_0 + i) and event.is_pressed() and not event.is_echo():
			_try_select_prize(i)
			return
			
	# ENTER: Confirmar el premio seleccionado y pasar a PRIZE_INTRO
	if event.is_action_pressed("ui_accept"):
		if selected_prize_id != -1:
			StateManager.change_state(StateManager.States.PRIZE_INTRO)
		else:
			print("Acción denegada: Debes seleccionar un premio habilitado primero.")

func _try_select_prize(id: int) -> void:
	var enabled_prizes = PrizeManager.get_enabled_prizes()
	for p in enabled_prizes:
		if p["id"] == id:
			selected_prize_id = id
			print("Premio válido seleccionado: ", p["nombre"])
			return
	print("El premio ", id, " está deshabilitado o no existe en la configuración.")
