extends Node

var main: Node
var checks: int = 0
var failures: int = 0
var fixtures := [
	{"id": 1, "nombre": "Premio bajo", "record": 100, "habilitado": true},
	{"id": 2, "nombre": "Premio alto", "record": 200, "habilitado": true},
	{"id": 3, "nombre": "Deshabilitado", "record": 1, "habilitado": false}
]

func _ready() -> void:
	call_deferred("run_tests")

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func press(key: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = key
	event.pressed = true
	main._input(event)

func start_round(score_keys: Array) -> void:
	PrizeManager.prizes = fixtures.duplicate(true)
	press(KEY_ENTER)
	check(StateManager.current_state == StateManager.States.PRIZE_INTRO, "Inicio debe presentar premios")
	press(KEY_ENTER)
	check(StateManager.current_state == StateManager.States.READY_TO_HIT, "Debe esperar el golpe")
	for key in score_keys:
		press(key)
	press(KEY_ENTER)
	check(StateManager.current_state == StateManager.States.SCORE_RISE, "Debe evaluar el golpe confirmado")

func run_tests() -> void:
	main = load("res://scenes/Main.tscn").instantiate()
	add_child(main)
	await get_tree().process_frame
	check(StateManager.current_state == StateManager.States.DEMO_IDLE, "Inicio en DEMO_IDLE")
	check(SessionManager.hit_score == 0, "Inicio sin golpe")
	start_round([KEY_1, KEY_0, KEY_0])
	check(SessionManager.eligible_prizes.size() == 1, "Igualar récord habilita solo ese premio")
	check(SessionManager.hit_confirmed, "Golpe confirmado")
	SessionManager.set_hit_score(9999)
	check(SessionManager.hit_score == 100, "Golpe confirmado no se sobrescribe")
	var before_reload := SessionManager.round_prizes.duplicate(true)
	PrizeManager.reload_prizes()
	check(SessionManager.round_prizes == before_reload, "F5 conserva snapshot")
	check(SessionManager.hit_score == 100 and SessionManager.last_result == "WIN", "F5 conserva golpe y resultado")
	press(KEY_ENTER)
	check(StateManager.current_state == StateManager.States.SHOW_WIN, "Victoria automática")
	press(KEY_ENTER)
	check(StateManager.current_state == StateManager.States.PRIZE_SELECT, "Victoria lleva a selección")
	press(KEY_2)
	check(not SessionManager.has_selected_prize(), "Premio con récord mayor bloqueado")
	press(KEY_3)
	check(not SessionManager.has_selected_prize(), "Premio deshabilitado bloqueado")
	press(KEY_ENTER)
	check(StateManager.current_state == StateManager.States.PRIZE_SELECT, "No finaliza victoria sin elegir premio")
	press(KEY_KP_1)
	check(SessionManager.has_selected_prize(), "Teclado numérico selecciona premio válido")
	check(SessionManager.hit_score == 100 and SessionManager.last_result == "WIN", "Elegir conserva golpe y victoria")
	press(KEY_ENTER)
	check(StateManager.current_state == StateManager.States.DEMO_IDLE, "Confirmar regresa al inicio")
	check(SessionManager.hit_score == 0 and SessionManager.last_result == "" and not SessionManager.hit_confirmed and SessionManager.round_prizes.is_empty() and not SessionManager.has_selected_prize(), "DEMO_IDLE limpia toda la sesión")
	start_round([KEY_0])
	press(KEY_ENTER)
	check(StateManager.current_state == StateManager.States.SHOW_LOSE, "Golpe insuficiente pierde")
	press(KEY_ENTER)
	check(StateManager.current_state == StateManager.States.PRIZE_SELECT, "Derrota también pasa por selección")
	press(KEY_1)
	check(not SessionManager.has_selected_prize(), "Derrota no permite premio")
	press(KEY_ENTER)
	check(StateManager.current_state == StateManager.States.DEMO_IDLE, "Derrota termina en inicio")
	start_round([KEY_2, KEY_0, KEY_0])
	press(KEY_L)
	check(StateManager.current_state == StateManager.States.SHOW_LOSE, "L prueba derrota")
	press(KEY_ENTER)
	press(KEY_1)
	check(not SessionManager.has_selected_prize(), "Derrota forzada tampoco permite premio")
	press(KEY_ENTER)
	start_round([KEY_2, KEY_0, KEY_0])
	press(KEY_W)
	check(StateManager.current_state == StateManager.States.SHOW_WIN, "W prueba victoria")
	StateManager.change_state(StateManager.States.DEMO_IDLE)
	start_round([KEY_1, KEY_0, KEY_0])
	StateManager.change_state(StateManager.States.DEMO_IDLE)
	await get_tree().create_timer(1.7).timeout
	check(StateManager.current_state == StateManager.States.DEMO_IDLE and SessionManager.hit_score == 0, "Reinicio cancela temporizador y limpia golpe")
	check(not StateManager._is_transition_valid(StateManager.States.DEMO_IDLE, StateManager.States.PRIZE_SELECT), "Salto antiguo bloqueado")
	check(not StateManager._is_transition_valid(StateManager.States.PRIZE_SELECT, StateManager.States.PRIZE_INTRO), "No reinicia golpe tras seleccionar")
	start_round([KEY_2, KEY_0, KEY_0])
	await get_tree().create_timer(1.7).timeout
	check(StateManager.current_state == StateManager.States.SHOW_WIN, "Temporizador avanza automáticamente al resultado")
	StateManager.change_state(StateManager.States.DEMO_IDLE)
	PrizeManager.prizes = []
	press(KEY_ENTER)
	check(StateManager.current_state == StateManager.States.DEMO_IDLE, "Sin premios no comienza")
	print("FLOW TESTS: %d checks, %d failures" % [checks, failures])
	get_tree().quit(1 if failures else 0)
