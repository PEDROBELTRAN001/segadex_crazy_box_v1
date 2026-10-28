class_name ReadyToHitState
extends BaseState

var typed_score_str: String = ""

func enter() -> void:
	typed_score_str = ""
	var prize_name = SessionManager.selected_prize.get("nombre", "Desconocido")
	var record = SessionManager.initial_record
	print("Entrando a READY_TO_HIT | Premio: %s (Récord: %d)" % [prize_name, record])
	print("Escribe el puntaje del golpe con los números del teclado y presiona ENTER:")

func update_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		# 1. Detectar números del 0 al 9 (tanto fila superior como teclado numérico)
		var number_pressed = -1
		if event.keycode >= KEY_0 and event.keycode <= KEY_9:
			number_pressed = event.keycode - KEY_0
		elif event.keycode >= KEY_KP_0 and event.keycode <= KEY_KP_9:
			number_pressed = event.keycode - KEY_KP_0
			
		if number_pressed != -1:
			# Limitar a 4 dígitos para evitar números gigantes accidentales
			if typed_score_str.length() < 4:
				typed_score_str += str(number_pressed)
				SessionManager.set_hit_score(int(typed_score_str))
				print("Golpe simulado: ", typed_score_str)
			return

		# 2. Permitir borrar dígitos con BACKSPACE
		if event.keycode == KEY_BACKSPACE:
			if typed_score_str.length() > 0:
				typed_score_str = typed_score_str.substr(0, typed_score_str.length() - 1)
				var current_val = int(typed_score_str) if typed_score_str != "" else 0
				SessionManager.set_hit_score(current_val)
				print("Golpe simulado (corregido): ", current_val)
			return

	# 3. ENTER: Confirmar puntaje y pasar a SCORE_RISE
	if event.is_action_pressed("ui_accept"):
		if typed_score_str != "":
			var final_score = int(typed_score_str)
			SessionManager.set_hit_score(final_score)
			print("Puntaje confirmado: %d -> Pasando a SCORE_RISE" % final_score)
			StateManager.change_state(StateManager.States.SCORE_RISE)
		else:
			print("Debes ingresar un puntaje numérico antes de presionar ENTER.")
