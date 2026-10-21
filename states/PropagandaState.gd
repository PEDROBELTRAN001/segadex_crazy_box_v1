class_name PropagandaState
extends BaseState

var ads: Array = []
var current_ad_index: int = 0
var ad_timer: Timer

func enter() -> void:
	ads = PropagandaManager.get_active_propagandas_sorted() 
	current_ad_index = 0
	
	ad_timer = Timer.new()
	ad_timer.one_shot = true
	ad_timer.timeout.connect(_show_next_ad)
	add_child(ad_timer)
	
	_show_current_ad()

func _show_current_ad() -> void:
	if current_ad_index >= ads.size():
		# Se acabaron las propagandas, volvemos a IDLE
		StateManager.change_state(StateManager.States.DEMO_IDLE)
		return
		
	var ad = ads[current_ad_index]
	print("\n--- MOSTRANDO PROPAGANDA ---")
	print("Nombre: ", ad["nombre"])
	print("Prioridad: ", ad["prioridad"])
	print("Mostrando por ", ad["duracion"], " segundos...")
	
	# Inicia el temporizador usando el tiempo específico de este anuncio
	ad_timer.wait_time = ad["duracion"]
	ad_timer.start()

func _show_next_ad() -> void:
	current_ad_index += 1
	_show_current_ad()

func update_input(event: InputEvent) -> void:
	# LA REGLA DE ORO: Si el jugador quiere jugar, se interrumpe el anuncio al instante
	if event.is_action_pressed("ui_accept"):
		StateManager.change_state(StateManager.States.PRIZE_SELECT)
