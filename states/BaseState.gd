class_name BaseState
extends Node

# Se ejecuta automáticamente al entrar a este estado
func enter() -> void:
	pass

# Se ejecuta automáticamente al salir de este estado
func exit() -> void:
	pass

# Manejo de entradas (teclado, mouse, etc.) independiente para cada estado
func update_input(event: InputEvent) -> void:
	pass
