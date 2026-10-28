extends Node2D

var state_label: Label
var session_info_label: Label
var diagnostic_label: Label
var current_state_node: BaseState = null

var state_scenes = {
	StateManager.States.DEMO_IDLE: preload("res://states/DemoIdleState.gd"),
	StateManager.States.PRIZE_SELECT: preload("res://states/PrizeSelectState.gd"),
	StateManager.States.PRIZE_INTRO: preload("res://states/PrizeIntroState.gd"),
	StateManager.States.READY_TO_HIT: preload("res://states/ReadyToHitState.gd"),
	StateManager.States.SCORE_RISE: preload("res://states/ScoreRiseState.gd"),
	StateManager.States.SHOW_WIN: preload("res://states/ShowWinState.gd"),
	StateManager.States.SHOW_LOSE: preload("res://states/ShowLoseState.gd")
}

func _ready() -> void:
	_setup_ui()
	StateManager.state_changed.connect(_on_state_changed)
	StateManager.diagnostic_toggled.connect(_on_diagnostic_toggled)
	
	# Actualizar textos en pantalla cada vez que cambie algún dato de la sesión
	SessionManager.session_updated.connect(_on_session_updated)
	
	_on_state_changed(StateManager.current_state)

func _setup_ui() -> void:
	# 1. Etiqueta grande del estado actual
	state_label = Label.new()
	state_label.add_theme_font_size_override("font_size", 42)
	state_label.position = Vector2(50, 30)
	add_child(state_label)
	
	# 2. Etiqueta de apoyo para ver la jugada actual (guía rápida en pantalla)
	session_info_label = Label.new()
	session_info_label.add_theme_font_size_override("font_size", 24)
	session_info_label.position = Vector2(50, 95)
	session_info_label.modulate = Color(0.7, 0.9, 1.0)
	add_child(session_info_label)
	
	# 3. Etiqueta completa del modo diagnóstico (F1)
	diagnostic_label = Label.new()
	diagnostic_label.add_theme_font_size_override("font_size", 18)
	diagnostic_label.position = Vector2(50, 210)
	diagnostic_label.modulate = Color(1, 0.9, 0.2)
	diagnostic_label.visible = false
	add_child(diagnostic_label)

func _input(event: InputEvent) -> void:
	if current_state_node and current_state_node.has_method("update_input"):
		current_state_node.update_input(event)
		
	# Si se recarga el JSON con F5, refrescar el diagnóstico
	if event.is_action_pressed("ui_reload_json") and diagnostic_label.visible:
		_update_diagnostic_text()

func _on_state_changed(new_state: int) -> void:
	if current_state_node:
		current_state_node.exit()
		current_state_node.queue_free()
	
	var state_script = state_scenes[new_state]
	current_state_node = state_script.new() as BaseState
	add_child(current_state_node)
	
	var state_name = StateManager.States.keys()[new_state]
	state_label.text = "ESTADO ACTUAL: " + state_name
	current_state_node.enter()
	
	_update_session_info_text()
	if diagnostic_label.visible:
		_update_diagnostic_text()

func _on_session_updated() -> void:
	_update_session_info_text()
	if diagnostic_label.visible:
		_update_diagnostic_text()

func _update_session_info_text() -> void:
	var state = StateManager.current_state
	var prize_name = SessionManager.selected_prize.get("nombre", "Ninguno")
	var record = SessionManager.initial_record
	var score = SessionManager.hit_score
	var result = SessionManager.last_result if SessionManager.last_result != "" else "Pendiente"
	
	var info = "Premio: %s (Récord: %d) | Golpe: %d | Resultado: %s\n" % [prize_name, record, score, result]
	
	match state:
		StateManager.States.DEMO_IDLE:
			info += "-> Presiona ENTER para comenzar."
		StateManager.States.PRIZE_SELECT:
			info += "-> Presiona 1-6 para elegir premio habilitado y luego ENTER."
		StateManager.States.PRIZE_INTRO:
			info += "-> Presiona ENTER para ir al golpe."
		StateManager.States.READY_TO_HIT:
			info += "-> Escribe el puntaje con los números (Backspace para borrar) y presiona ENTER."
		StateManager.States.SCORE_RISE:
			info += "-> Comparando puntaje y descontando récords..."
		StateManager.States.SHOW_WIN, StateManager.States.SHOW_LOSE:
			info += "-> Fin de jugada. Presiona ENTER para volver a DEMO_IDLE."
			
	session_info_label.text = info

func _on_diagnostic_toggled(is_visible: bool) -> void:
	diagnostic_label.visible = is_visible
	if is_visible:
		_update_diagnostic_text()

func _update_diagnostic_text() -> void:
	var state_name = StateManager.States.keys()[StateManager.current_state]
	var text = "=== MODO DIAGNÓSTICO (F1 para ocultar) ===\n"
	text += "Estado actual de la máquina: " + state_name + "\n"
	
	if SessionManager.has_selected_prize():
		var p = SessionManager.selected_prize
		var p_status = "HABILITADO" if p.get("habilitado", false) else "DESHABILITADO"
		text += "Premio seleccionado: [ID %d] %s (%s)\n" % [p["id"], p["nombre"], p_status]
		text += "Récord del premio al iniciar jugada: %d\n" % SessionManager.initial_record
	else:
		text += "Premio seleccionado: Ninguno\n"
		text += "Récord del premio al iniciar jugada: -\n"
		
	text += "Puntaje del golpe: %d\n" % SessionManager.hit_score
	text += "Resultado WIN/LOSE: %s\n\n" % (SessionManager.last_result if SessionManager.last_result != "" else "N/A")
	
	text += "--- Valores actuales de los 6 premios ---\n"
	for p in PrizeManager.prizes:
		var estado = "HABILITADO" if p.get("habilitado", false) else "DESHABILITADO"
		var rec_actual = int(p.get("record", 0))
		var rec_fijo = int(p.get("record_fijo", rec_actual))
		text += "ID %d | %s | Récord: %d (Fijo: %d) | %s\n" % [int(p["id"]), p["nombre"], rec_actual, rec_fijo, estado]	
		text += "\n--- Cambio producido por la última jugada ---\n"
	
	if SessionManager.last_changes_log.is_empty():
		text += "(Aún no se ha completado ninguna jugada en esta sesión)\n"
	else:
		for log_line in SessionManager.last_changes_log:
			text += log_line + "\n"
			
	diagnostic_label.text = text
