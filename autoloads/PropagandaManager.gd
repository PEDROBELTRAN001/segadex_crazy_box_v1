extends Node

const CONFIG_PATH = "user://propaganda_config.json"
var propagandas: Array = []

func _ready() -> void:
	load_propagandas()

func load_propagandas() -> void:
	if FileAccess.file_exists(CONFIG_PATH):
		var file = FileAccess.open(CONFIG_PATH, FileAccess.READ)
		var json = JSON.new()
		if json.parse(file.get_as_text()) == OK:
			propagandas = json.data
			return
	_create_default_propagandas()

func save_propagandas() -> void:
	var file = FileAccess.open(CONFIG_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(propagandas, "\t"))
	file.close()

func get_active_propagandas_sorted() -> Array:
	var active = []
	for p in propagandas:
		if p.get("estado", false):
			active.append(p)
			
	# Ordenar por prioridad (menor número = mayor prioridad)
	active.sort_custom(func(a, b): return a["prioridad"] < b["prioridad"])
	return active

func _create_default_propagandas() -> void:
	propagandas.clear()
	propagandas.append({
		"id": 1,
		"nombre": "Promo Peluches",
		"descripcion": "Lleva 2 por 1",
		"estado": true,
		"prioridad": 2,
		"link": "res://assets/promo1.png",
		"duracion": 5.0,        # Complemento 1: Segundos en pantalla
		"tipo_media": "imagen"  # Complemento 2: "imagen" o "video"
	})
	propagandas.append({
		"id": 2,
		"nombre": "Gran Sorteo SEGADEX",
		"descripcion": "Gana premios extra",
		"estado": true,
		"prioridad": 1, # Se mostrará primero
		"link": "res://assets/sorteo.mp4",
		"duracion": 8.0,
		"tipo_media": "video"
	})
	save_propagandas()
