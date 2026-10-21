extends Node2D

var state_label: Label
var diagnostic_label: Label 
var current_state_node: BaseState = null

var state_scenes = {
	StateManager.States.DEMO_IDLE: preload("res://states/DemoIdleState.gd"),
	StateManager.States.PRIZE_SELECT: preload("res://states/PrizeSelectState.gd"),
	StateManager.States.PRIZE_INTRO: preload("res://states/PrizeIntroState.gd"),
	StateManager.States.READY_TO_HIT: preload("res://states/ReadyToHitState.gd"),
	StateManager.States.SCORE_RISE: preload("res://states/ScoreRiseState.gd"),
	StateManager.States.SHOW_WIN: preload("res://states/ShowWinState.gd"),
	StateManager.States.SHOW_LOSE: preload("res://states/ShowLoseState.gd"),
	StateManager.States.PROPAGANDA: preload("res://states/PropagandaState.gd") # NUEVA LÍNEA
}

func _ready() -> void:
	_setup_ui()
	StateManager.state_changed.connect(_on_state_changed)
	
	StateManager.diagnostic_toggled.connect(_on_diagnostic_toggled)
	
	_on_state_changed(StateManager.current_state)

func _setup_ui() -> void:
	state_label = Label.new()
	state_label.add_theme_font_size_override("font_size", 48)
	state_label.position = Vector2(50, 50)
	add_child(state_label)
	
	diagnostic_label = Label.new()
	diagnostic_label.add_theme_font_size_override("font_size", 22)
	diagnostic_label.position = Vector2(50, 150)
	diagnostic_label.modulate = Color(1, 0.9, 0.2) # Color amarillo para distinguirlo
	diagnostic_label.visible = false # Oculto al inicio
	add_child(diagnostic_label)

func _input(event: InputEvent) -> void:
	if current_state_node and current_state_node.has_method("update_input"):
		current_state_node.update_input(event)

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
	
	if diagnostic_label.visible:
		_update_diagnostic_text()

# --- FUNCIONES DEL DIAGNÓSTICO ---
func _on_diagnostic_toggled(is_visible: bool) -> void:
	diagnostic_label.visible = is_visible
	if is_visible:
		_update_diagnostic_text()

func _update_diagnostic_text() -> void:
	var text = "--- MODO DIAGNÓSTICO (Presiona F1 para ocultar) ---\n"
	var state_name = StateManager.States.keys()[StateManager.current_state]
	text += "Estado Máquina: " + state_name + "\n\n"
	
	text += "Configuración de Premios:\n"
	
	var premios = PrizeManager.prizes
	for p in premios:
		var estado = "HABILITADO" if p.get("habilitado", false) else "DESHABILITADO"
		var tendencia = "Sí" if p.get("tendencia", false) else "No"
		text += "[Slot %d] %s | %s | Récord: %s | Tendencia: %s\n" % [p["id"], p["nombre"], estado, str(p["record"]), tendencia]
		
	diagnostic_label.text = text
