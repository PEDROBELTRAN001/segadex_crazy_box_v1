extends Node
# res://autoloads/PrizeManager.gd

const CONFIG_PATH = "res://data/prizes_config.json"
var prizes: Array = []

func _ready() -> void:
	load_prizes()

func load_prizes() -> void:
	if FileAccess.file_exists(CONFIG_PATH):
		var file = FileAccess.open(CONFIG_PATH, FileAccess.READ)
		var json = JSON.new()
		if json.parse(file.get_as_text()) == OK:
			prizes = json.data
			# Asegurar compatibilidad: si algún premio no tiene "record_fijo", se le asigna su "record" actual
			var needs_save = false
			for p in prizes:
				if not p.has("record_fijo"):
					p["record_fijo"] = int(p.get("record", 1000))
					needs_save = true
			if needs_save:
				save_prizes()
			return
	_create_default_prizes()

func save_prizes() -> void:
	var file = FileAccess.open(CONFIG_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(prizes, "\t"))
	file.close()

# Se ejecuta al presionar F5 (ui_reload_json)
func reload_prizes() -> void:
	load_prizes()
	
	# Copiar el valor referencial de record_fijo hacia record
	for p in prizes:
		var fijo: int = int(p.get("record_fijo", p.get("record", 1000)))
		p["record_fijo"] = fijo
		p["record"] = fijo
		
	save_prizes()
	
	# Si había un premio seleccionado en la sesión actual, actualizar también su récord en memoria
	if SessionManager.has_selected_prize():
		var current_id = int(SessionManager.selected_prize.get("id", -1))
		for p in prizes:
			if int(p.get("id", -1)) == current_id:
				SessionManager.select_prize(p)
				break
	else:
		SessionManager.session_updated.emit()
		
	print("JSON recargado con F5: 'record' restaurado al valor de 'record_fijo'.")

func get_enabled_prizes() -> Array:
	var enabled = []
	for p in prizes:
		if p.get("habilitado", false):
			enabled.append(p)
	return enabled

func _create_default_prizes() -> void:
	prizes.clear()
	for i in range(1, 7):
		var base_val = 1000 + (i * 100)
		prizes.append({
			"id": i,
			"nombre": "Premio " + str(i),
			"habilitado": i % 2 != 0,
			"record": base_val,
			"record_fijo": base_val,
			"tendencia": false,
			"orden": i
		})
	save_prizes()

func apply_post_game_discounts(selected_id: int) -> void:
	SessionManager.last_changes_log.clear()
	
	for p in prizes:
		if not p.get("habilitado", false):
			continue
			
		var old_record: int = int(p.get("record", 0))
		var discount: int = 1
		
		if int(p.get("id", -1)) == selected_id:
			discount += 1
			
		var new_record: int = max(0, old_record - discount)
		p["record"] = new_record
		
		var change_text = "%s: %d -> %d (Fijo: %d)" % [p.get("nombre", "Premio"), old_record, new_record, int(p.get("record_fijo", old_record))]
		SessionManager.last_changes_log.append(change_text)
		print("Récord actualizado -> ", change_text)
		
	save_prizes()
	SessionManager.session_updated.emit()
