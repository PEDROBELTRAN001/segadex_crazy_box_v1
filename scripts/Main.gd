extends Node2D

@onready var state_label = Label.new() # Mostrará texto grande[cite: 7]
var selected_prize_id: int = -1
var score_rise_finished: bool = false

func _ready():
	# Configuración de UI temporal para la Etapa 1[cite: 7]
	state_label.add_theme_font_size_override("font_size", 40)
	add_child(state_label)
	StateManager.state_changed.connect(_on_state_changed)
	_on_state_changed(StateManager.current_state)

func _input(event: InputEvent) -> void:
	var state = StateManager.current_state
	
	# TECLAS 1 al 6: Seleccionar slot de premio[cite: 9]
	if state == StateManager.States.PRIZE_SELECT:
		for i in range(1, 7):
			if Input.is_physical_key_pressed(KEY_0 + i):
				_try_select_prize(i)
				return

	# W / L: Forzar victoria o derrota[cite: 9]
	if state == StateManager.States.SCORE_RISE and score_rise_finished:
		if Input.is_physical_key_pressed(KEY_W):
			StateManager.change_state(StateManager.States.SHOW_WIN)
		elif Input.is_physical_key_pressed(KEY_L):
			StateManager.change_state(StateManager.States.SHOW_LOSE)

	# ENTER: Avance normal de la máquina[cite: 9]
	if event.is_action_pressed("ui_accept"): 
		match state:
			StateManager.States.DEMO_IDLE:
				StateManager.change_state(StateManager.States.PRIZE_SELECT)
			StateManager.States.PRIZE_SELECT:
				if selected_prize_id != -1:
					StateManager.change_state(StateManager.States.PRIZE_INTRO)
			StateManager.States.PRIZE_INTRO:
				StateManager.change_state(StateManager.States.READY_TO_HIT)
			StateManager.States.READY_TO_HIT:
				StateManager.change_state(StateManager.States.SCORE_RISE)
			StateManager.States.SCORE_RISE:
				score_rise_finished = true # Simular fin para permitir W/L[cite: 9]
				print("ScoreRise terminado. Presiona W o L.")
			StateManager.States.SHOW_WIN, StateManager.States.SHOW_LOSE:
				StateManager.change_state(StateManager.States.DEMO_IDLE)

func _try_select_prize(id: int) -> void:
	# Solo acepta premios habilitados[cite: 9, 10]
	var enabled_prizes = PrizeManager.get_enabled_prizes()
	for p in enabled_prizes:
		if p["id"] == id:
			selected_prize_id = id
			print("Premio seleccionado: ", p["nombre"])
			return
	print("Premio ", id, " está deshabilitado o no existe.")

func _on_state_changed(new_state: int) -> void:
	var state_name = StateManager.States.keys()[new_state]
	state_label.text = "ESTADO ACTUAL: " + state_name # Muestra el estado en pantalla[cite: 7, 10]
	
	if new_state == StateManager.States.DEMO_IDLE:
		selected_prize_id = -1
		score_rise_finished = false
