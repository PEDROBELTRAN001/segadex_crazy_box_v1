extends Node2D

var state_label: Label
var current_state_node: BaseState = null

# Diccionario que enlaza cada Enum del StateManager con su respectivo script
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
	# Conectar la señal del StateManager para actualizar la UI cuando cambie el estado
	StateManager.state_changed.connect(_on_state_changed)
	
	# Forzar la actualización visual inicial para entrar al primer estado (DEMO_IDLE)
	_on_state_changed(StateManager.current_state)

func _setup_ui() -> void:
	# Cada estado puede mostrarse de forma simple con un texto grande[cite: 2]
	state_label = Label.new()
	state_label.add_theme_font_size_override("font_size", 48)
	state_label.position = Vector2(50, 50)
	add_child(state_label)

func _input(event: InputEvent) -> void:
	# En lugar de tener toda la lógica aquí, le delegamos el input directamente al estado activo
	if current_state_node and current_state_node.has_method("update_input"):
		current_state_node.update_input(event)

func _on_state_changed(new_state: int) -> void:
	# 1. Limpiar el estado anterior si existe
	if current_state_node:
		current_state_node.exit()
		current_state_node.queue_free()
	
	# 2. Instanciar y cargar el archivo correspondiente al nuevo estado
	var state_script = state_scenes[new_state]
	current_state_node = state_script.new() as BaseState
	add_child(current_state_node)
	
	# 3. Actualizar el texto en pantalla y ejecutar el enter() del nuevo estado
	var state_name = StateManager.States.keys()[new_state]
	state_label.text = "ESTADO ACTUAL: " + state_name
	current_state_node.enter()
