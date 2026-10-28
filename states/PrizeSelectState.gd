class_name PrizeSelectState
extends BaseState

func enter() -> void:
	print("Entrando a PRIZE_SELECT - Selecciona un premio habilitado (Teclas 1 al 6)")

func update_input(event: InputEvent) -> void:
	# Teclas 1 a 6: Seleccionar únicamente premios habilitados
	for i in range(1, 7):
		if Input.is_physical_key_pressed(KEY_0 + i) and event.is_pressed() and not event.is_echo():
			_try_select_prize(i)
			return
			
	# ENTER: Confirmar el premio guardado en sesión y pasar a PRIZE_INTRO
	if event.is_action_pressed("ui_accept"):
		if SessionManager.has_selected_prize():
			StateManager.change_state(StateManager.States.PRIZE_INTRO)
		else:
			print("Acción denegada: Debes seleccionar un premio habilitado primero.")

func _try_select_prize(id: int) -> void:
	var enabled_prizes = PrizeManager.get_enabled_prizes()
	for p in enabled_prizes:
		if p["id"] == id:
			# Guardamos el premio y su récord actual en la sesión persistente
			SessionManager.select_prize(p)
			print("Premio guardado en sesión -> ID: %d | Nombre: %s | Récord: %d" % [p["id"], p["nombre"], p["record"]])
			return
			
	print("El premio ", id, " está deshabilitado o no existe en la configuración.")
