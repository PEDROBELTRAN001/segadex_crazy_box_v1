extends Node
# res://autoloads/PrizeManager.gd

const CONFIG_PATH = "user://prizes_config.json"
var prizes: Array = []

func _ready() -> void:
	load_prizes()

func load_prizes() -> void:
	# La configuración debe mantenerse después de cerrar y volver a abrir el programa[cite: 3].
	if FileAccess.file_exists(CONFIG_PATH):
		var file = FileAccess.open(CONFIG_PATH, FileAccess.READ)
		var json = JSON.new()
		if json.parse(file.get_as_text()) == OK:
			prizes = json.data
			return
	_create_default_prizes()

func save_prizes() -> void:
	# PUNTO DE INTEGRACIÓN: Los scripts externos de Python accederán a este mismo archivo.
	var file = FileAccess.open(CONFIG_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(prizes, "\t"))
	file.close()

func reload_prizes() -> void:
	load_prizes()

func get_enabled_prizes() -> Array:
	# PRIZE_SELECT debe leer la configuración y reconocer únicamente los premios habilitados[cite: 3].
	var enabled = []
	for p in prizes:
		if p.get("habilitado", false):
			enabled.append(p)
	return enabled

func _create_default_prizes() -> void:
	prizes.clear()
	# Crazy Box tendrá 6 slots disponibles, pero podrá operar con cualquier cantidad de premios activos[cite: 2].
	for i in range(1, 7):
		prizes.append({
			"id": i, # ID[cite: 2].
			"nombre": "Premio " + str(i), # Nombre[cite: 3].
			"habilitado": i % 2 != 0, # Habilitado / deshabilitado[cite: 3].
			"record": 1000 + (i * 100), # Récord actual[cite: 3].
			"tendencia": false, # Indicador de premio en tendencia[cite: 3].
			"orden": i # Orden o posición[cite: 3].
		})
	save_prizes()
