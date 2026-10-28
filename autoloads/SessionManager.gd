extends Node
# res://autoloads/SessionManager.gd

# Señal para avisarle a la pantalla de diagnóstico (Main.gd) que los datos cambiaron
signal session_updated

# Datos principales de la jugada actual
var selected_prize: Dictionary = {}
var initial_record: int = 0
var hit_score: int = 0
var last_result: String = "" # "WIN", "LOSE" o ""

# Historial de cambios de la última jugada (ej. "Pizza: 803 -> 801")
var last_changes_log: Array[String] = []

# Se llama al volver a DEMO_IDLE para limpiar la partida actual
func reset_session() -> void:
	selected_prize = {}
	initial_record = 0
	hit_score = 0
	last_result = ""
	# Nota: No borramos last_changes_log para poder seguir viendo 
	# el resultado de la jugada anterior en el modo diagnóstico.
	session_updated.emit()

# Se llama desde PRIZE_SELECT cuando el jugador elige un premio válido
func select_prize(prize_data: Dictionary) -> void:
	selected_prize = prize_data.duplicate()
	initial_record = int(prize_data.get("record", 0))
	hit_score = 0
	last_result = ""
	session_updated.emit()

# Se llama desde READY_TO_HIT cuando se ingresa el puntaje del golpe
func set_hit_score(score: int) -> void:
	hit_score = score
	session_updated.emit()

# Se llama desde SCORE_RISE al determinar automáticamente si ganó o perdió
func set_result(result: String) -> void:
	last_result = result
	session_updated.emit()

# Verifica rápidamente si ya hay un premio seleccionado en la sesión
func has_selected_prize() -> bool:
	return not selected_prize.is_empty()
