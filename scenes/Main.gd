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
	SessionManager.session_updated.connect(_on_session_updated)
	_on_state_changed(StateManager.current_state)

func _setup_ui() -> void:
	var scroll := ScrollContainer.new()
	scroll.size = get_viewport_rect().size
	add_child(scroll)
	get_viewport().size_changed.connect(func(): scroll.size = get_viewport_rect().size)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 16)
	scroll.add_child(content)
	state_label = Label.new()
	state_label.add_theme_font_size_override("font_size", 36)
	content.add_child(state_label)
	session_info_label = Label.new()
	session_info_label.add_theme_font_size_override("font_size", 22)
	session_info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	session_info_label.modulate = Color(0.7, 0.9, 1.0)
	content.add_child(session_info_label)
	diagnostic_label = Label.new()
	diagnostic_label.add_theme_font_size_override("font_size", 18)
	diagnostic_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	diagnostic_label.modulate = Color(1, 0.9, 0.2)
	diagnostic_label.visible = StateManager.is_diagnostic_visible
	content.add_child(diagnostic_label)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_echo():
		return
	if current_state_node:
		current_state_node.update_input(event)

func _on_state_changed(new_state: int) -> void:
	if current_state_node:
		current_state_node.exit()
		current_state_node.queue_free()
	current_state_node = state_scenes[new_state].new() as BaseState
	add_child(current_state_node)
	state_label.text = "ESTADO ACTUAL: " + StateManager.States.keys()[new_state]
	current_state_node.enter()
	_on_session_updated()

func _on_session_updated() -> void:
	_update_session_info_text()
	if diagnostic_label.visible:
		_update_diagnostic_text()

func _update_session_info_text() -> void:
	var state = StateManager.current_state
	var info := "Golpe: %d | Resultado: %s | Premio: %s\n" % [
		SessionManager.hit_score,
		SessionManager.last_result if SessionManager.last_result != "" else "Pendiente",
		SessionManager.selected_prize.get("nombre", "Sin elegir")]
	match state:
		StateManager.States.DEMO_IDLE:
			info += "ENTER: comenzar. F1: diagnóstico. F5: recargar premios. R: reiniciar."
			if PrizeManager.get_enabled_prizes().is_empty():
				info += "\nNo hay premios habilitados: modifica el JSON y presiona F5."
		StateManager.States.PRIZE_INTRO:
			info += "Premios de esta jugada (ENTER para continuar):\n"
			for prize in SessionManager.round_prizes:
				info += "[%d] %s | Récord: %d\n" % [int(prize["id"]), prize["nombre"], int(prize["record"])]
		StateManager.States.READY_TO_HIT:
			info += "Escribe el golpe (0-9999). Backspace: borrar. ENTER: confirmar."
		StateManager.States.SCORE_RISE:
			info += "Evaluando el golpe... ENTER: resultado. W/L: probar victoria/derrota."
		StateManager.States.SHOW_WIN:
			info += "¡Ganaste! ENTER para elegir entre los premios alcanzados."
		StateManager.States.SHOW_LOSE:
			info += "No ganaste un premio. ENTER para continuar a PRIZE_SELECT."
		StateManager.States.PRIZE_SELECT:
			if SessionManager.last_result == "WIN":
				info += "Elige con 1-6 (fila superior o teclado numérico). ENTER: confirmar y terminar.\n"
				for prize in SessionManager.eligible_prizes:
					info += "[%d] %s | Récord: %d\n" % [int(prize["id"]), prize["nombre"], int(prize["record"])]
			else:
				info += "Sin premios para reclamar. ENTER: terminar y volver a DEMO_IDLE."
	session_info_label.text = info

func _on_diagnostic_toggled(is_visible: bool) -> void:
	diagnostic_label.visible = is_visible
	if is_visible:
		_update_diagnostic_text()

func _update_diagnostic_text() -> void:
	var text := "=== DIAGNÓSTICO (F1) ===\nEstado: %s\n" % StateManager.States.keys()[StateManager.current_state]
	text += "Golpe: %d | Confirmado: %s | Resultado: %s\n" % [SessionManager.hit_score, str(SessionManager.hit_confirmed), SessionManager.last_result]
	text += "Premio seleccionado: %s | Récord al iniciar: %d\n" % [SessionManager.selected_prize.get("nombre", "Ninguno"), SessionManager.initial_record]
	text += "Premios de la jugada: %d | Alcanzados: %d\n" % [SessionManager.round_prizes.size(), SessionManager.eligible_prizes.size()]
	text += "La configuración recargada aplica a la siguiente jugada.\n--- Configuración actual ---\n"
	for prize in PrizeManager.prizes:
		text += "ID %d | %s | Récord: %d (Fijo: %d) | %s | Tendencia: %s | Orden: %d\n" % [
			int(prize["id"]), prize["nombre"], int(prize["record"]), int(prize.get("record_fijo", prize["record"])),
			"HABILITADO" if prize.get("habilitado", false) else "DESHABILITADO",
			str(prize.get("tendencia", false)), int(prize.get("orden", 0))]
	diagnostic_label.text = text
