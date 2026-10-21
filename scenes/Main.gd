extends Node2D

var state_label: Label
var selected_prize_id: int = -1
var score_rise_finished: bool = false

func _ready() -> void:
	_setup_ui()
	# Conectar la señal del StateManager para actualizar la UI cuando cambie el estado
	StateManager.state_changed.connect(_on_state_changed)
	# Forzar la actualización visual inicial
	_on_state_changed(StateManager.current_state)

func _setup_ui() -> void:
	# Cada estado puede mostrarse de forma simple con un texto grande[cite: 7].
	state_label = Label.new()
	state_label.add_theme_font_size_override("font_size", 48)
	state_label.position = Vector2(50, 50)
	add_child(state_label)

func _input(event: InputEvent) -> void:
	var state = StateManager.current_state
	
	# Lógica exclusiva para PRIZE_SELECT
	if state == StateManager.States.PRIZE_SELECT:
		# Detectar teclas numéricas del 1 al 6
		for i in range(1, 7):
			if Input.is_physical_key_pressed(KEY_0 + i) and event.is_pressed() and not event.is_echo():
				_try_select_prize(i)
				return

	# Lógica exclusiva para SCORE_RISE (Decisión W / L)
	if state == StateManager.States.SCORE_RISE and score_rise_finished:
		if Input.is_physical_key_pressed(KEY_W) and event.is_pressed():
			StateManager.change_state(StateManager.States.SHOW_WIN)
		elif Input.is_physical_key_pressed(KEY_L) and event.is_pressed():
			StateManager.change_state(StateManager.States.SHOW_LOSE)

	# Lógica de avance con ENTER para la transición normal[cite: 9]
	if event.is_action_pressed("ui_accept"):
		match state:
			StateManager.States.DEMO_IDLE:
				StateManager.change_state(StateManager.States.PRIZE_SELECT)
			StateManager.States.PRIZE_SELECT:
				# Confirmar el premio seleccionado y pasar a PRIZE_INTRO[cite: 9]
				if selected_prize_id != -1:
					StateManager.change_state(StateManager.States.PRIZE_INTRO)
				else:
					print("Debes seleccionar un premio habilitado primero.")
			StateManager.States.PRIZE_INTRO:
				StateManager.change_state(StateManager.States.READY_TO_HIT)
			StateManager.States.READY_TO_HIT:
				StateManager.change_state(StateManager.States.SCORE_RISE)
			StateManager.States.SCORE_RISE:
				# Simular fin de ScoreRise y habilitar decisión de resultado[cite: 9]
				score_rise_finished = true 
				state_label.text += "\n(Simulación terminada. Presiona W o L)"
			StateManager.States.SHOW_WIN, StateManager.States.SHOW_LOSE:
				# Volver a DEMO_IDLE[cite: 9]
				StateManager.change_state(StateManager.States.DEMO_IDLE)

func _try_select_prize(id: int) -> void:
	# El estado PRIZE_SELECT debe leer la configuración y reconocer únicamente los premios habilitados[cite: 8].
	var enabled_prizes = PrizeManager.get_enabled_prizes()
	var is_valid = false
	
	for p in enabled_prizes:
		if p["id"] == id:
			is_valid = true
			selected_prize_id = id
			state_label.text = "ESTADO ACTUAL: PRIZE_SELECT\nPremio seleccionado: " + p["nombre"]
			print("Premio válido seleccionado: ", p["nombre"])
			break
			
	if not is_valid:
		print("El premio ", id, " está deshabilitado o no existe. No se puede seleccionar.")

func _on_state_changed(new_state: int) -> void:
	var state_name = StateManager.States.keys()[new_state]
	state_label.text = "ESTADO ACTUAL: " + state_name
	
	# Limpiar variables temporales al reiniciar el ciclo
	if new_state == StateManager.States.DEMO_IDLE:
		selected_prize_id = -1
		score_rise_finished = false
