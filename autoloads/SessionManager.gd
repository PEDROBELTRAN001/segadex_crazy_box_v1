extends Node

signal session_updated

# Memoria de la jugada: se limpia únicamente al regresar a DEMO_IDLE.
var selected_prize: Dictionary = {}
var initial_record: int = 0
var hit_score: int = 0
var hit_confirmed: bool = false
var last_result: String = ""
var round_prizes: Array = []
var eligible_prizes: Array = []
var last_changes_log: Array[String] = []

func reset_session() -> void:
	selected_prize = {}
	initial_record = 0
	hit_score = 0
	hit_confirmed = false
	last_result = ""
	round_prizes.clear()
	eligible_prizes.clear()
	session_updated.emit()

func begin_round(prizes: Array) -> void:
	# La recarga de configuración no altera los récords de una jugada en curso.
	round_prizes = prizes.duplicate(true)
	session_updated.emit()

func select_prize(prize_data: Dictionary) -> bool:
	if last_result != "WIN":
		return false
	for prize in eligible_prizes:
		if int(prize.get("id", -1)) == int(prize_data.get("id", -1)):
			selected_prize = prize.duplicate(true)
			initial_record = int(prize.get("record", 0))
			session_updated.emit()
			return true
	return false

func set_hit_score(score: int) -> void:
	if hit_confirmed:
		return
	hit_score = clampi(score, 0, 9999)
	session_updated.emit()

func confirm_hit() -> void:
	hit_confirmed = true
	session_updated.emit()

func evaluate_hit() -> void:
	eligible_prizes.clear()
	for prize in round_prizes:
		if prize.get("habilitado", false) and hit_score >= int(prize.get("record", 0)):
			eligible_prizes.append(prize.duplicate(true))
	set_result("LOSE" if eligible_prizes.is_empty() else "WIN")

func set_result(result: String) -> void:
	last_result = result
	session_updated.emit()

func has_selected_prize() -> bool:
	return not selected_prize.is_empty()
