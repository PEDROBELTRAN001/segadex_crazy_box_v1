extends Node

enum States {
	DEMO_IDLE, PRIZE_SELECT, PRIZE_INTRO, READY_TO_HIT, 
	SCORE_RISE, SHOW_WIN, SHOW_LOSE, PROPAGANDA
}

var current_state: States = States.DEMO_IDLE
var is_diagnostic_visible: bool = false

signal state_changed(new_state: States)
signal diagnostic_toggled(is_visible: bool)

func _ready() -> void:
	call_deferred("change_state", States.DEMO_IDLE)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_diagnostic"): # Mapear a F1
		is_diagnostic_visible = !is_diagnostic_visible
		diagnostic_toggled.emit(is_diagnostic_visible)
		
	elif event.is_action_pressed("ui_reset"): # Mapear a R
		change_state(States.DEMO_IDLE)
		
	elif event.is_action_pressed("ui_reload_json"): # Mapear a F5
		PrizeManager.reload_prizes()
		print("JSON Recargado!")

func change_state(new_state: States) -> void:
	if _is_transition_valid(current_state, new_state):
		current_state = new_state
		state_changed.emit(current_state)
	else:
		push_warning("Transición inválida bloqueada.")

func _is_transition_valid(from_state: States, to_state: States) -> bool:
	if to_state == States.DEMO_IDLE: return true # 'R' reinicia desde cualquier lugar
	
	match from_state:
		States.DEMO_IDLE: 
			return to_state in [States.PRIZE_SELECT, States.PROPAGANDA]
		States.PROPAGANDA: 
			return to_state == States.PRIZE_SELECT
		States.PRIZE_SELECT: 
			return to_state == States.PRIZE_INTRO
		States.PRIZE_INTRO: 
			return to_state == States.READY_TO_HIT
		States.READY_TO_HIT: 
			return to_state == States.SCORE_RISE
		States.SCORE_RISE: 
			return to_state in [States.SHOW_WIN, States.SHOW_LOSE]
		States.SHOW_WIN, States.SHOW_LOSE: 
			return to_state == States.DEMO_IDLE
	return false
