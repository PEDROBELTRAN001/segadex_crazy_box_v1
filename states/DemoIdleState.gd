class_name DemoIdleState
extends BaseState

var idle_timer: Timer

func enter() -> void:
	print("Entrando a DEMO_IDLE - Esperando 10s para propaganda...")
	
	# Crear y configurar el temporizador de inactividad
	idle_timer = Timer.new()
	idle_timer.wait_time = 10.0
	idle_timer.one_shot = true
	idle_timer.timeout.connect(_on_idle_timeout)
	add_child(idle_timer)
	idle_timer.start()

func update_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		StateManager.change_state(StateManager.States.PRIZE_SELECT)

func _on_idle_timeout() -> void:
	# Solo salta a propaganda si hay propagandas activas configuradas
	var ads = PropagandaManager.get_active_propagandas_sorted()
	if ads.size() > 0:
		StateManager.change_state(StateManager.States.PROPAGANDA)
	else:
		# Si no hay propagandas, reinicia el timer para volver a comprobar después
		idle_timer.start()
